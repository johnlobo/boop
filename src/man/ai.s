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

;;------------------------------------------------------------------------------
;; Y positions for the AI-select screen options (20 px spacing)
;;------------------------------------------------------------------------------
AI_SELECT_OPT_Y0 = 70
AI_SELECT_OPT_Y1 = 90
AI_SELECT_OPT_Y2 = 110
AI_SELECT_OPT_Y3 = 130
AI_SELECT_OPT_Y4 = 150
AI_SELECT_TITLE_Y = 20
AI_SELECT_HINT1_Y = 175
AI_SELECT_HINT2_Y = 187

;;==============================================================================
;; DATA
;;==============================================================================
.area _DATA

man_ai_level::          .db 0   ;; 0-4: difficulty chosen at select screen
man_ai_select_done::    .db 0   ;; 1=confirmed, 2=cancelled (ESC)
man_ai_select_selected::.db 0   ;; 0-4: highlighted row in select screen

;;------------------------------------------------------------------------------
;; Per-turn evaluation state
;;------------------------------------------------------------------------------
_ai_think_phase:   .db 0   ;; 0=evaluating, 1=post-eval delay, 2=play
_ai_eval_row:      .db 0   ;; next row to evaluate (0..GRID_ROWS)
_ai_eval_col:      .db 0   ;; next col to evaluate (0..GRID_COLS-1)
_ai_post_delay:    .db 0   ;; countdown frames between eval end and move

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

;; Select-screen key debounce
_ai_sel_debounce:  .db 0

;;------------------------------------------------------------------------------
;; Profile table: 5 profiles × AI_PROFILE_SIZE(6) bytes
;;   delay, W_defense, W_align, W_center, W_kitten, rand_mask
;;   Weights chosen so worst-case non-win score stays under 200 (< 255 sentinel)
;;------------------------------------------------------------------------------
_ai_profiles:
   .db 50,  0,  0,  0,  3, #0x1F   ;; 0: GATITO TIMIDO  (random + kitten preference)
   .db 40,  5,  3,  1,  3, #0x0F   ;; 1: GATO JUGUETON  (slight positional)
   .db 30, 12,  6,  2,  6, #0x07   ;; 2: GATA LISTA     (win/block aware)
   .db 20, 18, 10,  3, 10, #0x03   ;; 3: GATO ASTUTO    (balanced)
   .db 10, 20, 15,  4, 15, #0x01   ;; 4: MAESTRO FELINO (full heuristic)

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

;;------------------------------------------------------------------------------
;; AI-select screen strings
;;------------------------------------------------------------------------------
_ai_sel_title:  .asciz "CHOOSE OPPONENT"
_ai_sel_hint1:  .asciz "ARROWS - MOVE"
_ai_sel_hint2:  .asciz "ENTER - SELECT"
_ai_sel_esc:    .asciz "ESC - BACK"

_ai_name_0:  .asciz "GATITO TIMIDO"
_ai_name_1:  .asciz "GATO JUGUETON"
_ai_name_2:  .asciz "GATA LISTA"
_ai_name_3:  .asciz "GATO ASTUTO"
_ai_name_4:  .asciz "MAESTRO FELINO"

_ai_name_ptrs:
   .dw _ai_name_0
   .dw _ai_name_1
   .dw _ai_name_2
   .dw _ai_name_3
   .dw _ai_name_4

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
   jr nz, _mau_play

   ;; --- Phase 1: post-eval delay ---
   ld hl, #_ai_post_delay
   ld a, (hl)
   or a
   jr z, _mau_delay_done
   dec a
   ld (hl), a
   ret
_mau_delay_done:
   ld a, #2
   ld (_ai_think_phase), a
   ret

_mau_play:
   ;; --- Phase 2: execute chosen move ---
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

;;==============================================================================
;; AI LEVEL SELECT SCREEN
;;==============================================================================

;;-----------------------------------------------------------------
;;
;; man_ai_select_init
;;
;;  Clears the screen and draws the AI level selection screen.
;;  Input:  -
;;  Output: man_ai_select_done=0, man_ai_select_selected=0
;;  Modified: AF, BC, DE, HL
;;
man_ai_select_init::
   xor a
   ld (man_ai_select_done), a
   ld (man_ai_select_selected), a
   ld (_ai_sel_debounce), a

   call sys_render_clear_buffer
   call sys_render_draw_header
   call _ai_select_draw
   ret

;;-----------------------------------------------------------------
;;
;; _ai_select_draw
;;
;;  Draws all 5 opponent names; selected one in yellow, others white.
;;  Input:  man_ai_select_selected
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_ai_select_draw:
   ;; Title
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 26, AI_SELECT_TITLE_Y
   ld hl, #_ai_sel_title
   ld c, #1                          ;; yellow
   call sys_text_draw_string

   ;; Draw each of the 5 options
   ld b, #0        ;; option index
_asd_loop:
   ;; Compute Y position: AI_SELECT_OPT_Y0 + b*20
   ld a, b
   add a, a        ;; *2
   add a, a        ;; *4
   add a, b        ;; *5? no... 20 = 16+4
   ;; Y = 70 + b*20: compute as b*16 + b*4 + 70
   ld c, a         ;; C = b*5 (scratch)... let me just use a multiply
   ;; b*20 = b*16 + b*4
   ld a, b
   add a, a        ;; *2
   add a, a        ;; *4
   ld c, a         ;; C = b*4
   add a, a        ;; *8
   add a, a        ;; *16
   add a, c        ;; *20
   add a, #AI_SELECT_OPT_Y0
   ld e, a         ;; E = Y (for cpctm_screenPtr_asm... but that's a compile-time macro)

   ;; We need a runtime screen address. Use cpct_getScreenPtr_asm.
   ;; C = X (byte), B = Y (px) → HL = screen addr
   push bc         ;; save option index in B
   ld b, a         ;; B = Y
   ld c, #27       ;; X = 27 bytes (centered)
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl       ;; DE = screen addr

   ;; Look up name string pointer
   pop bc          ;; restore B = option index
   push bc
   ld a, b
   add a, a        ;; *2 (word index)
   ld hl, #_ai_name_ptrs
   ld c, a
   ld b, #0
   add hl, bc
   ld c, (hl)
   inc hl
   ld b, (hl)      ;; BC = name string pointer
   ld h, b
   ld l, c         ;; HL = name string pointer

   pop bc          ;; restore B = option index
   push bc
   ld a, (man_ai_select_selected)
   cp b
   jr nz, _asd_white
   ld c, #1        ;; yellow = selected
   jr _asd_draw
_asd_white:
   ld c, #0        ;; white = unselected
_asd_draw:
   call sys_text_draw_string

   pop bc
   inc b
   ld a, b
   cp #5
   jr c, _asd_loop

   ;; Hint lines
   ld c, #27
   ld b, #AI_SELECT_HINT1_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_ai_sel_hint1
   ld c, #3
   call sys_text_draw_string

   ld c, #29
   ld b, #AI_SELECT_HINT2_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_ai_sel_hint2
   ld c, #3
   call sys_text_draw_string

   ld c, #32
   ld b, #(AI_SELECT_HINT2_Y + 12)
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_ai_sel_esc
   ld c, #3
   call sys_text_draw_string

   ret

;;-----------------------------------------------------------------
;;
;; man_ai_select_update
;;
;;  Handles input on the AI level selection screen.
;;  Input:  -
;;  Output: man_ai_select_done: 1=confirmed, 2=cancelled
;;          man_ai_level set to selected option when confirmed
;;  Modified: AF, BC, DE, HL
;;
man_ai_select_update::
   ;; Debounce: wait for full key release
   ld a, (_ai_sel_debounce)
   or a
   jr z, _masu_check_keys
   call cpct_isAnyKeyPressed_asm
   or a
   ret nz
   xor a
   ld (_ai_sel_debounce), a
   ret

_masu_check_keys:
   ;; Cursor Up
   ld hl, #Key_CursorUp
   call cpct_isKeyPressed_asm
   jr z, _masu_check_down
   ld a, (man_ai_select_selected)
   or a
   jr z, _masu_up_wrap
   dec a
   jr _masu_up_done
_masu_up_wrap:
   ld a, #4
_masu_up_done:
   ld (man_ai_select_selected), a
   call _ai_select_draw
   jr _masu_debounce

_masu_check_down:
   ld hl, #Key_CursorDown
   call cpct_isKeyPressed_asm
   jr z, _masu_check_enter
   ld a, (man_ai_select_selected)
   cp #4
   jr z, _masu_down_wrap
   inc a
   jr _masu_down_done
_masu_down_wrap:
   xor a
_masu_down_done:
   ld (man_ai_select_selected), a
   call _ai_select_draw
   jr _masu_debounce

_masu_check_enter:
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   jr z, _masu_check_esc
   ;; Confirm: copy selected to man_ai_level, signal done
   ld a, (man_ai_select_selected)
   ld (man_ai_level), a
   ld a, #1
   ld (man_ai_select_done), a
   jr _masu_debounce

_masu_check_esc:
   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   jr z, _masu_done
   ;; Cancel: signal caller to return to menu
   ld a, #2
   ld (man_ai_select_done), a

_masu_debounce:
   ld a, #1
   ld (_ai_sel_debounce), a
_masu_done:
   ret
