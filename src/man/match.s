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

.include "man/match.h.s"
.include "man/menu.h.s"
.include "man/ai.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/sound.h.s"
.include "sys/render.h.s"
.include "sys/input.h.s"
.include "sys/messages.h.s"
.include "sys/util.h.s"

.module man_match

MATCH_INITIAL_CATS    = 0
MATCH_INITIAL_KITTENS = 8

;; Cursor box dimensions (smaller than cell to leave gaps)
;; Width: GRID_CELL_W - 1 byte = 2 pixels thinner
;; Height: GRID_CELL_H - 2 pixels shorter
CURSOR_W              = 5
CURSOR_H              = 20

S_BIG_NUMBERS_W = 3
S_BIG_NUMBERS_H = 13

;;
;; Start of _DATA area
;;
.area _DATA

man_match_player1:: .ds sizeof_Player
man_match_player2:: .ds sizeof_Player
man_match_num_players:: .db 1

;;
;; Board: 6x6 cells, row-major [row*6 + col]
;; Values: 0=empty, 1=P1 cat, 2=P1 kitten, 3=P2 cat, 4=P2 kitten
;;
_match_board:: .ds 36

;;
;; Turn / cursor state
;;
_match_cancelled:: .db 0 ;; set to 1 when player confirms ESC → abandon match
_match_state::     .db 0 ;; MATCH_STATE_P1 or MATCH_STATE_P2 (exported for tests/run_rules.c)
_cursor_col::   .db 0   ;; 0 .. GRID_COLS-1  (exported for AI module)
_cursor_row::   .db 0   ;; 0 .. GRID_ROWS-1  (exported for AI module)
_cursor_piece:: .db 0   ;; PIECE_CAT or PIECE_KITTEN (exported for AI module)

;; Last-move marker: row/col of the most recently placed piece, so its cell
;; can be highlighted. 0xFF = no marker (start of match). Set at the end of
;; _match_place_piece; reset in man_match_init.
_last_move_row: .db 0xFF
_last_move_col: .db 0xFF
_lmm_x:         .db 0   ;; scratch: box byte-column origin (_match_draw_cell_frame / _match_draw_bbox_frame)
_lmm_y:         .db 0   ;; scratch: box pixel-row origin
_lmm_color:     .db 0   ;; scratch: colour pattern byte, across the clobbering calls
_lmm_w:         .db 0   ;; scratch: box width in bytes (_match_draw_bbox_frame only)
_lmm_h:         .db 0   ;; scratch: box height in px (_match_draw_bbox_frame only)

;; Scratch for the cat-triple win-line blink (_match_flash_win_box)
_mfwb_row:      .db 0
_mfwb_col:      .db 0
_mfwb_w:        .db 0
_mfwb_h:        .db 0
_mfwb_horiz:    .db 0   ;; 1 = 3 cols wide (horizontal line), 0 = 3 rows tall

;; Scratch for _match_restore_top_sliver
_mrts_row:      .db 0
_mrts_col:      .db 0
_mrts_w:        .db 0

;; Set by _match_mark_cats_increased whenever a player's cat reserve grows
;; (kitten converted via a 3-in-a-row, or a cat ejected back off the
;; board); consumed once by _mpp_do_place right after the HUD redraw, which
;; blinks that player's "cats" digit via _match_blink_cats_hud.
_cats_blink_p1: .db 0
_cats_blink_p2: .db 0
_match_simulation_mode:: .db 0   ;; suppress UI/SFX side effects during AI simulation
_mbch_addr:     .dw 0   ;; scratch: digit screen address (_match_blink_cats_hud)
_mbch_digit:    .db 0   ;; scratch: digit value, across the delay calls
_mbch_player:   .db 0   ;; scratch: 1/2, needed again for the backdrop restore
_mcdb_src:      .dw 0   ;; scratch: basket source ptr (_match_restore_cats_digit_backdrop)
_mcdb_dst:      .dw 0   ;; scratch: screen dest ptr
_mgow_player:   .db 0   ;; scratch: 1/2 (_match_graduate_or_win)

;; Scratch for diagonal match flashes (_match_flash_combo_diag /
;; _match_flash_win_diag): the bbox frame only draws axis-aligned
;; rectangles, so diagonals flash 3 individual cell frames instead.
_mfdc_r0:       .db 0
_mfdc_c0:       .db 0
_mfdc_r1:       .db 0
_mfdc_c1:       .db 0
_mfdc_r2:       .db 0
_mfdc_c2:       .db 0
_mfdc_color:    .db 0

;; Trio-candidate collection/choice (_match_collect_trio_candidates,
;; _match_trio_choice_ui, _match_resolve_window, _match_window_geometry).
;; When a move creates more than one valid trio, the real rule requires the
;; player to pick one — see the doc comment on _match_check_lines.
_match_candidate_list::  .ds MATCH_MAX_TRIO_CANDIDATES  ;; window-table indices (0-79);
                                                          ;; exported for tests/run_rules.c
_match_candidate_count:: .db 0   ;; exported for tests/run_rules.c
_match_candidate_sel:   .db 0   ;; index into _match_candidate_list, during choice UI
_match_chosen_window:   .db 0   ;; window-table index finally resolved
_mctc_invalid:          .db 0   ;; scratch: current window has an empty/wrong-player cell
_mctc_allcats:          .db 0   ;; scratch: current window all-cats so far (1=yes)
_mcrw_o0:               .db 0   ;; scratch: chosen/geometry window's 3 board offsets
_mcrw_o1:               .db 0
_mcrw_o2:               .db 0
_mcrw_stride:           .db 0   ;; scratch: o1-o0, used only to classify orientation
_mcrw_is_diag:          .db 0   ;; 0 = h/v (use _mfwb_*/bbox), 1 = diag (use _mfdc_*)
_mtcu_blink_on:         .db 0   ;; 1 = candidate frame currently drawn
_mtcu_blink_timer:      .db 0
_mtcu_confirmed:        .db 0   ;; Enter pressed
_mtcu_esc_resumed:      .db 0   ;; ESC opened+closed the abandon dialog without abandoning

_match_trio_choice_key_actions:
   .dw Key_CursorLeft,  _mtcu_key_left
   .dw Key_CursorRight, _mtcu_key_right
   .dw Key_CursorUp,    _mtcu_key_left    ;; Up/Down double as Left/Right —
   .dw Key_CursorDown,  _mtcu_key_right   ;; candidates are a flat list, no 2D layout
   .dw Key_Return,      _mtcu_key_enter
   .dw Key_Esc,         _mtcu_key_esc
   .dw 0

_match_choose_trio_msg: .asciz "CHOOSE A TRIO"

.if BOOP_DEBUG_BUILD
_match_debug_key_was_down: .db 0   ;; debounce for the in-game D→fill-board trigger
.endif

;;
;; Boop animation buffers
;;
_boop_anim_before: .ds 36     ;; pre-boop board snapshot (36 cells)

;;
;; Temp state for _match_restore_cell (row-by-row grid restore)
;;
_mrc_src:  .dw 0              ;; current source row ptr (in _bg_grid data)
_mrc_dst:  .dw 0              ;; current dest row ptr (in screen memory)
_mrc_col:  .db 0              ;; saved col for piece redraw
_mrc_row:  .db 0              ;; saved row for piece redraw
_boop_transit_buf: .ds 16     ;; destinations in-transit: 8 × (offset byte, value byte)
_boop_transit_cnt: .db 0      ;; number of valid entries in _boop_transit_buf

_match_cancel_msg:  .asciz " ABANDON MATCH? (Y/N)"
_match_p1_wins_msg: .asciz "    PLAYER 1 WINS!"
_match_p2_wins_msg: .asciz "    PLAYER 2 WINS!"
_match_p1_turn_msg: .asciz "PLAYER 1 TURN"
_match_p2_turn_msg: .asciz "PLAYER 2 TURN"

;;
;; Direction table for boop: 8 (dr, dc) pairs (signed bytes, 0xFF = -1)
;;
_boop_dir_table:
   .db 0xFF, 0xFF   ;; (-1,-1)
   .db 0xFF, 0x00   ;; (-1, 0)
   .db 0xFF, 0x01   ;; (-1,+1)
   .db 0x00, 0xFF   ;;  (0,-1)
   .db 0x00, 0x01   ;;  (0,+1)
   .db 0x01, 0xFF   ;; (+1,-1)
   .db 0x01, 0x00   ;; (+1, 0)
   .db 0x01, 0x01   ;; (+1,+1)

;;
;; Lookup table: 16-bit pointers to big number sprites 0-9
;;
_big_num_ptrs:
   .dw _s_big_numbers_00
   .dw _s_big_numbers_01
   .dw _s_big_numbers_02
   .dw _s_big_numbers_03
   .dw _s_big_numbers_04
   .dw _s_big_numbers_05
   .dw _s_big_numbers_06
   .dw _s_big_numbers_07
   .dw _s_big_numbers_08
   .dw _s_big_numbers_09

;;
;; Lookup table: sprite pointers for board cell values 1-4
;;   index 0 (value 1) -> P1 cat
;;   index 1 (value 2) -> P1 kitten
;;   index 2 (value 3) -> P2 cat
;;   index 3 (value 4) -> P2 kitten
;;
_board_sprite_ptrs:
   .dw _s_cat_0
   .dw _s_catty_0
   .dw _s_cat_1      ;; P2 cat   — patched at init by man_match_init
   .dw _s_catty_1    ;; P2 catty — patched at init by man_match_init

;; P2 sprite tables indexed by AI level (0-3 → sprites 1-4)
_p2_cat_sprites:
   .dw _s_cat_1
   .dw _s_cat_2
   .dw _s_cat_3
   .dw _s_cat_4

_p2_catty_sprites:
   .dw _s_catty_1
   .dw _s_catty_2
   .dw _s_catty_3
   .dw _s_catty_4

;; Mutable P2 sprite pointers — set by man_match_init, used by HUD and cursor
_p2_cat_ptr:   .dw _s_cat_1
_p2_catty_ptr: .dw _s_catty_1

;; Every length-three window on the 6x6 board, expressed as board offsets.
;; Shared by the trio-candidate scan below and by ai.s (win detection,
;; simulated trio resolution, tactical threat search) — one authoritative
;; copy of the board's window geometry instead of three.
_match_threat_windows::
   ;; Horizontal (24)
   .db 0,1,2, 1,2,3, 2,3,4, 3,4,5
   .db 6,7,8, 7,8,9, 8,9,10, 9,10,11
   .db 12,13,14, 13,14,15, 14,15,16, 15,16,17
   .db 18,19,20, 19,20,21, 20,21,22, 21,22,23
   .db 24,25,26, 25,26,27, 26,27,28, 27,28,29
   .db 30,31,32, 31,32,33, 32,33,34, 33,34,35
   ;; Vertical (24)
   .db 0,6,12, 6,12,18, 12,18,24, 18,24,30
   .db 1,7,13, 7,13,19, 13,19,25, 19,25,31
   .db 2,8,14, 8,14,20, 14,20,26, 20,26,32
   .db 3,9,15, 9,15,21, 15,21,27, 21,27,33
   .db 4,10,16, 10,16,22, 16,22,28, 22,28,34
   .db 5,11,17, 11,17,23, 17,23,29, 23,29,35
   ;; Diagonal down-right (16)
   .db 0,7,14, 1,8,15, 2,9,16, 3,10,17
   .db 6,13,20, 7,14,21, 8,15,22, 9,16,23
   .db 12,19,26, 13,20,27, 14,21,28, 15,22,29
   .db 18,25,32, 19,26,33, 20,27,34, 21,28,35
   ;; Diagonal down-left (16)
   .db 2,7,12, 3,8,13, 4,9,14, 5,10,15
   .db 8,13,18, 9,14,19, 10,15,20, 11,16,21
   .db 14,19,24, 15,20,25, 16,21,26, 17,22,27
   .db 20,25,30, 21,26,31, 22,27,32, 23,28,33

.if BOOP_DEBUG_BUILD
;; Debug preset: P1 has kittens at (0,1)-(0,2), (1,0)-(2,0), and (1,1)-(2,2)
;; — 6 on the board, 2 left in reserve. Placing a P1 kitten at (0,0)
;; simultaneously completes a horizontal trio ((0,0)-(0,1)-(0,2)), a
;; vertical trio ((0,0)-(1,0)-(2,0)), and a diagonal "\" trio
;; ((0,0)-(1,1)-(2,2)) — exercises the trio-choice UI with all three
;; orientations on the very first move. (0,2)-(1,1)-(2,0) also happens to
;; already be a complete diagonal "/" trio before that placement, which is
;; a deliberate bonus case: it checks that candidate collection finds
;; trios that don't involve the last-placed piece too.)
_match_debug_board_multitrio:
   .db 0,2,2,0,0,0
   .db 2,2,0,0,0,0
   .db 2,0,2,0,0,0
   .db 0,0,0,0,0,0
   .db 0,0,0,0,0,0
   .db 0,0,0,0,0,0
.endif

;;
;; Start of _CODE area
;;
.area _CODE

;;-----------------------------------------------------------------
;;
;; _match_init_player
;;
;;  Zeroes score and sets cats, kittens for one player struct
;;  Input:  HL = pointer to player struct
;;  Output:
;;  Modified: AF, IX
;;
_match_init_player:
   push hl
   pop ix                            ;; IX = player struct pointer (IX supports displacement)
   xor a
   ld Player_score+0(ix), a
   ld Player_score+1(ix), a
   ld Player_score+2(ix), a
   ld Player_score+3(ix), a
   ld a, #MATCH_INITIAL_CATS
   ld Player_cats(ix), a
   ld a, #MATCH_INITIAL_KITTENS
   ld Player_kittens(ix), a
   ret

;;-----------------------------------------------------------------
;;
;; _draw_big_digit
;;
;;  Draws a single big number sprite at the given screen address.
;;  Input:  A  = digit (0-9)
;;          DE = screen destination address
;;  Output:
;;  Modified: AF, BC, HL
;;
_draw_big_digit:
   push de                           ;; save dest while computing sprite ptr
   ld hl, #_big_num_ptrs
   ld b, #0
   ld c, a
   sla c                             ;; C = digit * 2 (each table entry = 2 bytes)
   rl b                              ;; carry into B (always 0 for digits 0-9)
   add hl, bc                        ;; HL = &_big_num_ptrs[digit * 2]
   ld c, (hl)
   inc hl
   ld b, (hl)                        ;; BC = sprite data pointer
   pop de                            ;; restore dest
   ld__ixl S_BIG_NUMBERS_W
   ld__ixh S_BIG_NUMBERS_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm
   ret

;;-----------------------------------------------------------------
;;
;; man_match_draw_hud
;;
;;  Draws cats and kittens counts for each player using big number sprites.
;;  Player 1 is drawn always; player 2 only when num_players == 2.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_match_draw_hud::
   ;; Restore basket + cat-icon background so old digits are erased cleanly
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 0, 50   ;; left basket
   ld c, #S_BASKET_W
   ld b, #S_BASKET_H
   ld hl, #_s_basket
   call cpct_drawSprite_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 62, 50  ;; right basket
   ld c, #S_BASKET_W
   ld b, #S_BASKET_H
   ld hl, #_s_basket
   call cpct_drawSprite_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 4, 68   ;; P1 cat
   ld bc, #_s_cat_0
   ld__ixl S_CAT_W
   ld__ixh S_CAT_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 9, 68   ;; P1 catty
   ld bc, #_s_catty_0
   ld__ixl S_CATTY_W
   ld__ixh S_CATTY_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 66, 68  ;; P2 cat
   ld hl, (_p2_cat_ptr)
   ld b, h
   ld c, l
   ld__ixl S_CAT_W
   ld__ixh S_CAT_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 71, 68  ;; P2 catty
   ld hl, (_p2_catty_ptr)
   ld b, h
   ld c, l
   ld__ixl S_CATTY_W
   ld__ixh S_CATTY_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   ;; --- Player 1 cats (below cat sprite) ---
   ld de, #CPCT_VMEM_START_ASM
   ld c, #HUD_P1_CATS_X
   ld b, #HUD_Y
   call cpct_getScreenPtr_asm
   ex de, hl                         ;; DE = screen address
   ld a, (man_match_player1 + Player_cats)
   call _draw_big_digit

   ;; --- Player 1 kittens (below catty sprite) ---
   ld de, #CPCT_VMEM_START_ASM
   ld c, #HUD_P1_KITTENS_X
   ld b, #HUD_Y
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (man_match_player1 + Player_kittens)
   call _draw_big_digit

   ;; --- Player 2 cats (below cat sprite) ---
   ld de, #CPCT_VMEM_START_ASM
   ld c, #HUD_P2_CATS_X
   ld b, #HUD_Y
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (man_match_player2 + Player_cats)
   call _draw_big_digit

   ;; --- Player 2 kittens (below catty sprite) ---
   ld de, #CPCT_VMEM_START_ASM
   ld c, #HUD_P2_KITTENS_X
   ld b, #HUD_Y
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (man_match_player2 + Player_kittens)
   call _draw_big_digit

   ret

;;-----------------------------------------------------------------
;;
;; _match_mark_cats_increased
;;
;;  Records that a player's cat reserve just grew, for
;;  _match_blink_cats_hud to pick up after the next HUD redraw.
;;  Input:  IX = &man_match_player1 or &man_match_player2
;;  Output: -
;;  Modified: AF, DE
;;
;;  HL is preserved: this is called from _mrl_process_trio_piece, which the
;;  three-in-a-row match handlers (_mcl_h_match/_mcl_v_match) call while
;;  HL still points at a board cell they're about to walk backwards
;;  through — see the V.054 HL-preservation note on _match_draw_cell_frame
;;  for what goes wrong if that pointer gets clobbered.
;;
_match_mark_cats_increased:
   ld a, (_match_simulation_mode)
   or a
   ret nz                           ;; simulated reserve changes must not touch HUD state
   push hl
   push ix
   pop hl                            ;; HL = IX
   ld de, #man_match_player1
   or a
   sbc hl, de
   jr nz, _mmci_p2
   ld a, #1
   ld (_cats_blink_p1), a
   jr _mmci_done
_mmci_p2:
   ld a, #1
   ld (_cats_blink_p2), a
_mmci_done:
   pop hl
   ret

;;-----------------------------------------------------------------
;;
;; _match_restore_cats_digit_backdrop
;;
;;  Restores the basket-art rectangle behind a player's "cats" HUD digit.
;;  That area is NOT flat black — S_BASKET_H=74 means the basket sprite
;;  (drawn at Y=HUD_BASKET_Y) bleeds all the way down under the digit row
;;  (Y=HUD_Y), so "erasing" the digit means copying that patch of _s_basket
;;  back, the same row-by-row technique _match_restore_cell uses for
;;  _bg_grid. Both players' cats digit sits at the same offset within
;;  their own basket (HUD_P1_CATS_X-HUD_BASKET_P1_X == HUD_P2_CATS_X-
;;  HUD_BASKET_P2_X == 5), so one routine covers both.
;;  Input:  A = 1 (P1) or 2 (P2)
;;          DE = digit screen address (as computed by _match_blink_cats_hud)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_restore_cats_digit_backdrop:
   ld (_mcdb_dst), de
   cp #2
   jr z, _mrcdb_p2
   ld hl, #(_s_basket + (HUD_Y - HUD_BASKET_Y) * S_BASKET_W + (HUD_P1_CATS_X - HUD_BASKET_P1_X))
   jr _mrcdb_go
_mrcdb_p2:
   ld hl, #(_s_basket + (HUD_Y - HUD_BASKET_Y) * S_BASKET_W + (HUD_P2_CATS_X - HUD_BASKET_P2_X))
_mrcdb_go:
   ld (_mcdb_src), hl

   ld b, #S_BIG_NUMBERS_H
_mrcdb_rowloop:
   ld hl, (_mcdb_src)
   ld de, (_mcdb_dst)
   ld c, #S_BIG_NUMBERS_W
_mrcdb_copy:
   ld a, (hl)
   ld (de), a
   inc hl
   inc de
   dec c
   jr nz, _mrcdb_copy

   ;; Source: skip remaining bytes to reach next basket row
   ld de, #(S_BASKET_W - S_BIG_NUMBERS_W)
   add hl, de
   ld (_mcdb_src), hl

   ;; Dest: advance one CPC pixel row (standard +0x800 with bank-crossing check)
   ld de, (_mcdb_dst)
   ld a, d
   add a, #0x08
   ld d, a
   and a, #0x38
   jr nz, _mrcdb_next
   ld a, e
   add a, #0x50
   ld e, a
   ld a, d
   adc a, #0xC0
   ld d, a
_mrcdb_next:
   ld (_mcdb_dst), de

   dec b
   jr nz, _mrcdb_rowloop
   ret

;;-----------------------------------------------------------------
;;
;; _match_blink_cats_hud
;;
;;  Blinks a player's "cats" HUD digit a few times so the player notices
;;  their reserve grew (kitten converted via a 3-in-a-row, or a cat
;;  ejected back off the board). "Off" restores the real basket-art
;;  backdrop (see _match_restore_cats_digit_backdrop); "on" redraws the
;;  real digit — both via the same masked/transparent routines the rest
;;  of the HUD uses, no solid-colour box involved.
;;  Input:  A = 1 (P1) or 2 (P2)
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX
;;
_match_blink_cats_hud:
   ld (_mbch_player), a
   cp #2
   jr z, _mbch_p2
   ld c, #HUD_P1_CATS_X
   ld a, (man_match_player1 + Player_cats)
   jr _mbch_go
_mbch_p2:
   ld c, #HUD_P2_CATS_X
   ld a, (man_match_player2 + Player_cats)
_mbch_go:
   ld (_mbch_digit), a
   ld b, #HUD_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl                         ;; DE = digit screen addr
   ld (_mbch_addr), de

   ld b, #4                          ;; 4 blink cycles
_mbch_loop:
   push bc

   ;; OFF: restore the real basket-art backdrop
   ld a, (_mbch_player)
   ld de, (_mbch_addr)
   call _match_restore_cats_digit_backdrop
   ld b, #10
   call sys_util_delay

   ;; ON: redraw the real digit
   ld de, (_mbch_addr)
   ld a, (_mbch_digit)
   call _draw_big_digit
   ld b, #10
   call sys_util_delay

   pop bc
   dec b
   jr nz, _mbch_loop
   ret

;;-----------------------------------------------------------------
;;
;; _match_col_row_to_screen_addr
;;
;;  Converts a grid (col, row) position to a video memory address.
;;  Input:  C = col (0 .. GRID_COLS-1)
;;          B = row (0 .. GRID_ROWS-1)
;;  Output: DE = screen address
;;  Modified: AF, BC, DE, HL
;;
_match_col_row_to_screen_addr:
   ;; Y = GRID_FIRST_CELL_Y + row * GRID_CELL_H  (row*24 = row*16 + row*8)
   ;; Computed first so we can use E as a temporary before DE is set for the call
   ld a, b
   add a, a                          ;; A = row * 2
   add a, a                          ;; A = row * 4
   add a, a                          ;; A = row * 8
   ld e, a                           ;; E = row * 8  (temp; DE overwritten below)
   add a, a                          ;; A = row * 16
   add a, e                          ;; A = row * 24
   add a, #GRID_FIRST_CELL_Y
   ld b, a                           ;; B = Y pixel row

   ;; X = GRID_FIRST_CELL_X + col * GRID_CELL_W  (col*7 = col*8 - col)
   ld a, c
   add a, a                          ;; A = col * 2
   add a, a                          ;; A = col * 4
   add a, a                          ;; A = col * 8
   sub c                             ;; A = col*8 - col = col * 7  (C still = col)
   add a, #GRID_FIRST_CELL_X
   ld c, a                           ;; C = X byte offset

   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm        ;; HL = screen address
   ex de, hl                         ;; DE = screen address
   ret

;;-----------------------------------------------------------------
;;
;; _match_draw_cell_frame
;;
;;  Outlines a cell with a rectangular frame (top/bottom/left/right edges)
;;  in the given color. Corners overlap by a couple of pixels where edges
;;  meet — harmless at this scale. Shared by the last-move marker and the
;;  three-in-a-row line-conversion flash.
;;
;;  Input:  B = row, C = col, A = colour pattern byte — B/C/HL preserved
;;  Output: -
;;  Modified: AF, DE
;;
_match_draw_cell_frame:
   ;; Both callers rely on B=row/C=col surviving this call — everything below
   ;; clobbers B/C freely (getScreenPtr's B=y/C=x, drawSolidBox's B=h/C=w), so
   ;; save/restore around it. Colour (A) is stashed too since it's clobbered
   ;; the same way. HL is also preserved: a past caller (see match.s history,
   ;; "V.054") called the sibling _match_draw_bbox_frame while HL still
   ;; pointed at a board cell it was about to read — silently corrupting
   ;; that pointer left the board data unmodified after a "cleared" line,
   ;; so it re-matched every following turn. Preserve HL here too so no
   ;; caller can hit that same trap.
   push hl
   push bc
   ld (_lmm_color), a

   ;; Cell origin: X (byte) = GRID_FIRST_CELL_X + col*7, Y (px) = GRID_FIRST_CELL_Y + row*24
   ;; Same formulas as _match_col_row_to_screen_addr, kept separate since we
   ;; need the raw X/Y pair (not a resolved screen address) for 4 edges.
   ld a, b
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, a                          ;; row*8
   ld l, a
   add a, a                          ;; row*16
   add a, l                          ;; row*24
   add a, #(GRID_FIRST_CELL_Y - 1)   ;; -1: nudge whole frame up 1px
   ld (_lmm_y), a

   ld a, c
   add a, a                          ;; col*2
   add a, a                          ;; col*4
   add a, a                          ;; col*8
   sub c                             ;; col*7
   add a, #GRID_FIRST_CELL_X
   ld (_lmm_x), a

   ;; Top edge: full cell width, 2px tall, at (x, y)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #2
   ld c, #GRID_CELL_W
   call cpct_drawSolidBox_asm

   ;; Bottom edge: full cell width, 2px tall, at (x, y + GRID_CELL_H - 2)
   ld a, (_lmm_y)
   add a, #(GRID_CELL_H - 2)
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #2
   ld c, #GRID_CELL_W
   call cpct_drawSolidBox_asm

   ;; Left edge: 1 byte wide, full cell height, at (x, y)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #GRID_CELL_H
   ld c, #1
   call cpct_drawSolidBox_asm

   ;; Right edge: 1 byte wide, full cell height, at (x + GRID_CELL_W - 1, y)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   add a, #(GRID_CELL_W - 1)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #GRID_CELL_H
   ld c, #1
   call cpct_drawSolidBox_asm

   pop bc
   pop hl
   ret

;;-----------------------------------------------------------------
;;
;; _match_draw_bbox_frame
;;
;;  Outlines a rectangular block of cells spanning from cell (B, C) with
;;  the given pixel size — used for the three-in-a-row line flash so all
;;  3 matched cells get ONE frame instead of 3 separate ones.
;;
;;  Input:  B = row, C = col (top-left cell of the box)
;;          D = box width in bytes (e.g. 3*GRID_CELL_W for a horizontal line)
;;          E = box height in px   (e.g. 3*GRID_CELL_H for a vertical line)
;;          A = colour pattern byte
;;  Output: -
;;  Modified: AF, DE
;;
_match_draw_bbox_frame:
   ;; HL is preserved (see _match_draw_cell_frame's comment on why this
   ;; matters) — cheap insurance for any caller that holds a live board
   ;; pointer in HL across this call.
   push hl
   push bc
   ld (_lmm_color), a
   ld a, d
   ld (_lmm_w), a
   ld a, e
   ld (_lmm_h), a

   ;; Box origin: same cell-origin formula as _match_draw_cell_frame
   ld a, b
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, a                          ;; row*8
   ld l, a
   add a, a                          ;; row*16
   add a, l                          ;; row*24
   add a, #(GRID_FIRST_CELL_Y - 1)   ;; -1: nudge up 1px, matches the last-move marker
   ld (_lmm_y), a

   ld a, c
   add a, a                          ;; col*2
   add a, a                          ;; col*4
   add a, a                          ;; col*8
   sub c                             ;; col*7
   add a, #GRID_FIRST_CELL_X
   ld (_lmm_x), a

   ;; Top edge: full box width, 2px tall, at (x, y)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #2
   push af                           ;; save colour across the (_lmm_w) load
   ld a, (_lmm_w)
   ld c, a
   pop af
   call cpct_drawSolidBox_asm

   ;; Bottom edge: full box width, 2px tall, at (x, y + h - 2)
   ld a, (_lmm_h)
   sub #2
   ld b, a
   ld a, (_lmm_y)
   add a, b
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   ld b, #2
   push af
   ld a, (_lmm_w)
   ld c, a
   pop af
   call cpct_drawSolidBox_asm

   ;; Left edge: 1 byte wide, full box height, at (x, y)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   push af
   ld a, (_lmm_h)
   ld b, a
   pop af
   ld c, #1
   call cpct_drawSolidBox_asm

   ;; Right edge: 1 byte wide, full box height, at (x + w - 1, y)
   ld a, (_lmm_w)
   dec a
   ld d, a                           ;; D = w-1 (temp; row/col already saved via push bc)
   ld a, (_lmm_y)
   ld b, a
   ld a, (_lmm_x)
   add a, d
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld a, (_lmm_color)
   push af
   ld a, (_lmm_h)
   ld b, a
   pop af
   ld c, #1
   call cpct_drawSolidBox_asm

   pop bc
   pop hl
   ret

;;-----------------------------------------------------------------
;;
;; _match_maybe_draw_last_move_marker
;;
;;  If (B, C) is the last-placed cell, draws the frame there in
;;  LAST_MOVE_COLOR. See _match_draw_cell_frame.
;;
;;  Input:  B = row, C = col (the cell about to be / just drawn) — preserved
;;  Output: -
;;  Modified: AF, DE (HL preserved — see _match_draw_cell_frame)
;;
_match_maybe_draw_last_move_marker:
   ld a, (_last_move_row)
   cp b
   ret nz
   ld a, (_last_move_col)
   cp c
   ret nz

   ld a, #LAST_MOVE_COLOR
   jp _match_draw_cell_frame         ;; tail call: preserves B/C, returns for us

;;-----------------------------------------------------------------
;;
;; _match_draw_cell_sprite
;;
;;  Draws the masked sprite for a given board cell value.
;;  Input:  A  = board value (1-4)
;;          DE = screen destination address
;;  Output:
;;  Modified: AF, BC, DE, HL, IX
;;
_match_draw_cell_sprite:
   push de                           ;; save screen address
   dec a                             ;; A = 0-3 (table index)
   ld hl, #_board_sprite_ptrs
   ld b, #0
   ld c, a
   sla c                             ;; C = index * 2
   rl b
   add hl, bc                        ;; HL = &_board_sprite_ptrs[index]
   ld c, (hl)
   inc hl
   ld b, (hl)                        ;; BC = sprite data pointer
   pop de                            ;; restore screen address
   ld__ixl S_CAT_W
   ld__ixh S_CAT_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm
   ret

;;-----------------------------------------------------------------
;;
;; _match_draw_board
;;
;;  Iterates all 6x6 cells and draws sprites for non-empty ones.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL, IX
;;
_match_draw_board:
   ld ix, #_match_board
   ld b, #0                          ;; B = row
_mdb_row_loop:
   ld c, #0                          ;; C = col
_mdb_col_loop:
   ld a, 0(ix)                       ;; A = cell value
   inc ix                            ;; advance board pointer
   or a
   jr z, _mdb_next_col               ;; skip empty cells

   push ix                           ;; save board pointer (clobbered by sprite draw)
   push bc                           ;; save row (B) and col (C)
   push af                           ;; save cell value
   call _match_maybe_draw_last_move_marker  ;; no-op unless (B,C) is the marked cell
   call _match_col_row_to_screen_addr ;; B=row, C=col -> DE = screen addr
   pop af                            ;; A = cell value
   inc de                            ;; shift sprite 1 byte (2px) right, same as cursor
   call _match_draw_cell_sprite
   pop bc                            ;; restore row/col
   pop ix                            ;; restore board pointer

_mdb_next_col:
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _mdb_col_loop

   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _mdb_row_loop

   ret

;;-----------------------------------------------------------------
;;
;; _match_draw_cursor
;;
;;  Draws the cursor: yellow solid box with current piece sprite on top.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL, IX
;;
_match_draw_cursor::
   ;; Compute screen address for cursor position
   ld a, (_cursor_col)
   ld c, a
   ld a, (_cursor_row)
   ld b, a
   call _match_col_row_to_screen_addr  ;; DE = screen addr
   inc de                              ;; shift cursor 1 byte (2px) right within cell

   ;; Draw yellow solid box (cursor background, slightly smaller than cell)
   ld a, #CURSOR_COLOR
   ld c, #CURSOR_W
   ld b, #CURSOR_H
   call cpct_drawSolidBox_asm          ;; DE is clobbered

   ;; Recompute screen address (cpct_drawSolidBox_asm modified DE)
   ld a, (_cursor_col)
   ld c, a
   ld a, (_cursor_row)
   ld b, a
   call _match_col_row_to_screen_addr  ;; DE = screen addr
   inc de                              ;; shift cursor 1 byte (2px) right within cell

   ;; Select sprite based on current player state and piece type
   ld a, (_match_state)
   or a
   jr nz, _mdc_p2

   ;; P1
   ld a, (_cursor_piece)
   or a
   jr nz, _mdc_p1_kitten
   ld bc, #_s_cat_0
   jr _mdc_draw_sprite
_mdc_p1_kitten:
   ld bc, #_s_catty_0
   jr _mdc_draw_sprite

_mdc_p2:
   ld a, (_cursor_piece)
   or a
   jr nz, _mdc_p2_kitten
   ld hl, (_p2_cat_ptr)
   ld b, h
   ld c, l
   jr _mdc_draw_sprite
_mdc_p2_kitten:
   ld hl, (_p2_catty_ptr)
   ld b, h
   ld c, l

_mdc_draw_sprite:
   ld__ixl S_CAT_W
   ld__ixh S_CAT_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm
   ret

;;-----------------------------------------------------------------
;;
;; _match_redraw_all
;;
;;  Full redraw: background, board pieces, cursor, HUD.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL, IX
;;
_match_redraw_all:
   call sys_render_draw_grid
   call _match_draw_board
   call _match_draw_cursor
   ret

;;-----------------------------------------------------------------
;;
;; _match_place_piece
;;
;;  Places the current player's selected piece at the cursor position.
;;  Does nothing if the cell is occupied or the player has no pieces left.
;;  On success: decrements piece count, toggles state, redraws.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL, IX
;;
_match_place_piece::
   ;; Compute board index = row*6 + col
   ld a, (_cursor_row)
   ld b, a                           ;; B = row
   rlca                              ;; A = row * 2
   rlca                              ;; A = row * 4
   add a, b                          ;; A = row * 5
   add a, b                          ;; A = row * 6
   ld b, a                           ;; B = row * 6
   ld a, (_cursor_col)
   add a, b                          ;; A = row*6 + col
   ld c, a
   ld b, #0

   ;; HL = &_match_board[idx]
   ld hl, #_match_board
   add hl, bc

   ;; Check cell is empty
   ld a, (hl)
   or a
   ret nz                            ;; occupied, do nothing

   ;; Load player struct into IX
   ld a, (_match_state)
   or a
   jr nz, _mpp_player2
   ld ix, #man_match_player1
   jr _mpp_got_player
_mpp_player2:
   ld ix, #man_match_player2

_mpp_got_player:
   ;; Check/decrement piece count; HL still points to board cell
   ld a, (_cursor_piece)
   or a
   jr nz, _mpp_check_kitten

   ;; CAT
   ld a, Player_cats(ix)
   or a
   ret z                             ;; no cats left
   dec a
   ld Player_cats(ix), a
   push hl
   push ix
   ld a, #SFX_CAT
   call sys_sound_play_sfx
   pop ix
   pop hl
   jr _mpp_do_place

_mpp_check_kitten:
   ;; KITTEN
   ld a, Player_kittens(ix)
   or a
   ret z                             ;; no kittens left
   dec a
   ld Player_kittens(ix), a
   push hl
   push ix
   ld a, #SFX_KITTEN
   call sys_sound_play_sfx
   pop ix
   pop hl

_mpp_do_place:
   ;; board_value = _match_state*2 + _cursor_piece + 1
   ;;   P1 cat=1, P1 kitten=2, P2 cat=3, P2 kitten=4
   ld a, (_match_state)
   add a, a                          ;; A = state * 2
   ld b, a
   ld a, (_cursor_piece)
   add a, b                          ;; A = state*2 + piece
   inc a                             ;; A = state*2 + piece + 1
   ld (hl), a                        ;; write to board

   ;; Remember this cell for the last-move marker (see _match_maybe_draw_last_move_marker)
   ld a, (_cursor_row)
   ld (_last_move_row), a
   ld a, (_cursor_col)
   ld (_last_move_col), a

   ;; Animate boop: frame0=placed, frame1=in-transit, frame2=destinations filled
   call _match_boop_animate
   xor a
   ld (_snd_lines_found), a
   call _match_check_lines           ;; check for 3 same-color pieces in a row
   ld a, (_match_cancelled)
   or a
   ret nz                            ;; abandoned mid trio-choice (_match_trio_choice_ui):
                                      ;; nothing below is safe to run against a torn-down match
   ld a, (_snd_lines_found)
   or a
   jr z, _mpp_no_line_sfx
   ld a, #SFX_LINE
   call sys_sound_play_sfx
_mpp_no_line_sfx:

   ;; Redraw final board state (line conversions visible), without cursor —
   ;; done BEFORE the win/elimination checks below so the win-line flash
   ;; (if any) draws over up-to-date board art.
   call sys_render_draw_grid
   call _match_draw_board
   call man_match_draw_hud

   ;; If either player's cat reserve grew this turn (kitten converted via a
   ;; 3-in-a-row, or a cat ejected back off the board), blink their "cats"
   ;; digit so they notice.
   ld a, (_cats_blink_p1)
   or a
   jr z, _mpp_no_blink_p1
   xor a
   ld (_cats_blink_p1), a
   ld a, #1
   call _match_blink_cats_hud
_mpp_no_blink_p1:
   ld a, (_cats_blink_p2)
   or a
   jr z, _mpp_no_blink_p2
   xor a
   ld (_cats_blink_p2), a
   ld a, #2
   call _match_blink_cats_hud
_mpp_no_blink_p2:

   ;; Check for a 3-cats win BEFORE the "no pieces left" elimination check
   ;; below: a move that completes a winning line and also happens to
   ;; empty the mover's reserve must count as a win for the mover, not an
   ;; elimination loss for them.
   call _match_check_cat_lines       ;; check 3 cats in a row → winner
   ld a, (_match_cancelled)
   or a
   ret nz                            ;; winner declared, done

   ;; After boop + line resolution: check if placing player has no pieces left
   ;; in reserve (boop may have ejected their own pieces back; lines may
   ;; have converted some). Per the real Boop rules: an empty reserve is
   ;; NOT a loss — it means all 8 of that player's pieces are on the
   ;; board. If all 8 are adult cats, that player WINS. Otherwise they
   ;; "graduate": one kitten comes off the board and becomes a cat in
   ;; their reserve, giving them something to place next turn.
   ld a, (_match_state)              ;; still = placing player (not yet toggled)
   or a
   jr nz, _mpp_pe_p2
   ld ix, #man_match_player1
   jr _mpp_pe_chk
_mpp_pe_p2:
   ld ix, #man_match_player2
_mpp_pe_chk:
   ld a, Player_cats(ix)
   or a
   jr nz, _mpp_pe_done
   ld a, Player_kittens(ix)
   or a
   jr nz, _mpp_pe_done                ;; still has something to place
   ld a, (_match_state)
   inc a                              ;; _match_state 0/1 → player number 1/2
   call _match_graduate_or_win
   ld a, (_match_cancelled)
   or a
   ret nz                             ;; win declared inside, done
_mpp_pe_done:

   ;; Toggle state, reset piece selection to kitten (or cat if no kittens left)
   ld a, (_match_state)
   xor #1
   ld (_match_state), a
   or a
   jr nz, _mpp_init_p2
   ld ix, #man_match_player1
   jr _mpp_init_piece
_mpp_init_p2:
   ld ix, #man_match_player2
_mpp_init_piece:
   ld a, #PIECE_KITTEN
   ld b, a
   ld a, Player_kittens(ix)
   or a
   jr nz, _mpp_init_done
   ld b, #PIECE_CAT                  ;; no kittens → default to cat
_mpp_init_done:
   ld a, b
   ld (_cursor_piece), a

   ;; Show turn message before cursor moves to next player's starting corner
   call _match_show_turn_message

   ;; Now move cursor to top corner for next player's turn
   ;; P1 -> top-left (col 0, row 0), P2 -> top-right (col 5, row 0)
   xor a
   ld (_cursor_row), a
   ld a, (_match_state)
   or a
   jr z, _mpp_cursor_p1
   ld a, #(GRID_COLS - 1)
_mpp_cursor_p1:
   ld (_cursor_col), a

   call _match_redraw_all
   call man_match_draw_hud
   ret

;;-----------------------------------------------------------------
;;
;; _match_graduate_or_win
;;
;;  Called when a player's reserve just hit 0 cats AND 0 kittens (all 8
;;  of their pieces are on the board). Scans the board for that player's
;;  first kitten:
;;   - found → "graduation": remove it from the board, add 1 cat to
;;     their reserve (so they have something to place next turn)
;;   - none found (all 8 on-board pieces are already cats) → they win
;;  Input:  A = 1 (P1) or 2 (P2)
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX (calls _match_declare_winner on a win —
;;            no return in that case, sets _match_cancelled)
;;
_match_graduate_or_win::  ;; exported for tests/run_rules.c
   ld (_mgow_player), a
   ld hl, #_match_board
   ld b, #36                          ;; cell counter
_mgow_scan:
   ld a, (hl)
   or a
   jr z, _mgow_next                   ;; empty cell
   ld c, a                            ;; C = board value at this cell
   ld a, (_mgow_player)
   cp #2
   ld a, c
   jr z, _mgow_p2
   cp #BOARD_P1_KITTEN
   jr z, _mgow_found_kitten
   jr _mgow_next
_mgow_p2:
   cp #BOARD_P2_KITTEN
   jr z, _mgow_found_kitten
_mgow_next:
   inc hl
   djnz _mgow_scan

   ;; No kitten found for this player anywhere on the board → all 8 of
   ;; their pieces are adult cats → they win.
   ld a, (_mgow_player)
   jp _match_declare_winner           ;; no return; sets _match_cancelled

_mgow_found_kitten:
   ;; HL points at this player's first kitten cell — graduate it.
   ld (hl), #BOARD_EMPTY
   ld a, (_mgow_player)
   cp #2
   jr z, _mgow_grad_p2
   ld ix, #man_match_player1
   jr _mgow_grad_inc
_mgow_grad_p2:
   ld ix, #man_match_player2
_mgow_grad_inc:
   inc Player_cats(ix)
   ld a, (_mgow_player)
   call _match_blink_cats_hud         ;; show it now — the main per-turn
                                       ;; redraw already ran earlier
   call _match_redraw_all
   call man_match_draw_hud
   ret

;;-----------------------------------------------------------------
;;
;; _match_restore_cell
;;
;;  Restores the grid background at a single cell position by copying
;;  the corresponding region from the _bg_grid sprite data row by row.
;;  Then redraws the piece sprite if the cell is non-empty.
;;  This is used when the cursor moves away from a cell, replacing the
;;  full _match_redraw_all call with a two-cell update.
;;
;;  Source offset in _bg_grid:
;;    sprite_x = 2 + col*7   (grid origin X=18; cell X=19+col*7; cursor +1 = 20+col*7; 20-18=2)
;;    sprite_y = 4 + row*24  (grid origin Y=20; cell Y=24+row*24; 24-20=4)
;;    row_stride = BG_GRID_W = 44
;;
;;  Input:  C = col (0..GRID_COLS-1), B = row (0..GRID_ROWS-1)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_restore_cell::
   ld a, c
   ld (_mrc_col), a
   ld a, b
   ld (_mrc_row), a

   ;; Compute sprite_y * BG_GRID_W (44):
   ;;   sprite_y = 4 + row*24  (row*24 = row*8 + row*16)
   ;;   The "+4" is NOT a cursor inset — it's the _bg_grid asset's own
   ;;   origin offset relative to the screen cell origin (see the sprite_x
   ;;   note below for the derivation). Full cell height/width is still
   ;;   used (no CURSOR_W/H narrowing) so margin art drawn by
   ;;   _match_draw_cell_frame/_match_draw_bbox_frame is erasable too.
   ld a, b              ;; A = row
   add a, a             ;; *2
   add a, a             ;; *4
   add a, a             ;; *8
   ld l, a              ;; L = row*8
   add a, a             ;; *16
   add a, l             ;; *24
   add a, #4            ;; sprite_y
   ld l, a
   ld h, #0             ;; HL = sprite_y
   ;; HL * 44 = HL*32 + HL*8 + HL*4:
   add hl, hl           ;; *2
   add hl, hl           ;; *4
   push hl              ;; [*4]
   add hl, hl           ;; *8
   push hl              ;; [*8, *4]
   add hl, hl           ;; *16
   add hl, hl           ;; *32
   pop de               ;; DE = *8
   add hl, de           ;; *40
   pop de               ;; DE = *4
   add hl, de           ;; *44

   ;; Add sprite_x = 1 + col*7  (col still in C). Derived from
   ;; sys_render_draw_grid (draws _bg_grid 1:1 at screen X=18,Y=20): cell
   ;; origin screen X = GRID_FIRST_CELL_X(19) + col*7, so its _bg_grid-local
   ;; X = (19+col*7) - 18 = 1 + col*7. (The old "+2" belonged to the narrow
   ;; CURSOR_W copy, which ALSO added a +1 dest shift — net effect "+2" only
   ;; matched once cell-origin dest no longer carries that +1.)
   ld a, c              ;; A = col
   add a, a             ;; *2
   add a, a             ;; *4
   add a, a             ;; *8
   sub c                ;; *7
   add a, #1            ;; sprite_x
   ld e, a
   ld d, #0
   add hl, de           ;; HL = sprite_y*44 + sprite_x
   ld de, #_bg_grid
   add hl, de           ;; HL = &_bg_grid[offset]
   ld (_mrc_src), hl

   ;; Compute dest screen address (B=row, C=col still valid) — cell origin,
   ;; no +1 byte shift (that shift is only for the inset cursor/piece art)
   call _match_col_row_to_screen_addr  ;; → DE
   ld (_mrc_dst), de

   ;; Copy GRID_CELL_W bytes per row, for GRID_CELL_H rows (the whole cell)
   ld b, #GRID_CELL_H
_mrc_rowloop:
   ld hl, (_mrc_src)
   ld de, (_mrc_dst)
   ld c, #GRID_CELL_W
_mrc_copy:
   ld a, (hl)
   ld (de), a
   inc hl
   inc de
   dec c
   jr nz, _mrc_copy

   ;; Source: skip remaining bytes to reach next row start (BG_GRID_W - GRID_CELL_W)
   ld de, #(BG_GRID_W - GRID_CELL_W)
   add hl, de
   ld (_mrc_src), hl

   ;; Dest: advance one CPC pixel row (standard +0x800 with bank-crossing check)
   ld de, (_mrc_dst)
   ld a, d
   add a, #0x08
   ld d, a
   and a, #0x38
   jr nz, _mrc_next
   ld a, e
   add a, #0x50
   ld e, a
   ld a, d
   adc a, #0xC0
   ld d, a
_mrc_next:
   ld (_mrc_dst), de

   dec b
   jr nz, _mrc_rowloop

   ;; Redraw piece if cell is non-empty
   ld a, (_mrc_row)
   ld b, a
   ld a, (_mrc_col)
   ld c, a
   call _match_maybe_draw_last_move_marker  ;; no-op unless (B,C) is the marked cell
   ld a, b              ;; row*6 + col
   add a, a             ;; *2
   ld e, a
   add a, a             ;; *4
   add a, e             ;; *6
   add a, c
   ld hl, #_match_board
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   or a
   ret z                ;; empty: done
   push af              ;; save board value
   call _match_col_row_to_screen_addr  ;; B=row, C=col → DE
   inc de
   pop af
   jp _match_draw_cell_sprite          ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_restore_cell_and_sliver
;;
;;  Same as _match_restore_cell, but also restores the 1px sliver directly
;;  above the cell (see _match_restore_top_sliver). Only needed by callers
;;  erasing something drawn with the -1px Y nudge (win/combo/selector box
;;  and diag frames, the last-move marker) — NOT a general replacement for
;;  _match_restore_cell: calling this on every plain cursor move repaints
;;  a scanline nothing ever touched there, which is harmless on paper but
;;  visibly glitches (confirmed empirically) — keep it scoped to those
;;  specific erase call sites only.
;;  Input:  B = row, C = col
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_restore_cell_and_sliver:
   push bc
   ld d, #GRID_CELL_W
   call _match_restore_top_sliver
   pop bc
   jp _match_restore_cell            ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_restore_top_sliver
;;
;;  _match_draw_bbox_frame/_match_draw_cell_frame nudge a frame's Y origin
;;  up 1px from the cell boundary (matches the last-move marker's look —
;;  see the "-1: nudge" comment on both). _match_restore_cell only ever
;;  restores a cell's own GRID_CELL_H-row span, so that extra pixel row
;;  above a frame's top edge is never touched when the frame is erased,
;;  leaving a 1px line behind. This restores exactly that missing row,
;;  using the same _bg_grid math as _match_restore_cell but with the
;;  source Y one row earlier (row*24+3 instead of +4).
;;  Input:  B = row, C = col, D = width in bytes
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_restore_top_sliver:
   ld a, b
   ld (_mrts_row), a
   ld a, c
   ld (_mrts_col), a
   ld a, d
   ld (_mrts_w), a

   ;; Source: &_bg_grid[(row*24+3)*44 + (col*7+1)]
   ld a, (_mrts_row)
   add a, a
   add a, a
   add a, a
   ld l, a
   add a, a
   add a, l
   add a, #3
   ld l, a
   ld h, #0             ;; HL = sprite_y
   ;; HL * 44 = HL*32 + HL*8 + HL*4 (same idiom as _match_restore_cell —
   ;; BUG FIX: this previously pushed after *2 and *4 instead of *4 and
   ;; *8, computing sprite_y*22 instead of *44 — read garbage from
   ;; _bg_grid, painting wrong-coloured pixels into the sliver row on
   ;; every single cell restore, including plain cursor movement)
   add hl, hl           ;; *2
   add hl, hl           ;; *4
   push hl              ;; [*4]
   add hl, hl           ;; *8
   push hl              ;; [*8, *4]
   add hl, hl           ;; *16
   add hl, hl           ;; *32
   pop de                ;; DE = *8
   add hl, de            ;; *40
   pop de                ;; DE = *4
   add hl, de            ;; *44

   ld a, (_mrts_col)
   ld c, a
   add a, a
   add a, a
   add a, a
   sub c
   add a, #1
   ld e, a
   ld d, #0
   add hl, de
   ld de, #_bg_grid
   add hl, de              ;; HL = source ptr

   ;; Dest: same Y formula the frame itself uses for its top edge
   ;; (GRID_FIRST_CELL_Y + row*24 - 1), so source and dest line up exactly.
   push hl
   ld a, (_mrts_row)
   add a, a                  ;; row*2
   add a, a                  ;; row*4
   add a, a                  ;; row*8
   ld e, a                   ;; E = row*8 (NOT row*4 — dropping this third
   add a, a                  ;; row*16    add left the total at row*12, which
   add a, e                  ;; row*24    put the sliver 12px above where it
   add a, #(GRID_FIRST_CELL_Y - 1)   ;;   belonged, painting the grid's dark
   ld b, a                           ;;   separator row into a neighbour cell)
   ld a, (_mrts_col)
   ld e, a
   add a, a
   add a, a
   add a, a
   sub e
   add a, #GRID_FIRST_CELL_X
   ld c, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   pop hl                    ;; HL = source, DE = dest

   ld a, (_mrts_w)
   ld b, a
_mrts_copy:
   ld a, (hl)
   ld (de), a
   inc hl
   inc de
   djnz _mrts_copy
   ret

;;-----------------------------------------------------------------
;; Match input action routines — called by sys_input_match_update
;;-----------------------------------------------------------------

;;  _match_check_cell_empty
;;  Input:  B=row, C=col
;;  Output: Z=1 if BOARD_EMPTY, NZ if occupied
;;  Modified: AF, DE, HL
_match_check_cell_empty:
   ld a, b
   add a, a     ;; row*2
   add a, a     ;; row*4
   add a, b     ;; row*5
   add a, b     ;; row*6
   add a, c     ;; row*6 + col
   ld hl, #_match_board
   ld d, #0
   ld e, a
   add hl, de
   ld a, (hl)
   or a
   ret

_match_input_up::
   ld a, (_cursor_row)
   or a
   ret z                             ;; already at top
   ld b, a                           ;; B = orig row (scan start)
   ld a, (_cursor_col)
   ld c, a
   push bc                           ;; save (orig_row, col) for restore
_miu_scan:
   ld a, b
   or a
   jr z, _miu_none                   ;; reached top with no empty cell
   dec b                             ;; candidate row
   call _match_check_cell_empty
   jr nz, _miu_scan                  ;; occupied: keep scanning
   ld a, b
   ld (_cursor_row), a               ;; commit
   pop bc                            ;; BC = (orig_row, col) for restore
   push bc
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop bc
   call _match_restore_cell
   jp _match_draw_cursor
_miu_none:
   pop bc
   ret

_match_input_down::
   ld a, (_cursor_row)
   cp #(GRID_ROWS - 1)
   ret z                             ;; already at bottom
   ld b, a
   ld a, (_cursor_col)
   ld c, a
   push bc
_mid_scan:
   ld a, b
   cp #(GRID_ROWS - 1)
   jr z, _mid_none
   inc b
   call _match_check_cell_empty
   jr nz, _mid_scan
   ld a, b
   ld (_cursor_row), a
   pop bc
   push bc
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop bc
   call _match_restore_cell
   jp _match_draw_cursor
_mid_none:
   pop bc
   ret

_match_input_left::
   ld a, (_cursor_col)
   or a
   ret z                             ;; already at left edge
   ld a, (_cursor_row)
   ld b, a
   ld a, (_cursor_col)
   ld c, a
   push bc
_mil_scan:
   ld a, c
   or a
   jr z, _mil_none
   dec c
   call _match_check_cell_empty
   jr nz, _mil_scan
   ld a, c
   ld (_cursor_col), a
   pop bc
   push bc
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop bc
   call _match_restore_cell
   jp _match_draw_cursor
_mil_none:
   pop bc
   ret

_match_input_right::
   ld a, (_cursor_col)
   cp #(GRID_COLS - 1)
   ret z                             ;; already at right edge
   ld a, (_cursor_row)
   ld b, a
   ld a, (_cursor_col)
   ld c, a
   push bc
_mir_scan:
   ld a, c
   cp #(GRID_COLS - 1)
   jr z, _mir_none
   inc c
   call _match_check_cell_empty
   jr nz, _mir_scan
   ld a, c
   ld (_cursor_col), a
   pop bc
   push bc
   ld a, #SFX_CURSOR
   call sys_sound_play_sfx
   pop bc
   call _match_restore_cell
   jp _match_draw_cursor
_mir_none:
   pop bc
   ret

_match_input_space::
   ld a, (_match_state)
   or a
   jr nz, _mis_p2
   ld ix, #man_match_player1
   jr _mis_check
_mis_p2:
   ld ix, #man_match_player2
_mis_check:
   ld a, (_cursor_piece)
   cp #PIECE_CAT
   jr z, _mis_chk_kitten
   ld a, Player_cats(ix)
   or a
   jr z, _mis_blocked
   jr _mis_do_toggle
_mis_chk_kitten:
   ld a, Player_kittens(ix)
   or a
   jr z, _mis_blocked
_mis_do_toggle:
   ld a, (_cursor_piece)
   xor #1
   ld (_cursor_piece), a
   jp _match_draw_cursor             ;; same cell, just redraw cursor with new piece
_mis_blocked:
   ld a, (_cursor_col)
   ld c, a
   ld a, (_cursor_row)
   ld b, a
   call _match_col_row_to_screen_addr
   inc de
   ld a, #BLOCKED_CURSOR_COLOR
   ld c, #CURSOR_W
   ld b, #CURSOR_H
   call cpct_drawSolidBox_asm
   ld b, #13
   call sys_util_delay
   jp _match_draw_cursor             ;; restore yellow cursor after red flash

_match_input_enter::
   jp _match_place_piece             ;; tail call

_match_input_esc::
   jp _match_confirm_cancel          ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_confirm_cancel
;;
;;  Shows "ABANDON MATCH? (Y/N)" dialog. Blocks until Y, N or Esc.
;;  On Y: sets _match_cancelled = 1.
;;  On N or Esc: restores screen and returns, match continues.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
_match_confirm_cancel:
   ;; Show dialog window (wait_for_key=0: no auto-wait; background saved in message_buffer)
   m_msg_w_background 14            ;; red interior for the dialog box
   ld e, #6
   ld d, #78                         ;; y position
   ld b, #35                        ;; height
   ld c, #44                         ;; width (auto-computed from text)
   ld a, #0                          ;; no auto-wait
   ld hl, #_match_cancel_msg
   call sys_messages_show            ;; IY = &_window_data; background saved

   ;; Wait for ESC key to be released before accepting new input
_mcc_wait_esc_release:
   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   or a
   jr nz, _mcc_wait_esc_release

   ;; Poll for Y, N, or Esc
_mcc_poll:
   ld hl, #Key_Y
   call cpct_isKeyPressed_asm
   or a
   jr nz, _mcc_yes

   ld hl, #Key_N
   call cpct_isKeyPressed_asm
   or a
   jr nz, _mcc_no

   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   or a
   jr nz, _mcc_no

   jr _mcc_poll

_mcc_yes:
   call sys_messages_restore_message_background
   ld a, #1
   ld (_match_cancelled), a
   ret

_mcc_no:
   call sys_messages_restore_message_background
   ret

;;-----------------------------------------------------------------
;;
;; _match_boop_animate
;;
;;  Animates the boop in 3 visual frames:
;;    Frame 0: piece placed, all others still at original positions (pre-boop)
;;    Frame 1: boop sources cleared, destinations empty (in-transit)
;;    Frame 2: pieces restored at boop destinations (post-boop)
;;  Reads _cursor_piece to dispatch kitten vs cat boop.
;;  Input:  _cursor_piece, _cursor_row, _cursor_col (board already updated with placed piece)
;;  Output: _match_board in post-boop state
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_match_boop_animate:
   ;; Frame 0: show piece placed, before any boop
   call _match_redraw_all
   ld b, #4
   call sys_util_delay

   ;; Save pre-boop board (before boop clears source cells)
   ld hl, #_match_board
   ld de, #_boop_anim_before
   ld bc, #36
   ldir

   ;; Execute boop (board → post-boop state)
   ld a, (_cursor_piece)
   or a
   jr z, _mba_cat
   call _match_boop
   jr _mba_after_boop
_mba_cat:
   call _match_boop_cat

_mba_after_boop:
   ;; Scan all 36 cells to find destinations:
   ;; destination = empty in pre-boop AND non-empty in post-boop board
   ;; Save each to transit buffer, then clear from board → intermediate state
   xor a
   ld (_boop_transit_cnt), a
   ld hl, #_boop_anim_before         ;; pre-boop snapshot
   ld de, #_match_board              ;; post-boop (current board)
   ld ix, #_boop_transit_buf
   ld b, #36                         ;; cell count
   ld c, #0                          ;; cell index (0..35)
_mba_scan:
   ld a, (hl)
   or a
   jr nz, _mba_scan_next             ;; was non-empty before → not a destination
   ld a, (de)
   or a
   jr z, _mba_scan_next              ;; still empty → not a destination
   ;; Found a destination: save offset + value, clear cell in board
   ld 0(ix), c                       ;; board offset
   ld 1(ix), a                       ;; piece value
   inc ix
   inc ix
   ld a, (_boop_transit_cnt)
   inc a
   ld (_boop_transit_cnt), a
   xor a
   ld (de), a                        ;; clear destination → intermediate state
_mba_scan_next:
   inc hl
   inc de
   inc c
   dec b
   jr nz, _mba_scan

   ;; Frame 1: show intermediate (sources gone, destinations not yet filled)
   call _match_redraw_all
   ld b, #3
   call sys_util_delay

   ;; Restore destinations → post-boop state
   ld a, (_boop_transit_cnt)
   or a
   ret z                             ;; nothing to restore (all ejected or no boop)
   ld b, a                           ;; loop counter
   ld ix, #_boop_transit_buf
_mba_restore:
   push bc                           ;; save B (loop counter) and C (unused)
   ld c, 0(ix)                       ;; board cell offset (0..35)
   ld b, #0
   ld hl, #_match_board
   add hl, bc                        ;; HL = &board[offset]
   ld a, 1(ix)                       ;; piece value
   ld (hl), a
   pop bc                            ;; restore loop counter in B
   inc ix
   inc ix
   dec b
   jr nz, _mba_restore
   ret

;;-----------------------------------------------------------------
;;
;; _match_boop
;;
;;  Called after placing a kitten at (_cursor_row, _cursor_col).
;;  For each of 8 neighbor directions: if the neighbor cell holds a
;;  kitten, it is pushed one cell further away (neighbor + delta).
;;  If the destination is off-grid the kitten is removed from the
;;  board and its owner's Player_kittens count is incremented.
;;  If the destination is occupied the kitten stays in place.
;;  Cats (BOARD_P1_CAT / BOARD_P2_CAT) are never affected.
;;  Input:  _cursor_row, _cursor_col = placed kitten position
;;  Output:
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_match_boop::
   ld iy, #_boop_dir_table
   ld b, #8                          ;; 8 directions to check

_mb_dir_loop:
   push bc                           ;; save loop counter

   ;; -- compute neighbor row: nr = cursor_row + dr --
   ld a, (_cursor_row)
   add a, 0(iy)
   jp m, _mb_next_dir                ;; nr < 0 → out of bounds
   ld d, a                           ;; D = nr
   cp #GRID_ROWS
   jp nc, _mb_next_dir               ;; nr >= 6 → out of bounds

   ;; -- compute neighbor col: nc = cursor_col + dc --
   ld a, (_cursor_col)
   add a, 1(iy)
   jp m, _mb_next_dir                ;; nc < 0 → out of bounds
   ld e, a                           ;; E = nc
   cp #GRID_COLS
   jr nc, _mb_next_dir               ;; nc >= 6 → out of bounds

   ;; -- look up board[nr][nc] (index = nr*6 + nc) --
   ld a, d
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, d                          ;; row*5
   add a, d                          ;; row*6
   add a, e
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc                        ;; HL = &board[nr][nc]

   ld a, (hl)
   cp #BOARD_P1_KITTEN
   jr z, _mb_is_kitten
   cp #BOARD_P2_KITTEN
   jr nz, _mb_next_dir               ;; not a kitten → nothing to push

_mb_is_kitten:
   ;; A = kitten value (2 or 4); HL = source cell; D=nr, E=nc
   push hl                           ;; save source cell ptr
   push af                           ;; save kitten board value

   ;; -- destination = neighbor + same delta (pushed away from placed kitten) --
   ld a, d
   add a, 0(iy)                      ;; dest_row = nr + dr
   ld d, a
   ld a, e
   add a, 1(iy)                      ;; dest_col = nc + dc
   ld e, a

   ;; -- destination bounds check --
   bit 7, d
   jr nz, _mb_dest_out               ;; dest_row negative
   ld a, d
   cp #GRID_ROWS
   jr nc, _mb_dest_out               ;; dest_row >= 6
   bit 7, e
   jr nz, _mb_dest_out               ;; dest_col negative
   ld a, e
   cp #GRID_COLS
   jr nc, _mb_dest_out               ;; dest_col >= 6

   ;; -- destination in bounds: check if empty --
   ld a, d
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, d                          ;; row*5
   add a, d                          ;; row*6
   add a, e
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc                        ;; HL = &board[dest_row][dest_col]

   ld a, (hl)
   or a
   jr nz, _mb_dest_blocked           ;; occupied → kitten stays

   ;; -- move kitten to empty destination --
   pop af
   ld (hl), a                        ;; write kitten to destination
   pop hl                            ;; source cell ptr
   ld (hl), #BOARD_EMPTY
   jr _mb_next_dir

_mb_dest_blocked:
   pop af                            ;; balance stack
   pop hl
   jr _mb_next_dir

_mb_dest_out:
   ;; kitten pushed off-grid: remove from board, return to owner's reserve
   pop af                            ;; kitten board value (2=P1, 4=P2)
   pop hl                            ;; source cell ptr
   ld (hl), #BOARD_EMPTY
   push af
   ld a, (_match_simulation_mode)
   or a
   jr nz, _mb_eject_sfx_done
   ld a, #SFX_EJECT
   call sys_sound_play_sfx
_mb_eject_sfx_done:
   pop af
   cp #BOARD_P2_KITTEN
   jr z, _mb_eject_p2
   ld ix, #man_match_player1
   inc Player_kittens(ix)
   jr _mb_next_dir

_mb_eject_p2:
   ld ix, #man_match_player2
   inc Player_kittens(ix)

_mb_next_dir:
   inc iy
   inc iy                            ;; advance past (dr, dc) pair
   pop bc                            ;; restore loop counter
   dec b
   jp nz, _mb_dir_loop
   ret

;;-----------------------------------------------------------------
;;
;; _match_boop_cat
;;
;;  Called after placing a cat at (_cursor_row, _cursor_col).
;;  For each of 8 neighbor directions: if the neighbor cell holds
;;  any piece (kitten or cat), it is pushed one cell further away.
;;  If the destination is off-grid the piece is removed from the
;;  board and returned to its owner's reserve (kittens or cats).
;;  If the destination is occupied the piece stays in place.
;;  Input:  _cursor_row, _cursor_col = placed cat position
;;  Output:
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_match_boop_cat::
   ld iy, #_boop_dir_table
   ld b, #8                          ;; 8 directions to check

_mbc_dir_loop:
   push bc                           ;; save loop counter

   ;; -- compute neighbor row: nr = cursor_row + dr --
   ld a, (_cursor_row)
   add a, 0(iy)
   jp m, _mbc_next_dir               ;; nr < 0 → out of bounds
   ld d, a                           ;; D = nr
   cp #GRID_ROWS
   jp nc, _mbc_next_dir              ;; nr >= 6 → out of bounds

   ;; -- compute neighbor col: nc = cursor_col + dc --
   ld a, (_cursor_col)
   add a, 1(iy)
   jp m, _mbc_next_dir               ;; nc < 0 → out of bounds
   ld e, a                           ;; E = nc
   cp #GRID_COLS
   jr nc, _mbc_next_dir              ;; nc >= 6 → out of bounds

   ;; -- look up board[nr][nc] --
   ld a, d
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, d                          ;; row*5
   add a, d                          ;; row*6
   add a, e
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc                        ;; HL = &board[nr][nc]

   ld a, (hl)
   or a
   jr z, _mbc_next_dir               ;; empty → nothing to push

_mbc_is_piece:
   ;; A = piece value (1-4); HL = source cell; D=nr, E=nc
   push hl                           ;; save source cell ptr
   push af                           ;; save piece board value

   ;; -- destination = neighbor + same delta --
   ld a, d
   add a, 0(iy)                      ;; dest_row = nr + dr
   ld d, a
   ld a, e
   add a, 1(iy)                      ;; dest_col = nc + dc
   ld e, a

   ;; -- destination bounds check --
   bit 7, d
   jr nz, _mbc_dest_out              ;; dest_row negative
   ld a, d
   cp #GRID_ROWS
   jr nc, _mbc_dest_out              ;; dest_row >= 6
   bit 7, e
   jr nz, _mbc_dest_out              ;; dest_col negative
   ld a, e
   cp #GRID_COLS
   jr nc, _mbc_dest_out              ;; dest_col >= 6

   ;; -- destination in bounds: check if empty --
   ld a, d
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, d                          ;; row*5
   add a, d                          ;; row*6
   add a, e
   ld hl, #_match_board
   ld c, a
   ld b, #0
   add hl, bc                        ;; HL = &board[dest_row][dest_col]

   ld a, (hl)
   or a
   jr nz, _mbc_dest_blocked          ;; occupied → piece stays

   ;; -- move piece to empty destination --
   pop af
   ld (hl), a                        ;; write piece to destination
   pop hl                            ;; source cell ptr
   ld (hl), #BOARD_EMPTY
   jr _mbc_next_dir

_mbc_dest_blocked:
   pop af                            ;; balance stack
   pop hl
   jr _mbc_next_dir

_mbc_dest_out:
   ;; piece pushed off-grid: remove from board, return to owner's reserve
   pop af                            ;; piece board value (1-4)
   pop hl                            ;; source cell ptr
   ld (hl), #BOARD_EMPTY
   push af
   ld a, (_match_simulation_mode)
   or a
   jr nz, _mbc_eject_sfx_done
   ld a, #SFX_EJECT
   call sys_sound_play_sfx
_mbc_eject_sfx_done:
   pop af
   ;; owner: values 1,2 = P1; values 3,4 = P2
   cp #3
   jr nc, _mbc_eject_p2
   ld ix, #man_match_player1
   jr _mbc_eject_inc
_mbc_eject_p2:
   ld ix, #man_match_player2
_mbc_eject_inc:
   ;; type: odd value = cat, even value = kitten
   bit 0, a
   jr z, _mbc_eject_kitten           ;; even → kitten
   inc Player_cats(ix)
   call _match_mark_cats_increased   ;; blink the HUD digit after the redraw
   jr _mbc_next_dir
_mbc_eject_kitten:
   inc Player_kittens(ix)

_mbc_next_dir:
   inc iy
   inc iy                            ;; advance past (dr, dc) pair
   pop bc                            ;; restore loop counter
   dec b
   jp nz, _mbc_dir_loop
   ret

;;-----------------------------------------------------------------
;;
;; _mrl_process_trio_piece
;;
;;  For a single board cell that's part of a resolved (non-winning) trio:
;;  clears it and awards the owner +1 cat, whether the cell held a cat or
;;  a kitten. Boop's real rule: a trio may mix cats and kittens of the
;;  same player (e.g. cat-kitten-cat); ALL three pieces come off the
;;  board, kittens graduate to cats, and cats simply return to reserve —
;;  same net effect either way, so this doesn't special-case the type.
;;  (An all-cats trio never reaches here — see the caller's skip check;
;;  that's a win-line, handled separately by _match_check_cat_lines.)
;;  Input:  HL = board cell pointer
;;          A  = cell value (must be non-zero)
;;  Output: -
;;  Modified: AF, IX (HL preserved — callers walk it cell-by-cell)
;;
_mrl_process_trio_piece:
   ld (hl), #BOARD_EMPTY
   cp #3
   jr nc, _mpk_p2                    ;; value 3 or 4 → P2 piece
   ld ix, #man_match_player1
   jr _mpk_add
_mpk_p2:
   ld ix, #man_match_player2
_mpk_add:
   inc Player_cats(ix)
   call _match_mark_cats_increased   ;; blink the HUD digit after the redraw
   ret

;;-----------------------------------------------------------------
;;
;; _match_is_inactive_piece
;;
;;  Per the real Boop rules, only the ACTIVE player (the one who just
;;  moved, per _match_state — NOT yet toggled when this is called) can
;;  win or graduate on their turn. If their move boops an opponent piece
;;  into a line of 3, that line just sits there until the opponent's own
;;  turn. So every trio/win scan must skip windows belonging to the
;;  other player.
;;  Input:  A = board cell value (nonzero: 1..4)
;;  Output: Carry SET if this piece belongs to the player who is NOT
;;          active this turn — caller should skip the window.
;;  Modified: F only; A preserved
;;
_match_is_inactive_piece:
   push bc
   ld b, a                           ;; B = piece value
   ld a, (_match_state)              ;; 0 = P1 active, 1 = P2 active
   or a
   jr nz, _miap_p2_active
   ld a, b
   cp #3
   jr nc, _miap_inactive             ;; A >= 3 (P2 piece) but P1 active
   jr _miap_active
_miap_p2_active:
   ld a, b
   cp #3
   jr c, _miap_inactive              ;; A < 3 (P1 piece) but P2 active
_miap_active:
   or a                              ;; clear carry
   ld a, b
   pop bc
   ret
_miap_inactive:
   scf                               ;; set carry
   ld a, b
   pop bc
   ret

;;-----------------------------------------------------------------
;;
;; _match_check_lines
;;
;;  After any placement + boop, finds every valid trio for the ACTIVE
;;  player (_match_state) — same player in all 3 cells (enforced by
;;  _match_is_inactive_piece), any mix of cats/kittens, excluding an
;;  all-cats window (that's a win-line, left for _match_check_cat_lines).
;;  If more than one candidate exists, the real rule says the player picks
;;  one (_match_trio_choice_ui); with 0 or 1 candidates it resolves
;;  directly, same as before. Only one trio ever resolves per turn — any
;;  other candidate is left on the board for that player's next turn.
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_match_check_lines::
   call _match_collect_trio_candidates
   ld a, (_match_candidate_count)
   or a
   ret z                              ;; nothing to do

   cp #2
   jr nc, _mcl_choice_flow            ;; 2+ candidates: ask the player

   ;; Exactly one candidate: resolve it directly, no banner/UI.
   ld a, (_match_candidate_list)
   ld (_match_chosen_window), a
   jp _match_resolve_window           ;; tail call

_mcl_choice_flow:
   ;; Hide the white last-move marker for the whole selection — it visually
   ;; clashes with the cyan selector frame while the player is choosing.
   ;; (_match_resolve_window also clears it, but only once a trio is
   ;; actually confirmed — too late to keep it off the screen during
   ;; the choice UI itself.)
   ld a, (_last_move_row)
   cp #0xFF
   jr z, _mcl_no_marker
   ld b, a
   ld a, (_last_move_col)
   ld c, a
   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a
   call _match_restore_cell_and_sliver ;; erase it (redraws the piece there too)
_mcl_no_marker:
   call _match_trio_choice_ui         ;; blocking; sets _match_chosen_window,
                                       ;; or _match_cancelled on abandon
   ld a, (_match_cancelled)
   or a
   ret nz                             ;; abandoned mid-selection: nothing resolved
   jp _match_resolve_window           ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_collect_trio_candidates
;;
;;  Scans all 80 windows (_match_threat_windows) and collects every one
;;  that's a valid trio for the active player: all 3 cells belong to
;;  _match_state's player (_match_is_inactive_piece), and at least one
;;  cell is a kitten (an all-cats window is a win-line, not a trio —
;;  left for _match_check_cat_lines). Never writes to _match_board, so
;;  candidates that share a cell (overlapping windows) are both detected
;;  against the same, unmutated board.
;;  Output: _match_candidate_list[0.._match_candidate_count-1] = window
;;          indices (0-79) of every valid candidate
;;  Modified: AF, BC, DE, HL, IY
;;
_match_collect_trio_candidates::  ;; exported for tests/run_rules.c
   xor a
   ld (_match_candidate_count), a
   ld iy, #_match_threat_windows
   ld b, #0                           ;; B = window index (0-79)
_mctc_window:
   xor a
   ld (_mctc_invalid), a
   ld a, #1
   ld (_mctc_allcats), a              ;; assume all-cats until a kitten shows up
   ld c, #3
_mctc_cell:
   ld e, 0(iy)
   inc iy
   ld d, #0
   ld hl, #_match_board
   add hl, de
   ld a, (hl)
   or a
   jr z, _mctc_cell_invalid           ;; empty
   call _match_is_inactive_piece      ;; preserves A; carry = wrong player
   jr c, _mctc_cell_invalid
   bit 0, a
   jr nz, _mctc_cell_done             ;; cat: "allcats" stays as-is
   xor a
   ld (_mctc_allcats), a              ;; kitten seen: not an all-cats window
   jr _mctc_cell_done
_mctc_cell_invalid:
   ld a, #1
   ld (_mctc_invalid), a
_mctc_cell_done:
   dec c
   jr nz, _mctc_cell

   ld a, (_mctc_invalid)
   or a
   jr nz, _mctc_next
   ld a, (_mctc_allcats)
   or a
   jr nz, _mctc_next                  ;; all cats: skip, win-check handles it

   ;; Valid trio candidate: append window index B (bounds-checked — should
   ;; be unreachable given MATCH_MAX_TRIO_CANDIDATES's proof, see match.h.s)
   ld a, (_match_candidate_count)
   cp #MATCH_MAX_TRIO_CANDIDATES
   jr nc, _mctc_next
   ld hl, #_match_candidate_list
   ld e, a
   ld d, #0
   add hl, de
   ld (hl), b
   ld a, (_match_candidate_count)
   inc a
   ld (_match_candidate_count), a

_mctc_next:
   inc b
   ld a, b
   cp #80
   jr nz, _mctc_window
   ret

;;-----------------------------------------------------------------
;;
;; _match_offset_to_rowcol
;;
;;  Input:  A = board offset (0-35)
;;  Output: B = row, C = col
;;  Modified: AF
;;
_match_offset_to_rowcol:
   ld c, a
   ld b, #0
_moto_loop:
   ld a, c
   cp #GRID_COLS
   ret c
   sub #GRID_COLS
   ld c, a
   inc b
   jr _moto_loop

;;-----------------------------------------------------------------
;;
;; _match_window_geometry
;;
;;  Decodes a window-table index into board offsets and screen geometry.
;;  Orientation is derived from the stride between offsets (o1-o0): +1 =
;;  horizontal, +6 = vertical, +7 = diag "\", +5 = diag "/" — this reads
;;  the window's actual shape rather than assuming the table's authoring
;;  order, so it stays correct even if _match_threat_windows is reordered.
;;  Input:  A = window index (0-79)
;;  Output: _mcrw_o0/o1/o2 = the window's 3 board offsets
;;          _mcrw_is_diag  = 0 (h/v: _mfwb_row/col/w/h/horiz populated,
;;                           for _match_flash_combo_box/_match_flash_win_box)
;;                           or 1 (diag: _mfdc_r0/c0/r1/c1/r2/c2 populated,
;;                           for _match_flash_combo_diag/_match_flash_win_diag)
;;  Modified: AF, BC, DE, HL
;;
_match_window_geometry:
   ;; HL = &_match_threat_windows + A*3
   ld l, a
   ld h, #0
   add hl, hl                         ;; *2
   ld d, h
   ld e, l
   ld l, a
   ld h, #0
   add hl, de                         ;; *3
   ld de, #_match_threat_windows
   add hl, de

   ld a, (hl)
   ld (_mcrw_o0), a
   ld b, a                            ;; B = o0, for the stride calc
   inc hl
   ld a, (hl)
   ld (_mcrw_o1), a
   sub b                              ;; A = o1 - o0 = stride
   ld (_mcrw_stride), a
   inc hl
   ld a, (hl)
   ld (_mcrw_o2), a

   ld a, (_mcrw_stride)
   cp #1
   jr z, _mwg_horiz
   cp #GRID_COLS
   jr z, _mwg_vert
   cp #7
   jr z, _mwg_diag1
   jr _mwg_diag2                      ;; stride == 5

_mwg_horiz:
   xor a
   ld (_mcrw_is_diag), a
   ld a, (_mcrw_o0)
   call _match_offset_to_rowcol       ;; B=row, C=col
   ld a, b
   ld (_mfwb_row), a
   ld a, c
   ld (_mfwb_col), a
   ld a, #(3 * GRID_CELL_W)
   ld (_mfwb_w), a
   ld a, #GRID_CELL_H
   ld (_mfwb_h), a
   ld a, #1
   ld (_mfwb_horiz), a
   ret

_mwg_vert:
   xor a
   ld (_mcrw_is_diag), a
   ld a, (_mcrw_o0)
   call _match_offset_to_rowcol
   ld a, b
   ld (_mfwb_row), a
   ld a, c
   ld (_mfwb_col), a
   ld a, #GRID_CELL_W
   ld (_mfwb_w), a
   ld a, #(3 * GRID_CELL_H)
   ld (_mfwb_h), a
   xor a
   ld (_mfwb_horiz), a
   ret

_mwg_diag1:                          ;; "\": (row,col),(row+1,col+1),(row+2,col+2)
   ld a, #1
   ld (_mcrw_is_diag), a
   ld a, (_mcrw_o0)
   call _match_offset_to_rowcol
   ld a, b
   ld (_mfdc_r0), a
   ld a, c
   ld (_mfdc_c0), a
   inc a
   ld (_mfdc_c1), a
   inc a
   ld (_mfdc_c2), a
   ld a, b
   inc a
   ld (_mfdc_r1), a
   inc a
   ld (_mfdc_r2), a
   ret

_mwg_diag2:                          ;; "/": (row,col),(row+1,col-1),(row+2,col-2)
   ld a, #1
   ld (_mcrw_is_diag), a
   ld a, (_mcrw_o0)
   call _match_offset_to_rowcol
   ld a, b
   ld (_mfdc_r0), a
   ld a, c
   ld (_mfdc_c0), a
   dec a
   ld (_mfdc_c1), a
   dec a
   ld (_mfdc_c2), a
   ld a, b
   inc a
   ld (_mfdc_r1), a
   inc a
   ld (_mfdc_r2), a
   ret

;;-----------------------------------------------------------------
;;
;; _match_resolve_window
;;
;;  Resolves the trio at window _match_chosen_window (0-79): flashes it,
;;  then clears its 3 cells and gives the owner +1 cat each — regardless
;;  of cat/kitten (_mrl_process_trio_piece already handles the mix). No
;;  live board HL is held across the flash call here (offsets are
;;  captured into scratch first, unlike the old sequential-scan code —
;;  see the V.054 history elsewhere in this file for what goes wrong when
;;  that isn't true), so no push hl/pop hl dance is needed.
;;  Input:  _match_chosen_window
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX
;;
_match_resolve_window:
   ld a, (_match_chosen_window)
   call _match_window_geometry

   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a

   ld a, (_mcrw_is_diag)
   or a
   jr nz, _mrw_diag_flash
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   ld a, (_mfwb_w)
   ld d, a
   ld a, (_mfwb_h)
   ld e, a
   call _match_flash_combo_box
   jr _mrw_flashed
_mrw_diag_flash:
   call _match_flash_combo_diag
_mrw_flashed:

   ld a, #1
   ld (_snd_lines_found), a

   ld a, (_mcrw_o0)
   ld e, a
   ld d, #0
   ld hl, #_match_board
   add hl, de
   ld a, (hl)
   call _mrl_process_trio_piece

   ld a, (_mcrw_o1)
   ld e, a
   ld d, #0
   ld hl, #_match_board
   add hl, de
   ld a, (hl)
   call _mrl_process_trio_piece

   ld a, (_mcrw_o2)
   ld e, a
   ld d, #0
   ld hl, #_match_board
   add hl, de
   ld a, (hl)
   call _mrl_process_trio_piece

   ret

;;-----------------------------------------------------------------
;;
;; _match_trio_choice_ui
;;
;;  Blocking selection UI for 2+ simultaneous trio candidates (real Boop
;;  rule: the player must pick one). Shows a "CHOOSE A TRIO" banner (auto-
;;  dismiss, same pattern as _match_show_turn_message), then blinks the
;;  first candidate and lets the player cycle with Left/Right and confirm
;;  with Enter. Esc opens the normal abandon dialog (_match_confirm_cancel)
;;  — same as during regular play.
;;  Input:  _match_candidate_list/_match_candidate_count (already filled)
;;  Output: _match_chosen_window set, or _match_cancelled=1 on abandon
;;  Modified: AF, BC, DE, HL, IX, IY
;;
_match_trio_choice_ui:
   m_msg_w_background 10             ;; pen 10 = Cyan (distinct from the
                                      ;; green selector frame and every
                                      ;; other message window's background)
   ld e, #6
   ld d, #78
   ld b, #22
   ld c, #50
   ld a, #2                           ;; auto-dismiss
   ld hl, #_match_choose_trio_msg
   call sys_messages_show

   xor a
   ld (_match_candidate_sel), a
   ld a, #1
   ld (_mtcu_blink_on), a
   xor a
   ld (_mtcu_blink_timer), a
   ld (_mtcu_confirmed), a
   ld (_mtcu_esc_resumed), a
   call _mtcu_draw_selected

_mtcu_loop:
   ld b, #2                           ;; poll every ~2 vsyncs
   call sys_util_delay
   ld iy, #_match_trio_choice_key_actions
   call sys_input_debounced_update

   ld a, (_match_cancelled)
   or a
   ret nz                             ;; abandoned: caller unwinds

   ld a, (_mtcu_esc_resumed)
   or a
   jr z, _mtcu_check_confirmed
   xor a
   ld (_mtcu_esc_resumed), a
   ld a, #1
   ld (_mtcu_blink_on), a
   xor a
   ld (_mtcu_blink_timer), a
   call _mtcu_draw_selected           ;; clean ON redraw after the dialog closes

_mtcu_check_confirmed:
   ld a, (_mtcu_confirmed)
   or a
   jr z, _mtcu_tick

   ld a, (_mtcu_blink_on)
   or a
   call nz, _mtcu_restore_selected    ;; don't leave a stray frame behind
   ld a, (_match_candidate_sel)
   ld hl, #_match_candidate_list
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   ld (_match_chosen_window), a
   ret

_mtcu_tick:
   ld hl, #_mtcu_blink_timer
   inc (hl)
   ld a, (hl)
   cp #3                              ;; ~3*2=6-frame half-cycle: clearly
   jr c, _mtcu_loop                   ;; faster than the resolve flash's 15
   xor a
   ld (_mtcu_blink_timer), a
   ld a, (_mtcu_blink_on)
   xor #1
   ld (_mtcu_blink_on), a
   or a
   jr z, _mtcu_off
   call _mtcu_draw_selected
   jr _mtcu_loop
_mtcu_off:
   call _mtcu_restore_selected
   jr _mtcu_loop

;; ON: draw the currently-selected candidate's frame
_mtcu_draw_selected:
   ld a, (_match_candidate_sel)
   ld hl, #_match_candidate_list
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   call _match_window_geometry
   ld a, (_mcrw_is_diag)
   or a
   jr nz, _mtds_diag
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   ld a, (_mfwb_w)
   ld d, a
   ld a, (_mfwb_h)
   ld e, a
   ld a, #TRIO_SELECT_COLOR
   jp _match_draw_bbox_frame          ;; tail call
_mtds_diag:
   ld a, #TRIO_SELECT_COLOR
   ld (_mfdc_color), a
   jp _mfdc_draw_on                   ;; tail call

;; OFF: restore the currently-selected candidate's 3 cells
_mtcu_restore_selected:
   ld a, (_match_candidate_sel)
   ld hl, #_match_candidate_list
   ld e, a
   ld d, #0
   add hl, de
   ld a, (hl)
   call _match_window_geometry
   ld a, (_mcrw_is_diag)
   or a
   jp z, _mfwb_restore_off            ;; tail call
   jp _mfdc_restore_off               ;; tail call

_mtcu_key_left:
   ld a, (_mtcu_blink_on)
   or a
   call nz, _mtcu_restore_selected
   ld a, (_match_candidate_sel)
   or a
   jr nz, _mtcu_kl_dec
   ld a, (_match_candidate_count)
_mtcu_kl_dec:
   dec a
   ld (_match_candidate_sel), a
   ld a, #1
   ld (_mtcu_blink_on), a
   xor a
   ld (_mtcu_blink_timer), a
   call _mtcu_draw_selected
   ret

_mtcu_key_right:
   ld a, (_mtcu_blink_on)
   or a
   call nz, _mtcu_restore_selected
   ld a, (_match_candidate_sel)
   inc a
   ld b, a                            ;; B = sel+1
   ld a, (_match_candidate_count)
   cp b
   jr z, _mtcu_kr_wrap                ;; count == sel+1 → wrap
   jr c, _mtcu_kr_wrap                ;; count < sel+1 → wrap (defensive)
   jr _mtcu_kr_ok
_mtcu_kr_wrap:
   ld b, #0
_mtcu_kr_ok:
   ld a, b
   ld (_match_candidate_sel), a
   ld a, #1
   ld (_mtcu_blink_on), a
   xor a
   ld (_mtcu_blink_timer), a
   call _mtcu_draw_selected
   ret

_mtcu_key_enter:
   ld a, #1
   ld (_mtcu_confirmed), a
   ret

_mtcu_key_esc:
   call _match_confirm_cancel
   ld a, (_match_cancelled)
   or a
   ret nz                             ;; abandoning: outer loop will see this
   ld a, #1
   ld (_mtcu_esc_resumed), a
   ret

;;-----------------------------------------------------------------
;;
;; _match_declare_winner
;;
;;  Shows "PLAYER X WINS!" window (waits for any key, restores bg)
;;  and sets _match_cancelled = 1 so the game loop returns to menu.
;;  Input:  A = winning player (1 = P1, 2 = P2)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_declare_winner::
   push af                           ;; save winner number for after fanfare call
   cp #2
   jr nz, _mdw_win_music             ;; P1 always gets the victory fanfare
   ld a, (man_match_num_players)
   cp #1
   jr nz, _mdw_win_music             ;; two humans: P2 also gets victory music
   call sys_sound_start_lose_music    ;; one player: P2 is the AI
   jr _mdw_music_ready
_mdw_win_music:
   call sys_sound_start_win_music
_mdw_music_ready:
   ;; Let the fanfare play once, then stop it — see WIN_MUSIC_FRAMES note.
   ld b, #WIN_MUSIC_FRAMES
   call sys_util_delay
   call sys_sound_stop
   pop af
   push af                           ;; save winner number (macro clobbers AF)
   m_msg_w_background 3
   ld e, #6
   ld d, #78
   ld b, #39                         ;; room for 9px PRESS ANY KEY + bottom padding
   ld c, #50
   pop af                            ;; restore winner number
   cp #2
   jr z, _mdw_p2
   ld a, #1
   ld hl, #_match_p1_wins_msg
   jr _mdw_show
_mdw_p2:
   ld a, #1
   ld hl, #_match_p2_wins_msg
_mdw_show:
   call sys_messages_show            ;; blocks until key pressed, restores bg
   ld a, #1
   ld (_match_cancelled), a          ;; signal game loop to return to menu
   ret

;;-----------------------------------------------------------------
;;
;; _match_show_turn_message
;;
;;  Shows "PLAYER X TURN" window (auto-dismisses after 2s,
;;  then auto-restores background). Orange bg for P1, blue for P2.
;;  Input:  _match_state (0=P1, 1=P2)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_show_turn_message:
   ld a, (_match_state)
   or a
   jr nz, _mstm_p2
   ;; P1: orange background
   m_msg_w_background 5
   ld b, #25                         ;; ~0.5 second delay before showing
   call sys_util_delay
   ld e, #6
   ld d, #78
   ld b, #22
   ld c, #50
   ld a, #2
   ld hl, #_match_p1_turn_msg
   jp sys_messages_show              ;; tail call: auto-dismisses after delay, restores bg
_mstm_p2:
   ;; P2: bright blue background
   m_msg_w_background 2
   ld b, #25                         ;; ~0.5 second delay before showing
   call sys_util_delay
   ld e, #6
   ld d, #78
   ld b, #22
   ld c, #50
   ld a, #2
   ld hl, #_match_p2_turn_msg
   jp sys_messages_show              ;; tail call: auto-dismisses after delay, restores bg

;;-----------------------------------------------------------------
;;
;; _match_flash_win_box
;;
;;  Blinks a yellow frame around the winning 3-cat line (3 short
;;  on/off cycles) before _match_declare_winner shows the "PLAYER X
;;  WINS!" banner and starts the victory music. Between blinks the box
;;  is restored via _match_restore_cell, which also redraws the cats
;;  underneath, so the line reads as flashing rather than disappearing.
;;
;;  Input:  B = row, C = col (top-left cell of the box)
;;          D = box width in bytes  (GRID_CELL_W or 3*GRID_CELL_W)
;;          E = box height in px    (GRID_CELL_H or 3*GRID_CELL_H)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_flash_win_box:
   ld a, b
   ld (_mfwb_row), a
   ld a, c
   ld (_mfwb_col), a
   ld a, d
   ld (_mfwb_w), a
   ld a, e
   ld (_mfwb_h), a
   ld a, #1                          ;; assume horizontal (width = 3 cells)
   ld (_mfwb_horiz), a
   ld a, d
   cp #GRID_CELL_W
   jr nz, _mfwb_orient_done          ;; width == 1 cell → vertical line
   xor a
   ld (_mfwb_horiz), a
_mfwb_orient_done:

   ld b, #2                          ;; 2 full on/off cycles, then a final
                                      ;; on-phase that stays lit (see below)
_mfwb_loop:
   push bc                           ;; save blink counter
   call _mfwb_draw_on
   ld b, #15
   call sys_util_delay
   call _mfwb_restore_off
   ld b, #15
   call sys_util_delay
   pop bc                            ;; restore blink counter
   dec b
   jr nz, _mfwb_loop

   ;; Final on-phase: leave the yellow frame visible so the winning line
   ;; stays highlighted under the "PLAYER X WINS!" banner.
   call _mfwb_draw_on
   ret

;; ON: draw the yellow frame over the 3-cell box
_mfwb_draw_on:
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   ld a, (_mfwb_w)
   ld d, a
   ld a, (_mfwb_h)
   ld e, a
   ld a, #WIN_FLASH_COLOR
   jp _match_draw_bbox_frame         ;; tail call

;; OFF: restore the 3 cells (redraws the cats too)
_mfwb_restore_off:
   ;; Each cell restore also needs the 1px sliver above it (see
   ;; _match_restore_cell_and_sliver) — this frame was drawn with the -1px
   ;; Y nudge, so erasing it must repaint that row too.
   ld a, (_mfwb_horiz)
   or a
   jr z, _mfwb_off_v

   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   inc a
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   add a, #2
   ld c, a
   jp _match_restore_cell_and_sliver ;; tail call

_mfwb_off_v:
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfwb_row)
   inc a
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfwb_row)
   add a, #2
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   jp _match_restore_cell_and_sliver ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_flash_combo_box
;;
;;  Blinks a yellow frame around a 3-in-a-row kitten conversion (2 on/off
;;  cycles), same visual language as _match_flash_win_box, but ends OFF
;;  (fully restored) since this doesn't end the match — only the winning
;;  combo stays permanently lit.
;;  Input:  B = row, C = col (top-left cell of the box)
;;          D = box width in bytes  (GRID_CELL_W or 3*GRID_CELL_W)
;;          E = box height in px    (GRID_CELL_H or 3*GRID_CELL_H)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_flash_combo_box:
   ld a, b
   ld (_mfwb_row), a
   ld a, c
   ld (_mfwb_col), a
   ld a, d
   ld (_mfwb_w), a
   ld a, e
   ld (_mfwb_h), a
   ld a, #1                          ;; assume horizontal (width = 3 cells)
   ld (_mfwb_horiz), a
   ld a, d
   cp #GRID_CELL_W
   jr nz, _mfcb_orient_done          ;; width == 1 cell → vertical line
   xor a
   ld (_mfwb_horiz), a
_mfcb_orient_done:

   ld b, #2                          ;; 2 on/off cycles
_mfcb_loop:
   push bc
   call _mfwb_draw_on
   ld b, #15
   call sys_util_delay
   call _mfwb_restore_off
   ld b, #15
   call sys_util_delay
   pop bc
   dec b
   jr nz, _mfcb_loop
   ret

;; ON: draw individual yellow frames on the 3 cells (_mfdc_r0/c0 etc, set
;; by the caller)
_mfdc_draw_on:
   ld a, (_mfdc_r0)
   ld b, a
   ld a, (_mfdc_c0)
   ld c, a
   ld a, (_mfdc_color)
   call _match_draw_cell_frame
   ld a, (_mfdc_r1)
   ld b, a
   ld a, (_mfdc_c1)
   ld c, a
   ld a, (_mfdc_color)
   call _match_draw_cell_frame
   ld a, (_mfdc_r2)
   ld b, a
   ld a, (_mfdc_c2)
   ld c, a
   ld a, (_mfdc_color)
   jp _match_draw_cell_frame         ;; tail call

;; OFF: restore the 3 cells (redraws the pieces too)
_mfdc_restore_off:
   ;; Each cell restore also needs the 1px sliver above it (see
   ;; _match_restore_cell_and_sliver) — this frame was drawn with the -1px
   ;; Y nudge, so erasing it must repaint that row too.
   ld a, (_mfdc_r0)
   ld b, a
   ld a, (_mfdc_c0)
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfdc_r1)
   ld b, a
   ld a, (_mfdc_c1)
   ld c, a
   call _match_restore_cell_and_sliver
   ld a, (_mfdc_r2)
   ld b, a
   ld a, (_mfdc_c2)
   ld c, a
   jp _match_restore_cell_and_sliver ;; tail call

;;-----------------------------------------------------------------
;;
;; _match_flash_combo_diag / _match_flash_win_diag
;;
;;  Diagonal counterparts of _match_flash_combo_box / _match_flash_win_box:
;;  _match_draw_bbox_frame only draws axis-aligned rectangles, so a
;;  diagonal 3-in-a-row flashes 3 individual cell frames instead (see
;;  _mfdc_draw_on/_mfdc_restore_off above). Same 2-cycle blink; combo ends
;;  erased, win ends lit. Caller must set _mfdc_r0/c0/r1/c1/r2/c2 first.
;;
;;  Input:  -  (cell coords + already set in _mfdc_* scratch)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_flash_combo_diag:
   ld a, #WIN_FLASH_COLOR
   ld (_mfdc_color), a
   ld b, #2
_mfcd_loop:
   push bc
   call _mfdc_draw_on
   ld b, #15
   call sys_util_delay
   call _mfdc_restore_off
   ld b, #15
   call sys_util_delay
   pop bc
   dec b
   jr nz, _mfcd_loop
   ret

_match_flash_win_diag:
   ld a, #WIN_FLASH_COLOR
   ld (_mfdc_color), a
   ld b, #2
_mfwd_loop:
   push bc
   call _mfdc_draw_on
   ld b, #15
   call sys_util_delay
   call _mfdc_restore_off
   ld b, #15
   call sys_util_delay
   pop bc
   dec b
   jr nz, _mfwd_loop

   ;; Final on-phase: leave the frames visible (matches _match_flash_win_box).
   call _mfdc_draw_on
   ret

;;-----------------------------------------------------------------
;;
;; _match_check_cat_lines
;;
;;  Scans every row/col/diagonal for 3 consecutive cats belonging to the
;;  ACTIVE player (per _match_state — see _match_is_inactive_piece) of
;;  the same colour. If found, that player wins via _match_declare_winner
;;  — since only the active player's cats are scanned, a match always
;;  means the active player won.
;;
;;  Horizontal windows: col 0..3 in each row (0..5)
;;  Vertical   windows: row 0..3 in each col (0..5)
;;  Diagonal windows:   "\" and "/", row/col window start per direction
;;
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_match_check_cat_lines:
   ;; === Horizontal scan ===
   ld b, #0                          ;; B = row (0..5)
_mccl_h_rowloop:
   ld c, #0                          ;; C = col window start (0..3)
_mccl_h_colloop:
   push bc

   ld a, b
   add a, a                          ;; row*2
   add a, a                          ;; row*4
   add a, b                          ;; row*5
   add a, b                          ;; row*6
   add a, c
   ld hl, #_match_board
   ld d, #0
   ld e, a
   add hl, de                        ;; HL = &board[row][col]

   ld a, (hl)
   ld d, a                           ;; D = v0
   ;; Only the active player's cats can win this turn — check against
   ;; their specific cat constant, not "either player".
   ld a, (_match_state)
   or a
   ld a, #BOARD_P1_CAT
   jr z, _mccl_h_cpsel
   ld a, #BOARD_P2_CAT
_mccl_h_cpsel:
   cp d
   jr nz, _mccl_h_next
   inc hl
   ld a, (hl)
   cp d
   jr nz, _mccl_h_next
   inc hl
   ld a, (hl)
   cp d
   jr nz, _mccl_h_next
   ;; Match: 3 cats in a row (always the active player's — see above)
   pop bc                             ;; B=row, C=col (leftmost cell)
   ld a, #0xFF                        ;; clear last-move marker — see the
   ld (_last_move_row), a             ;; note on _mcl_h_do_match
   ld (_last_move_col), a
   ld d, #(3 * GRID_CELL_W)
   ld e, #GRID_CELL_H
   call _match_flash_win_box
   ld a, (_match_state)
   inc a                              ;; 0/1 → winner 1/2
   jp _match_declare_winner          ;; no return; sets _match_cancelled
_mccl_h_next:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)
   jr c, _mccl_h_colloop
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _mccl_h_rowloop

   ;; === Vertical scan ===
   ld c, #0                          ;; C = col (0..5)
_mccl_v_colloop:
   ld b, #0                          ;; B = row window start (0..3)
_mccl_v_rowloop:
   push bc

   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld d, #0
   ld e, a
   add hl, de                        ;; HL = &board[row][col]

   ld a, (hl)
   ld d, a                           ;; D = v0
   ;; Only the active player's cats can win this turn.
   ld a, (_match_state)
   or a
   ld a, #BOARD_P1_CAT
   jr z, _mccl_v_cpsel
   ld a, #BOARD_P2_CAT
_mccl_v_cpsel:
   cp d
   jr nz, _mccl_v_next

   push hl                           ;; [ptr0, BC_outer]
   ld bc, #GRID_COLS
   add hl, bc                        ;; HL = ptr1
   ld a, (hl)
   cp d
   jr nz, _mccl_v_nm1
   push hl                           ;; [ptr1, ptr0, BC_outer]
   add hl, bc                        ;; HL = ptr2
   ld a, (hl)
   cp d
   jr nz, _mccl_v_nm2
   ;; Match (always the active player's — see above)
   pop hl                            ;; pop ptr1
   pop hl                            ;; pop ptr0
   pop bc                            ;; restore outer BC (B=row window start, C=col)
   ld a, #0xFF                       ;; clear last-move marker — see the
   ld (_last_move_row), a            ;; note on _mcl_h_do_match
   ld (_last_move_col), a
   ld d, #GRID_CELL_W
   ld e, #(3 * GRID_CELL_H)
   call _match_flash_win_box
   ld a, (_match_state)
   inc a                             ;; 0/1 → winner 1/2
   jp _match_declare_winner
_mccl_v_nm2:
   pop hl                            ;; pop ptr1
_mccl_v_nm1:
   pop hl                            ;; pop ptr0
_mccl_v_next:
   pop bc
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)
   jr c, _mccl_v_rowloop

   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _mccl_v_colloop

   ;; === Diagonal "\" scan (row+1, col+1): row/col window start 0..3 ===
   ld b, #0
_mccl_d1_rowloop:
   ld c, #0
_mccl_d1_colloop:
   push bc

   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld d, #0
   ld e, a
   add hl, de                        ;; HL = &board[row][col]

   ld a, (hl)
   ld d, a                           ;; D = v0
   ;; Only the active player's cats can win this turn.
   ld a, (_match_state)
   or a
   ld a, #BOARD_P1_CAT
   jr z, _mccl_d1_cpsel
   ld a, #BOARD_P2_CAT
_mccl_d1_cpsel:
   cp d
   jr nz, _mccl_d1_next

   push hl                           ;; [ptr0, BC_outer]
   ld bc, #7
   add hl, bc                        ;; HL = ptr1 (row+1,col+1)
   ld a, (hl)
   cp d
   jr nz, _mccl_d1_nm1
   push hl                           ;; [ptr1, ptr0, BC_outer]
   add hl, bc                        ;; HL = ptr2
   ld a, (hl)
   cp d
   jr nz, _mccl_d1_nm2
   ;; Match: 3 cats diagonally (always the active player's — see above)
   pop hl
   pop hl
   pop bc                            ;; B=row, C=col (top-left cell)
   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a
   ld a, b
   ld (_mfdc_r0), a
   ld a, c
   ld (_mfdc_c0), a
   inc a
   ld (_mfdc_c1), a
   inc a
   ld (_mfdc_c2), a
   ld a, b
   inc a
   ld (_mfdc_r1), a
   inc a
   ld (_mfdc_r2), a
   call _match_flash_win_diag
   ld a, (_match_state)
   inc a                             ;; 0/1 → winner 1/2
   jp _match_declare_winner
_mccl_d1_nm2:
   pop hl
_mccl_d1_nm1:
   pop hl
_mccl_d1_next:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)
   jr c, _mccl_d1_colloop
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)
   jr c, _mccl_d1_rowloop

   ;; === Diagonal "/" scan (row+1, col-1): row start 0..3, col start 2..5 ===
   ld b, #0
_mccl_d2_rowloop:
   ld c, #2
_mccl_d2_colloop:
   push bc

   ld a, b
   add a, a
   add a, a
   add a, b
   add a, b
   add a, c
   ld hl, #_match_board
   ld d, #0
   ld e, a
   add hl, de                        ;; HL = &board[row][col]

   ld a, (hl)
   ld d, a                           ;; D = v0
   ;; Only the active player's cats can win this turn.
   ld a, (_match_state)
   or a
   ld a, #BOARD_P1_CAT
   jr z, _mccl_d2_cpsel
   ld a, #BOARD_P2_CAT
_mccl_d2_cpsel:
   cp d
   jr nz, _mccl_d2_next

   push hl                           ;; [ptr0, BC_outer]
   ld bc, #5
   add hl, bc                        ;; HL = ptr1 (row+1,col-1)
   ld a, (hl)
   cp d
   jr nz, _mccl_d2_nm1
   push hl                           ;; [ptr1, ptr0, BC_outer]
   add hl, bc                        ;; HL = ptr2
   ld a, (hl)
   cp d
   jr nz, _mccl_d2_nm2
   ;; Match: 3 cats diagonally (always the active player's — see above)
   pop hl
   pop hl
   pop bc                            ;; B=row, C=col (top cell)
   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a
   ld a, b
   ld (_mfdc_r0), a
   ld a, c
   ld (_mfdc_c0), a
   dec a
   ld (_mfdc_c1), a
   dec a
   ld (_mfdc_c2), a
   ld a, b
   inc a
   ld (_mfdc_r1), a
   inc a
   ld (_mfdc_r2), a
   call _match_flash_win_diag
   ld a, (_match_state)
   inc a                             ;; 0/1 → winner 1/2
   jp _match_declare_winner
_mccl_d2_nm2:
   pop hl
_mccl_d2_nm1:
   pop hl
_mccl_d2_next:
   pop bc
   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _mccl_d2_colloop
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)
   jr c, _mccl_d2_rowloop

   ret

.if BOOP_DEBUG_BUILD
;;-----------------------------------------------------------------
;;
;; _match_debug_fill_board
;;
;;  Debug-only (see BOOP_DEBUG_BUILD, match.h.s). Loads
;;  _match_debug_board_multitrio into _match_board — usable at any point
;;  during a match, not just at the start — resets both players' reserves
;;  to match it (P1: 2 kittens left, 6 already on the board; P2: fresh
;;  8 kittens), resets the turn to P1 and the cursor to the top-left
;;  corner, then redraws everything. Triggered by man_match_update when
;;  Key_D is pressed (see _match_debug_key_was_down for the debounce).
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX
;;
_match_debug_fill_board:
   ld hl, #_match_debug_board_multitrio
   ld de, #_match_board
   ld bc, #36
   ldir

   ld a, #2
   ld (man_match_player1 + Player_kittens), a
   xor a
   ld (man_match_player1 + Player_cats), a
   ld a, #MATCH_INITIAL_KITTENS
   ld (man_match_player2 + Player_kittens), a
   xor a
   ld (man_match_player2 + Player_cats), a

   xor a
   ld (_match_state), a
   ld (_cursor_row), a
   ld (_cursor_col), a
   ld a, #PIECE_KITTEN
   ld (_cursor_piece), a

   call sys_render_draw_grid
   call _match_draw_board
   call man_match_draw_hud
   call _match_draw_cursor
   ret
.endif

;;-----------------------------------------------------------------
;;
;; man_match_init
;;
;;  Initializes the match: reads num_players from menu, resets
;;  player structs, clears board, initialises cursor and state,
;;  then draws the full screen.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_match_init::
   ;; store number of players from menu selection
   ld a, (man_menu_confirmed)        ;; 1 = ONE PLAYER, 2 = TWO PLAYERS
   ld (man_match_num_players), a

   ;; init player 1
   ld hl, #man_match_player1
   call _match_init_player

   ;; init player 2
   ld hl, #man_match_player2
   call _match_init_player

   ;; clear board (36 bytes) using ldir memset pattern
   ld hl, #_match_board
   ld de, #(_match_board + 1)
   ld bc, #35
   ld (hl), #BOARD_EMPTY
   ldir

.if BOOP_DEBUG_BUILD
   xor a
   ld (_match_debug_key_was_down), a  ;; fresh debounce state for this match
.endif

   ;; initialise cursor, turn state and cancel flag
   xor a
   ld (_match_cancelled), a
   ld (_match_state), a
   ld (_cursor_col), a
   ld (_cursor_row), a
   ld a, #PIECE_KITTEN               ;; start with kitten selected
   ld (_cursor_piece), a
   ld a, #0xFF                       ;; no last-move marker at match start
   ld (_last_move_row), a
   ld (_last_move_col), a
   xor a
   ld (_cats_blink_p1), a            ;; no pending cats-increased blink either
   ld (_cats_blink_p2), a
   ld (_match_simulation_mode), a
   ;; Set P2 sprite pointers: AI level for 1-player, default (level 0) for 2-player
   ld a, (man_match_num_players)
   cp #1
   jr nz, _mmi_p2_default
   ld a, (man_ai_level)           ;; 0-3
   jr _mmi_p2_set
_mmi_p2_default:
   xor a                          ;; treat as level 0 → _s_cat_1 / _s_catty_1
_mmi_p2_set:
   add a, a                       ;; A*2 (word table index)
   ld c, a
   ld b, #0
   ld hl, #_p2_cat_sprites
   add hl, bc
   ld e, (hl)
   inc hl
   ld d, (hl)
   ld (_p2_cat_ptr), de
   ld (_board_sprite_ptrs + 4), de
   ld hl, #_p2_catty_sprites
   add hl, bc
   ld e, (hl)
   inc hl
   ld d, (hl)
   ld (_p2_catty_ptr), de
   ld (_board_sprite_ptrs + 6), de

   ;; draw full screen: clear first (menu leaves hint text at Y=175/187), then static chrome
   call sys_util_fadeOut
   call sys_render_clear_buffer
   call sys_render_draw_screen
   call _match_redraw_all
   call man_match_draw_hud
   call sys_util_fadeIn
   ;; 1-player: initialise AI evaluation state for the first P2 turn
   ld a, (man_match_num_players)
   cp #1
   jr nz, _mmi_skip_ai
   call man_ai_init
_mmi_skip_ai:
   jp _match_show_turn_message       ;; tail call: announce Player 1 starts

;;-----------------------------------------------------------------
;;
;; man_match_update
;;
;;  Main match update, called every frame while playing.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_match_update::
.if BOOP_DEBUG_BUILD
   ;; Debug-only: press D at any point during a match to force-load the
   ;; test board (_match_debug_fill_board). Simple press-once debounce so
   ;; holding the key doesn't reload every frame.
   ld hl, #Key_D
   call cpct_isKeyPressed_asm
   or a
   jr z, _mmu_debug_key_up
   ld a, (_match_debug_key_was_down)
   or a
   jr nz, _mmu_debug_done             ;; still held from a previous frame
   ld a, #1
   ld (_match_debug_key_was_down), a
   call _match_debug_fill_board
   jr _mmu_debug_done
_mmu_debug_key_up:
   xor a
   ld (_match_debug_key_was_down), a
_mmu_debug_done:
.endif

   ;; 1-player mode: when it is P2's turn, delegate entirely to AI
   ld a, (man_match_num_players)
   cp #1
   jr nz, _mmu_human
   ld a, (_match_state)
   cp #MATCH_STATE_P2
   jr nz, _mmu_human
   call man_ai_update
   ret

_mmu_human:
   jp sys_input_match_update
