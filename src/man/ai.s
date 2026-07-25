;;-----------------------------LICENSE NOTICE------------------------------------
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

.include "man/ai.h.s"
.include "man/match.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/render.h.s"
.include "sys/text.h.s"
.include "sys/util.h.s"

.module man_ai

;;------------------------------------------------------------------------------
;; Cells evaluated per frame during move search (4 cells × 2 piece types = ~8
;; simulations per frame; at level 4 this finishes in ~9 frames for empty board)
;;------------------------------------------------------------------------------
AI_EVAL_CELLS_PER_FRAME = 4

;;==============================================================================
;; DATA
;;==============================================================================
.area _DATA

man_ai_level::          .db 0   ;; 0-3: difficulty chosen at level-select screen

;;------------------------------------------------------------------------------
;; Per-turn evaluation state
;;------------------------------------------------------------------------------
_ai_think_phase:   .db 0   ;; 0=eval, 1=delay, 2=cursor anim, 3=play
_ai_eval_row:      .db 0   ;; next row to evaluate (0..GRID_ROWS)
_ai_eval_col:      .db 0   ;; next col to evaluate (0..GRID_COLS-1)
_ai_post_delay:    .db 0   ;; countdown frames between eval end and move
_ai_anim_delay:    .db 0   ;; countdown frames between animation steps

;; Pre-computed baselines (computed once at start of each AI turn)
_ai_opp_before:    .db 0   ;; P1 cat-pair count before any simulation
_ai_own_before:    .db 0   ;; P2 piece-pair count before any simulation

;; Current candidate being scored
_ai_cand_col:      .db 0
_ai_cand_row:      .db 0
_ai_cand_piece:    .db 0   ;; PIECE_CAT or PIECE_KITTEN

;; Best move found so far
_ai_best_col:      .db 0
_ai_best_row:      .db 0
_ai_best_piece:    .db 0
_ai_best_score:    .db 0   ;; 0..254; 255 = winning move sentinel

;; Active profile pointer (16-bit, set in man_ai_init)
_ai_profile_ptr:   .dw 0

;; Simulation save buffers
_ai_board_backup:  .ds 36
_ai_p1_backup:     .ds 6
_ai_p2_backup:     .ds 6

;; Temporary count variable shared by all pair/line counting functions
_ai_pair_count:    .db 0

;;------------------------------------------------------------------------------
;; Profile table: 4 profiles × AI_PROFILE_SIZE(6) bytes
;;   delay, W_defense, W_align, W_center, W_kitten, rand_mask
;;   Weights chosen so worst-case non-win score stays under 200 (< 255 sentinel)
;;------------------------------------------------------------------------------
_ai_profiles:
   .db 50,  0,  0,  0,  3, #0x1F   ;; 0: GATITO TIMIDO  (random + kitten preference)
   .db 40,  5,  3,  1,  3, #0x0F   ;; 1: GATO JUGUETON  (slight positional)
   .db 20, 18, 10,  3, 10, #0x03   ;; 2: GATA ASTUTA    (balanced)
   .db 10, 20, 15,  4, 15, #0x01   ;; 3: MAESTRO FELINO (full heuristic)

;;------------------------------------------------------------------------------
;; Center-bonus lookup table (36 bytes, index = row*6 + col, value 0..3)
;;------------------------------------------------------------------------------
_ai_center_table:
   .db 0, 0, 1, 1, 0, 0   ;; row 0
   .db 0, 1, 2, 2, 1, 0   ;; row 1
   .db 1, 2, 3, 3, 2, 1   ;; row 2
   .db 1, 2, 3, 3, 2, 1   ;; row 3
   .db 0, 1, 2, 2, 1, 0   ;; row 4
   .db 0, 0, 1, 1, 0, 0   ;; row 5


;;==============================================================================
;; CODE
;;==============================================================================
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_ai_init
;;
;;  Resets the per-turn evaluation state and picks a random fallback
;;  move. Call at man_match_init time and after each AI move.
;;  Baseline board counts are computed lazily on the first evaluated
;;  cell (so they reflect the board AFTER P1's last move).
;;  Input:  man_ai_level set
;;  Output: _ai_think_phase=0, _ai_eval_row/col=0, best=fallback
;;  Modified: AF, BC, DE, HL, IX
;;
man_ai_init::
   ;; Reset phase and eval position
   xor a
   ld (_ai_think_phase), a
   ld (_ai_eval_row), a
   ld (_ai_eval_col), a
   ld (_ai_best_score), a

   ;; Load profile pointer for current level
   call _ai_load_profile_ptr
   ld (_ai_profile_ptr), hl

   ;; Set a random valid fallback move (in case all candidates score 0)
   call _ai_set_random_fallback
   ret

;;-----------------------------------------------------------------
;;
;; man_ai_update
;;
;;  Called every frame when it is P2's turn (1-player mode).
;;  Phase 0: evaluates AI_EVAL_CELLS_PER_FRAME cells per frame.
;;  Phase 1: waits post-eval delay (personality "think time").
;;  Phase 2: executes the chosen move via _match_place_piece.
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX, IY
;;
man_ai_update::
   ld a, (_ai_think_phase)
   or a
   jr nz, _mau_phase12

   ;; --- Phase 0: evaluating ---
   ld b, #AI_EVAL_CELLS_PER_FRAME
_mau_eval_loop:
   ;; Stop early if winning move already found
   ld a, (_ai_best_score)
   cp #AI_WIN_SENTINEL
   jr z, _mau_eval_fast_done

   ;; Check if all rows have been evaluated
   ld a, (_ai_eval_row)
   cp #GRID_ROWS
   jr nc, _mau_eval_complete

   call _ai_eval_one_cell
   dec b
   jr nz, _mau_eval_loop
   ret

_mau_eval_fast_done:
   ;; Winning move found; skip remaining evaluation
   ld a, #GRID_ROWS
   ld (_ai_eval_row), a   ;; mark as done

_mau_eval_complete:
   ;; Switch to post-eval delay
   ld a, #1
   ld (_ai_think_phase), a
   ld hl, (_ai_profile_ptr)
   ld a, (hl)              ;; delay_frames (offset 0)
   ld (_ai_post_delay), a
   ret

_mau_phase12:
   cp #1
   jr z, _mau_delay_phase
   cp #2
   jr z, _mau_anim_phase
   jr _mau_play            ;; phase 3

_mau_delay_phase:
   ;; --- Phase 1: post-eval delay ---
   ld hl, #_ai_post_delay
   ld a, (hl)
   or a
   jr z, _mau_delay_done
   dec a
   ld (hl), a
   ret
_mau_delay_done:
   ;; Cursor is already at (0,5) from _match_place_piece; just set piece type
   ld a, (_ai_best_piece)
   ld (_cursor_piece), a
   ;; Switch to animation phase with initial step delay
   ld a, #4
   ld (_ai_anim_delay), a
   ld a, #2
   ld (_ai_think_phase), a
   ret

_mau_anim_phase:
   ;; --- Phase 2: animate cursor moving toward target ---
   ld hl, #_ai_anim_delay
   ld a, (hl)
   or a
   jr z, _mau_anim_step
   dec a
   ld (hl), a
   ret
_mau_anim_step:
   call _ai_cursor_step    ;; Z=1 if already at target
   jr nz, _mau_anim_cont
   ld a, #3
   ld (_ai_think_phase), a
   ret
_mau_anim_cont:
   ld a, #4
   ld (_ai_anim_delay), a
   ret

_mau_play:
   ;; --- Phase 3: cursor is at target, execute move ---
   ld a, (_ai_best_col)
   ld (_cursor_col), a
   ld a, (_ai_best_row)
   ld (_cursor_row), a
   ld a, (_ai_best_piece)
   ld (_cursor_piece), a
   call _match_place_piece
   call man_ai_init        ;; reset for next AI turn
   ret

;;-----------------------------------------------------------------
;;
;; _ai_cursor_step
;;
;;  Moves the cursor one step toward (_ai_best_col, _ai_best_row),
;;  restoring the previous cell and redrawing the cursor at the new
;;  position. Column is adjusted before row.
;;  Input:  _cursor_col, _cursor_row = current position
;;          _ai_best_col, _ai_best_row = target
;;  Output: Z=1 if cursor was already at target (no step taken)
;;          Z=0 a step was taken and cursor redrawn
;;  Modified: AF, BC, DE, HL, IX
;;
_ai_cursor_step:
   ld a, (_cursor_col)
   ld c, a                    ;; C = current col
   ld a, (_cursor_row)
   ld b, a                    ;; B = current row

   ;; Try moving column first
   ld a, (_ai_best_col)
   cp c
   jr z, _acs_try_row

   push bc                    ;; save old row/col for restore
   jr c, _acs_col_left
   inc c
   jr _acs_col_moved
_acs_col_left:
   dec c
_acs_col_moved:
   ld a, c
   ld (_cursor_col), a
   pop bc                     ;; B=old_row, C=old_col
   call _match_restore_cell
   call _match_draw_cursor
   push af
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop af
   or #1                      ;; Z=0: step taken
   ret

_acs_try_row:
   ld a, (_ai_best_row)
   cp b
   jr z, _acs_arrived

   push bc
   jr c, _acs_row_up
   inc b
   jr _acs_row_moved
_acs_row_up:
   dec b
_acs_row_moved:
   ld a, b
   ld (_cursor_row), a
   pop bc
   call _match_restore_cell
   call _match_draw_cursor
   push af
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop af
   or #1
   ret

_acs_arrived:
   xor a                      ;; Z=1: already at target
   ret

;;-----------------------------------------------------------------
;;
;; _ai_eval_one_cell
;;
;;  Evaluates the current (_ai_eval_row, _ai_eval_col) cell, then
;;  advances to the next position. On the very first cell (0,0),
;;  computes the baseline board counts for this turn.
;;  Input:  -
;;  Output: _ai_eval_col/_ai_eval_row advanced
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_ai_eval_one_cell:
   ;; On first cell: compute baselines so they reflect P1's latest move
   ld a, (_ai_eval_row)
   or a
   jr nz, _aeoc_not_first
   ld a, (_ai_eval_col)
   or a
   jr nz, _aeoc_not_first
   call _ai_count_p1_cat_pairs
   ld (_ai_opp_before), a
   call _ai_count_p2_piece_pairs
   ld (_ai_own_before), a
_aeoc_not_first:

   ;; Copy position to candidate vars and score
   ld a, (_ai_eval_col)
   ld (_ai_cand_col), a
   ld a, (_ai_eval_row)
   ld (_ai_cand_row), a
   call _ai_score_cell_both_pieces

   ;; Advance column
   ld hl, #_ai_eval_col
   ld a, (hl)
   inc a
   ld (hl), a
   cp #GRID_COLS
   ret c            ;; col < 6: done
   ;; Wrap column, advance row
   xor a
   ld (hl), a
   ld hl, #_ai_eval_row
   inc (hl)
   ret

;;-----------------------------------------------------------------
;;
;; _ai_score_cell_both_pieces
;;
;;  If cell (_ai_cand_row, _ai_cand_col) is empty, scores it for
;;  both kitten and cat (when the piece type is available to P2).
;;  Input:  _ai_cand_row, _ai_cand_col
;;  Output: possibly updates _ai_best_*
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_ai_score_cell_both_pieces:
   ;; Compute board index = row*6 + col
   ld a, (_ai_cand_row)
   ld b, a
   add a, a         ;; *2
   add a, a         ;; *4
   add a, b         ;; *5
   add a, b         ;; *6
   ld b, a
   ld a, (_ai_cand_col)
   add a, b
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc
   ld a, (hl)
   or a
   ret nz           ;; cell occupied: skip

   ;; Try KITTEN
   ld a, (man_match_player2 + Player_kittens)
   or a
   jr z, _ascbp_try_cat
   ld a, #PIECE_KITTEN
   ld (_ai_cand_piece), a
   call _ai_score_one_candidate

_ascbp_try_cat:
   ld a, (man_match_player2 + Player_cats)
   or a
   ret z
   ld a, #PIECE_CAT
   ld (_ai_cand_piece), a
   jp _ai_score_one_candidate   ;; tail call

;;-----------------------------------------------------------------
;;
;; _ai_score_one_candidate
;;
;;  Simulates placing _ai_cand_piece at (_ai_cand_row, _ai_cand_col)
;;  as P2, evaluates the resulting board with the heuristic, then
;;  restores the board to its original state.
;;  Updates _ai_best_* if this candidate scores higher.
;;  Input:  _ai_cand_col, _ai_cand_row, _ai_cand_piece
;;          _ai_opp_before, _ai_own_before, _ai_profile_ptr
;;  Output: possibly updates _ai_best_*
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_ai_score_one_candidate:
   ;; === Save board and player reserves ===
   ld hl, #_match_board
   ld de, #_ai_board_backup
   ld bc, #36
   ldir

   ld hl, #man_match_player1
   ld de, #_ai_p1_backup
   ld bc, #sizeof_Player
   ldir

   ld hl, #man_match_player2
   ld de, #_ai_p2_backup
   ld bc, #sizeof_Player
   ldir

   ;; === Set cursor to candidate position ===
   ld a, (_ai_cand_col)
   ld (_cursor_col), a
   ld a, (_ai_cand_row)
   ld (_cursor_row), a
   ld a, (_ai_cand_piece)
   ld (_cursor_piece), a

   ;; === Place piece + boop (no animation) ===
   call _ai_place_no_animate

   ;; === Evaluate ===
   ld d, #0        ;; D = score accumulator

   ;; Priority 1: immediate P2 cat win → sentinel score, early exit
   call _ai_has_p2_cat_win
   or a
   jr z, _asoc_no_win
   ld d, #AI_WIN_SENTINEL
   jr _asoc_restore

_asoc_no_win:
   ;; Load profile into IX for fast weight access
   ld hl, (_ai_profile_ptr)
   push hl
   pop ix          ;; IX = &profile[0]

   ;; --- Defense: opponent cat-pair reduction ---
   call _ai_count_p1_cat_pairs  ;; A = pairs after simulation
   ld e, a
   ld a, (_ai_opp_before)
   sub e            ;; A = reduction (how many P1 threats disrupted)
   jr nc, _asoc_def_ok
   xor a            ;; clamp to 0 if negative
_asoc_def_ok:
   ld e, a
   ld a, 1(ix)      ;; W_defense
   call _ai_mul_e_a ;; A = reduction × W_defense
   add a, d
   ld d, a

   ;; --- Alignment: own piece-pair improvement ---
   call _ai_count_p2_piece_pairs  ;; A = pairs after
   ld b, a
   ld a, (_ai_own_before)
   ;; gain = after - before
   ld e, b
   sub e            ;; A = before - after; we want after - before
   neg              ;; A = after - before (may be negative)
   jr nc, _asoc_align_ok
   xor a
_asoc_align_ok:
   ld e, a
   ld a, 2(ix)      ;; W_align
   call _ai_mul_e_a
   add a, d
   ld d, a

   ;; --- Center bonus ---
   call _ai_center_bonus  ;; A = 0..3
   ld e, a
   ld a, 3(ix)      ;; W_center
   call _ai_mul_e_a
   add a, d
   ld d, a

   ;; --- Kitten 3-in-a-row lines created ---
   call _ai_count_p2_three_in_row  ;; A = count
   ld e, a
   ld a, 4(ix)      ;; W_kitten
   call _ai_mul_e_a
   add a, d
   ld d, a

   ;; --- Random noise ---
   call cpct_getRandom_mxor_u8_asm
   ld a, l
   and 5(ix)        ;; rand_mask
   add a, d
   ld d, a

   ;; --- Danger check: does this move leave P1 an immediate win? ---
   ;; Only applied at levels 2-3 (GATA ASTUTA / MAESTRO FELINO); lower
   ;; levels stay blind to this threat on purpose (part of their weakness).
   ld a, (man_ai_level)
   cp #2
   jr c, _asoc_restore     ;; level 0-1: skip danger check
   push de                 ;; D = accumulated score, save across the call
   call _ai_has_p1_cat_win
   pop de
   or a
   jr z, _asoc_restore     ;; no danger: keep heuristic score
   ld d, #0                ;; danger: this move loses the game, discard score

_asoc_restore:
   ;; === Restore board and player reserves ===
   ld hl, #_ai_board_backup
   ld de, #_match_board
   ld bc, #36
   ldir

   ld hl, #_ai_p1_backup
   ld de, #man_match_player1
   ld bc, #sizeof_Player
   ldir

   ld hl, #_ai_p2_backup
   ld de, #man_match_player2
   ld bc, #sizeof_Player
   ldir

   ;; === Compare with current best ===
   ld a, d            ;; score
   ld hl, #_ai_best_score
   cp (hl)
   jr c, _asoc_done   ;; worse: skip
   jr z, _asoc_equal  ;; equal: 50% RNG tiebreak
   ;; Better: always replace
   ld (hl), a
   jr _asoc_update_best
_asoc_equal:
   ;; Replace 50% of the time (add variety at equal scores)
   call cpct_getRandom_mxor_u8_asm
   ld a, l
   rra              ;; test bit 0
   jr nc, _asoc_done
   ld a, d
   ld (_ai_best_score), a
_asoc_update_best:
   ld a, (_ai_cand_col)
   ld (_ai_best_col), a
   ld a, (_ai_cand_row)
   ld (_ai_best_row), a
   ld a, (_ai_cand_piece)
   ld (_ai_best_piece), a
_asoc_done:
   ret

;;-----------------------------------------------------------------
;;
;; _ai_place_no_animate
;;
;;  Places the current candidate piece on _match_board as P2 and
;;  runs the boop. No animation, no line check, no win check.
;;  Input:  _cursor_col, _cursor_row, _cursor_piece, _match_board
;;  Output: _match_board updated (boop applied)
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_ai_place_no_animate:
   ;; Compute board index
   ld a, (_cursor_row)
   ld b, a
   add a, a    ;; *2
   add a, a    ;; *4
   add a, b    ;; *5
   add a, b    ;; *6
   ld b, a
   ld a, (_cursor_col)
   add a, b
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc  ;; HL = &board[row][col]

   ;; Decrement P2 piece reserve and write board value
   ld ix, #man_match_player2
   ld a, (_cursor_piece)
   or a
   jr nz, _apna_kitten
   ;; CAT: board value = BOARD_P2_CAT = 3
   dec Player_cats(ix)
   ld (hl), #BOARD_P2_CAT
   jp _match_boop_cat   ;; tail call
_apna_kitten:
   ;; KITTEN: board value = BOARD_P2_KITTEN = 4
   dec Player_kittens(ix)
   ld (hl), #BOARD_P2_KITTEN
   jp _match_boop       ;; tail call

;;-----------------------------------------------------------------
;;
;; _ai_has_p2_cat_win
;;
;;  Scans _match_board for 3 consecutive BOARD_P2_CAT (=3) in any
;;  row or column (windows of 3).
;;  Output: A = 1 if P2 has 3 cats in a row, 0 otherwise
;;  Modified: AF, BC, DE, HL
;;
_ai_has_p2_cat_win:
   ;; Horizontal scan
   ld b, #0
_ahpcw_hrow:
   ld c, #0
_ahpcw_hcol:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_hnext
   pop bc
   ld a, #1
   ret
_ahpcw_hnext:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)   ;; window start: 0..3
   jr c, _ahpcw_hcol
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _ahpcw_hrow

   ;; Vertical scan
   ld c, #0
_ahpcw_vcol:
   ld b, #0
_ahpcw_vrow:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_vnext
   ld de, #6
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_vnext
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr nz, _ahpcw_vnext
   pop bc
   ld a, #1
   ret
_ahpcw_vnext:
   pop bc
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)   ;; window start: 0..3
   jr c, _ahpcw_vrow
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _ahpcw_vcol

   xor a
   ret

;;-----------------------------------------------------------------
;;
;; _ai_has_p1_cat_win
;;
;;  Scans _match_board for 3 consecutive BOARD_P1_CAT (=1) in any
;;  row or column (windows of 3). Used to detect whether a simulated
;;  P2 move leaves P1 with an immediate winning reply.
;;  Output: A = 1 if P1 has 3 cats in a row, 0 otherwise
;;  Modified: AF, BC, DE, HL
;;
_ai_has_p1_cat_win:
   ;; Horizontal scan
   ld b, #0
_ahp1cw_hrow:
   ld c, #0
_ahp1cw_hcol:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_hnext
   pop bc
   ld a, #1
   ret
_ahp1cw_hnext:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)   ;; window start: 0..3
   jr c, _ahp1cw_hcol
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _ahp1cw_hrow

   ;; Vertical scan
   ld c, #0
_ahp1cw_vcol:
   ld b, #0
_ahp1cw_vrow:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_vnext
   ld de, #6
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_vnext
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _ahp1cw_vnext
   pop bc
   ld a, #1
   ret
_ahp1cw_vnext:
   pop bc
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)   ;; window start: 0..3
   jr c, _ahp1cw_vrow
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _ahp1cw_vcol

   xor a
   ret

;;-----------------------------------------------------------------
;;
;; _ai_count_p1_cat_pairs
;;
;;  Counts adjacent pairs of BOARD_P1_CAT (=1) in _match_board:
;;  horizontal (col c and c+1) and vertical (row r and r+1).
;;  Output: A = count (typically 0-4)
;;  Modified: AF, BC, DE, HL
;;
_ai_count_p1_cat_pairs:
   xor a
   ld (_ai_pair_count), a

   ;; Horizontal: rows 0..5, col window 0..4
   ld b, #0
_a1cp_hrow:
   ld c, #0
_a1cp_hcol:
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _a1cp_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _a1cp_hnext
   ld hl, #_ai_pair_count
   inc (hl)
_a1cp_hnext:
   inc c
   ld a, c
   cp #(GRID_COLS - 1)
   jr c, _a1cp_hcol
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _a1cp_hrow

   ;; Vertical: rows 0..4, cols 0..5
   ld b, #0
_a1cp_vrow:
   ld c, #0
_a1cp_vcol:
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _a1cp_vnext
   ld de, #6
   add hl, de
   ld a, (hl)
   cp #BOARD_P1_CAT
   jr nz, _a1cp_vnext
   ld hl, #_ai_pair_count
   inc (hl)
_a1cp_vnext:
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _a1cp_vcol
   inc b
   ld a, b
   cp #(GRID_ROWS - 1)
   jr c, _a1cp_vrow

   ld a, (_ai_pair_count)
   ret

;;-----------------------------------------------------------------
;;
;; _ai_count_p2_piece_pairs
;;
;;  Counts adjacent pairs of ANY P2 piece (values 3 or 4, i.e.
;;  >= BOARD_P2_CAT) in _match_board: horizontal and vertical.
;;  Output: A = count
;;  Modified: AF, BC, DE, HL
;;
_ai_count_p2_piece_pairs:
   xor a
   ld (_ai_pair_count), a

   ;; Horizontal: rows 0..5, col window 0..4
   ld b, #0
_a2pp_hrow:
   ld c, #0
_a2pp_hcol:
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT      ;; >= 3 means P2 piece
   jr c, _a2pp_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2pp_hnext
   ld hl, #_ai_pair_count
   inc (hl)
_a2pp_hnext:
   inc c
   ld a, c
   cp #(GRID_COLS - 1)
   jr c, _a2pp_hcol
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _a2pp_hrow

   ;; Vertical: rows 0..4, cols 0..5
   ld b, #0
_a2pp_vrow:
   ld c, #0
_a2pp_vcol:
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2pp_vnext
   ld de, #6
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2pp_vnext
   ld hl, #_ai_pair_count
   inc (hl)
_a2pp_vnext:
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _a2pp_vcol
   inc b
   ld a, b
   cp #(GRID_ROWS - 1)
   jr c, _a2pp_vrow

   ld a, (_ai_pair_count)
   ret

;;-----------------------------------------------------------------
;;
;; _ai_count_p2_three_in_row
;;
;;  Counts windows of 3 consecutive P2 pieces (values >= 3) in
;;  _match_board, both horizontal and vertical.
;;  On the simulated board, any count > 0 means placing this piece
;;  would trigger a kitten→cat conversion for P2.
;;  Output: A = count (typically 0-2)
;;  Modified: AF, BC, DE, HL
;;
_ai_count_p2_three_in_row:
   xor a
   ld (_ai_pair_count), a

   ;; Horizontal: rows 0..5, col window 0..3
   ld b, #0
_a2tir_hrow:
   ld c, #0
_a2tir_hcol:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_hnext
   inc hl
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_hnext
   ld hl, #_ai_pair_count
   inc (hl)
_a2tir_hnext:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)
   jr c, _a2tir_hcol
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _a2tir_hrow

   ;; Vertical: rows 0..3, cols 0..5
   ld c, #0
_a2tir_vcol:
   ld b, #0
_a2tir_vrow:
   push bc
   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_vnext
   ld de, #6
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_vnext
   add hl, de
   ld a, (hl)
   cp #BOARD_P2_CAT
   jr c, _a2tir_vnext
   ld hl, #_ai_pair_count
   inc (hl)
_a2tir_vnext:
   pop bc
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)
   jr c, _a2tir_vrow
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _a2tir_vcol

   ld a, (_ai_pair_count)
   ret

;;-----------------------------------------------------------------
;;
;; _ai_center_bonus
;;
;;  Returns a 0-3 center-proximity bonus for the current candidate
;;  cell, using the precomputed 36-byte _ai_center_table.
;;  Input:  _ai_cand_row, _ai_cand_col
;;  Output: A = 0..3
;;  Modified: AF, BC, HL
;;
_ai_center_bonus:
   ld a, (_ai_cand_row)
   ld b, a
   add a, a    ;; *2
   add a, a    ;; *4
   add a, b    ;; *5
   add a, b    ;; *6
   ld b, a
   ld a, (_ai_cand_col)
   add a, b
   ld hl, #_ai_center_table
   ld c, a
   ld b, #0
   add hl, bc
   ld a, (hl)
   ret

;;-----------------------------------------------------------------
;;
;; _ai_mul_e_a
;;
;;  Multiplies E by A (both small values, result < 256).
;;  A = E × A
;;  Input:  E = multiplicand (count, 0-5), A = multiplier (weight, 0-20)
;;  Output: A = product
;;  Modified: AF, B
;;
_ai_mul_e_a:
   ld b, a     ;; B = weight (loop count)
   xor a       ;; A = accumulator
   or b
   ret z       ;; weight 0: result 0
_ame_loop:
   add a, e    ;; accumulate E
   dec b
   jr nz, _ame_loop
   ret

;;-----------------------------------------------------------------
;;
;; _ai_load_profile_ptr
;;
;;  Computes HL = &_ai_profiles[man_ai_level * AI_PROFILE_SIZE].
;;  AI_PROFILE_SIZE = 6: multiply by 6 = shift-left-3 minus shift-left-1.
;;  Input:  man_ai_level (0-4)
;;  Output: HL = pointer to current profile entry
;;  Modified: AF, BC, HL
;;
_ai_load_profile_ptr:
   ;; level*6 = level*4 + level*2
   ld a, (man_ai_level)
   ld c, a     ;; C = level
   add a, a    ;; A = level*2
   add a, c    ;; A = level*3
   add a, a    ;; A = level*6
   ld c, a
   ld b, #0
   ld hl, #_ai_profiles
   add hl, bc
   ret

;;-----------------------------------------------------------------
;;
;; _ai_set_random_fallback
;;
;;  Picks a random empty cell and the preferred piece type (kitten
;;  if available, cat otherwise) as a guaranteed fallback move in
;;  case no candidate receives a positive score.
;;  Input:  -
;;  Output: _ai_best_col, _ai_best_row, _ai_best_piece populated
;;  Modified: AF, BC, DE, HL
;;
_ai_set_random_fallback:
_asrf_retry:
   call cpct_getRandom_mxor_u8_asm
   ld a, l
   call _ai_mod6
   ld (_ai_best_col), a

   call cpct_getRandom_mxor_u8_asm
   ld a, l
   call _ai_mod6
   ld (_ai_best_row), a

   ;; Compute board index and check if empty
   ld a, (_ai_best_row)
   ld b, a
   add a, a
   add a, a
   add a, b
   add a, b
   ld b, a
   ld a, (_ai_best_col)
   add a, b
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc
   ld a, (hl)
   or a
   jr nz, _asrf_retry   ;; occupied: try again

   ;; Set preferred piece type
   ld a, (man_match_player2 + Player_kittens)
   or a
   jr nz, _asrf_kitten
   ld a, #PIECE_CAT
   jr _asrf_done
_asrf_kitten:
   ld a, #PIECE_KITTEN
_asrf_done:
   ld (_ai_best_piece), a
   ret

;;-----------------------------------------------------------------
;;
;; _ai_mod6
;;
;;  Returns A mod 6 using a fast and-then-subtract loop.
;;  Input:  A (0-255)
;;  Output: A = A mod 6 (0-5)
;;  Modified: AF
;;
_ai_mod6:
   and #31      ;; reduce to 0..31 (at most 5 subtractions below)
_am6_loop:
   cp #6
   ret c        ;; A < 6: done
   sub #6
   jr _am6_loop

