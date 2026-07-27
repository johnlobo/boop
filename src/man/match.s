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
_match_state:      .db 0 ;; MATCH_STATE_P1 or MATCH_STATE_P2
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
_mccl_v0:       .db 0   ;; winning piece value, stashed across the blink call

;; Set by _match_mark_cats_increased whenever a player's cat reserve grows
;; (kitten converted via a 3-in-a-row, or a cat ejected back off the
;; board); consumed once by _mpp_do_place right after the HUD redraw, which
;; blinks that player's "cats" digit via _match_blink_cats_hud.
_cats_blink_p1: .db 0
_cats_blink_p2: .db 0
_mbch_addr:     .dw 0   ;; scratch: digit screen address (_match_blink_cats_hud)
_mbch_digit:    .db 0   ;; scratch: digit value, across the delay calls
_mbch_player:   .db 0   ;; scratch: 1/2, needed again for the backdrop restore
_mcdb_src:      .dw 0   ;; scratch: basket source ptr (_match_restore_cats_digit_backdrop)
_mcdb_dst:      .dw 0   ;; scratch: screen dest ptr

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
;;  HL is preserved: this is called from _mrl_process_kitten, which the
;;  three-in-a-row match handlers (_mcl_h_match/_mcl_v_match) call while
;;  HL still points at a board cell they're about to walk backwards
;;  through — see the V.054 HL-preservation note on _match_draw_cell_frame
;;  for what goes wrong if that pointer gets clobbered.
;;
_match_mark_cats_increased:
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
   ;; the same way. HL is also preserved: _match_check_lines calls the
   ;; sibling _match_draw_bbox_frame while HL still points at a board cell
   ;; it's about to read — silently corrupting that pointer previously left
   ;; the board data unmodified after a "cleared" line, so it re-matched
   ;; every following turn. Preserve HL here too so no caller can hit that
   ;; same trap.
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
   ;; matters): _match_check_lines calls this while HL still points at a
   ;; board cell it's about to read/clear.
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
   ld a, (_snd_lines_found)
   or a
   jr z, _mpp_no_line_sfx
   ld a, #SFX_LINE
   call sys_sound_play_sfx
_mpp_no_line_sfx:

   ;; After boop + line resolution: check if placing player has no pieces left
   ;; (boop may have ejected their own pieces back; lines may have converted some)
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
   jr z, _mpp_pe_out                 ;; 0 cats and 0 kittens → opponent wins
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

   ;; Redraw final board state (line conversions visible), without cursor
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

   call _match_check_cat_lines       ;; check 3 cats in a row → winner
   ld a, (_match_cancelled)
   or a
   ret nz                            ;; winner declared, skip turn message

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

_mpp_pe_out:
   ;; Placing player is out of pieces after resolution → redraw, opponent wins
   call _match_redraw_all
   call man_match_draw_hud
   ld a, (_match_state)              ;; placing player: 0=P1, 1=P2
   xor #1
   inc a                             ;; winner: state=0→2(P2), state=1→1(P1)
   jp _match_declare_winner

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
   jr nc, _mb_next_dir               ;; nr >= 6 → out of bounds

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
   ld a, #SFX_EJECT
   call sys_sound_play_sfx
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
   ld a, #SFX_EJECT
   call sys_sound_play_sfx
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
;; _mrl_process_kitten
;;
;;  For a single board cell: if it holds a kitten (even value),
;;  clears it and gives the owner +1 cat. If it holds a cat (odd),
;;  does nothing (cats remain in place).
;;  Input:  HL = board cell pointer
;;          A  = cell value (must be non-zero)
;;  Output: -
;;  Modified: AF, IX (HL preserved — callers walk it cell-by-cell)
;;
_mrl_process_kitten:
   bit 0, a                          ;; odd = cat → nothing to do
   ret nz
   ;; even = kitten: clear cell and award 1 cat to owner
   ld (hl), #BOARD_EMPTY
   cp #BOARD_P2_KITTEN
   jr z, _mpk_p2
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
;; _match_check_lines
;;
;;  After any placement + boop, scans every row and column for 3
;;  consecutive same-colour pieces (any mix of cats and kittens of
;;  the same player). For each match:
;;    - kittens are removed from the board; owner gets +1 cat each
;;    - cats are left in place
;;  Both players are checked. Called for both kitten and cat placement.
;;
;;  Horizontal windows: col 0..3 in each row (0..5)
;;  Vertical   windows: row 0..3 in each col (0..5)
;;
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL, IX
;;
_match_check_lines::
   ;; === Horizontal scan ===
   ld b, #0                          ;; B = row (0..5)
_mcl_h_rowloop:
   ld c, #0                          ;; C = col window start (0..3)
_mcl_h_colloop:
   push bc                           ;; save row/col

   ;; Compute HL = &board[row][col]
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
   or a
   jp z, _mcl_h_next                 ;; empty → skip
   ld d, a                           ;; D = v0

   ;; Boop's real rule: a trio must be the SAME PLAYER *and* SAME SIZE
   ;; (three matching kittens, or three matching cats) — mixed sizes do
   ;; nothing, even if same-coloured. So require v1 == v0 and v2 == v0
   ;; exactly, not just "same player, any size".
   inc hl
   ld a, (hl)
   cp d
   jp nz, _mcl_h_next                 ;; v1 != v0 → mismatch
   inc hl
   ld a, (hl)
   cp d
   jp nz, _mcl_h_next                 ;; v2 != v0 → mismatch

_mcl_h_match:
   ;; HL = ptr+2, A = v2 (== v1 == v0), D = v0; process each cell

   ;; A same-size trio of CATS is a win-line, not a conversion — leave it
   ;; to _match_check_cat_lines (run later, after the final board redraw)
   ;; instead of firing the cyan line-conversion flash here for a window
   ;; with nothing to convert, ahead of (and visually competing with) the
   ;; real yellow win flash.
   bit 0, d                          ;; v0 (== v1 == v2) odd → all 3 cats
   jp nz, _mcl_h_next                ;; skip — win-check handles it

_mcl_h_do_match:
   ;; Yellow flash for this conversion (same colour as the win flash, but
   ;; ends erased — only the game-ending combo stays lit). Clear the
   ;; last-move marker first so its white frame doesn't reappear (in
   ;; _match_restore_cell's redraw) during the flash's off-phase.
   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a
   push hl                           ;; preserve v2 ptr — _match_flash_combo_box
                                      ;; (via _match_restore_cell) clobbers HL
   ld d, #(3 * GRID_CELL_W)
   ld e, #GRID_CELL_H
   call _match_flash_combo_box
   pop hl

   ld a, #1
   ld (_snd_lines_found), a

   ld a, (hl)                        ;; reload v2 (A was clobbered by store above)
   call _mrl_process_kitten          ;; v2
   dec hl
   ld a, (hl)
   call _mrl_process_kitten          ;; v1
   dec hl
   ld a, (hl)
   call _mrl_process_kitten          ;; v0
_mcl_h_next:
   pop bc
   inc c
   ld a, c
   cp #(GRID_COLS - 2)
   jp c, _mcl_h_colloop
   inc b
   ld a, b
   cp #GRID_ROWS
   jp c, _mcl_h_rowloop

   ;; === Vertical scan ===
   ld c, #0                          ;; C = col (0..5)
_mcl_v_colloop:
   ld b, #0                          ;; B = row window start (0..3)
_mcl_v_rowloop:
   push bc                           ;; save row/col

   ;; Compute HL = &board[row][col]
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
   or a
   jp z, _mcl_v_next                 ;; empty → skip
   ld d, a                           ;; D = v0

   ;; Boop's real rule: a trio must be the SAME PLAYER *and* SAME SIZE —
   ;; see the matching note on the horizontal scan above. Require v1 == v0
   ;; and v2 == v0 exactly.
   ;; BUG FIX: this used to do `ld de, #GRID_COLS` here as a 16-bit stride
   ;; for `add hl, de` — but D is v0! Loading DE clobbers D to 0 (GRID_COLS'
   ;; high byte), so the `cp d` below compared v1/v2 against 0, not v0. Since
   ;; empty cells ARE 0, any empty v1/v2 "matched" trivially — placing the
   ;; very first kitten anywhere always false-matched a vertical trio with
   ;; the two empty cells below it. Fix: step HL by GRID_COLS via six
   ;; `inc hl`, never touching D.
   push hl                           ;; [ptr0, BC_outer]
   inc hl
   inc hl
   inc hl
   inc hl
   inc hl
   inc hl                             ;; HL = ptr1 (row stride = GRID_COLS)
   ld a, (hl)
   cp d
   jp nz, _mcl_v_nm1                  ;; v1 != v0 → mismatch
   push hl                           ;; [ptr1, ptr0, BC_outer]
   inc hl
   inc hl
   inc hl
   inc hl
   inc hl
   inc hl                             ;; HL = ptr2 (row stride = GRID_COLS)
   ld a, (hl)
   cp d
   jp nz, _mcl_v_nm2                  ;; v2 != v0 → mismatch

_mcl_v_match:
   ;; HL = ptr2 (== v1 == v0); stack = [ptr1, ptr0, BC_outer]

   ;; A same-size trio of CATS is a win-line, not a conversion — see the
   ;; matching note on _mcl_h_match.
   bit 0, d                          ;; v0 (== v1 == v2) odd → all 3 cats
   jp nz, _mcl_v_nm2                 ;; skip — win-check handles it, unwind like a mismatch

_mcl_v_do_match:
   ;; Yellow flash — see the matching note on _mcl_h_do_match.
   ld a, #0xFF
   ld (_last_move_row), a
   ld (_last_move_col), a
   push hl                           ;; preserve v2 ptr (see _mcl_h_do_match note)
   ld d, #GRID_CELL_W
   ld e, #(3 * GRID_CELL_H)
   call _match_flash_combo_box
   pop hl

   ld a, #1
   ld (_snd_lines_found), a

   ld a, (hl)                        ;; reload v2 (A clobbered by store above)
   call _mrl_process_kitten          ;; v2
   pop hl                            ;; HL = ptr1
   ld a, (hl)
   call _mrl_process_kitten          ;; v1
   pop hl                            ;; HL = ptr0
   ld a, (hl)
   call _mrl_process_kitten          ;; v0
   jr _mcl_v_next

_mcl_v_nm2:
   pop hl                            ;; pop ptr1
_mcl_v_nm1:
   pop hl                            ;; pop ptr0
_mcl_v_next:
   pop bc
   inc b
   ld a, b
   cp #(GRID_ROWS - 2)
   jp c, _mcl_v_rowloop

   inc c
   ld a, c
   cp #GRID_COLS
   jp c, _mcl_v_colloop

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
   ld b, #35
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
   ld a, (_mfwb_horiz)
   or a
   jr z, _mfwb_off_v

   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   inc a
   ld c, a
   call _match_restore_cell
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   add a, #2
   ld c, a
   jp _match_restore_cell            ;; tail call

_mfwb_off_v:
   ld a, (_mfwb_row)
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell
   ld a, (_mfwb_row)
   inc a
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   call _match_restore_cell
   ld a, (_mfwb_row)
   add a, #2
   ld b, a
   ld a, (_mfwb_col)
   ld c, a
   jp _match_restore_cell            ;; tail call

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

;;-----------------------------------------------------------------
;;
;; _match_check_cat_lines
;;
;;  Scans every row and column for 3 consecutive cats of the same
;;  colour. If found, calls _match_declare_winner for that player.
;;  BOARD_P1_CAT=1 (odd) → P1 wins; BOARD_P2_CAT=3 (odd) → P2 wins.
;;
;;  Horizontal windows: col 0..3 in each row (0..5)
;;  Vertical   windows: row 0..3 in each col (0..5)
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
   cp #BOARD_P1_CAT
   jr z, _mccl_h_chk
   cp #BOARD_P2_CAT
   jr nz, _mccl_h_next
_mccl_h_chk:
   inc hl
   ld a, (hl)
   cp d
   jr nz, _mccl_h_next
   inc hl
   ld a, (hl)
   cp d
   jr nz, _mccl_h_next
   ;; Match: 3 cats in a row
   pop bc                             ;; B=row, C=col (leftmost cell)
   ld a, #0xFF                        ;; clear last-move marker — see the
   ld (_last_move_row), a             ;; note on _mcl_h_do_match
   ld (_last_move_col), a
   ld a, d                            ;; stash v0 — _match_flash_win_box clobbers D
   ld (_mccl_v0), a
   ld d, #(3 * GRID_CELL_W)
   ld e, #GRID_CELL_H
   call _match_flash_win_box
   ld a, (_mccl_v0)
   cp #BOARD_P2_CAT
   ld a, #1
   jr nz, _mccl_declare
   ld a, #2
_mccl_declare:
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
   cp #BOARD_P1_CAT
   jr z, _mccl_v_chk
   cp #BOARD_P2_CAT
   jr nz, _mccl_v_next

_mccl_v_chk:
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
   ;; Match
   pop hl                            ;; pop ptr1
   pop hl                            ;; pop ptr0
   pop bc                            ;; restore outer BC (B=row window start, C=col)
   ld a, #0xFF                       ;; clear last-move marker — see the
   ld (_last_move_row), a            ;; note on _mcl_h_do_match
   ld (_last_move_col), a
   ld a, d                           ;; stash v0 — _match_flash_win_box clobbers D
   ld (_mccl_v0), a
   ld d, #GRID_CELL_W
   ld e, #(3 * GRID_CELL_H)
   call _match_flash_win_box
   ld a, (_mccl_v0)
   cp #BOARD_P2_CAT
   ld a, #1
   jr nz, _mccl_v_declare
   ld a, #2
_mccl_v_declare:
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

   ret

;;-----------------------------------------------------------------
;;
;; _match_check_no_pieces
;;
;;  Called after each placement. Checks whether the next player has
;;  no cats and no kittens in reserve. If so, the opposite player
;;  wins via _match_declare_winner.
;;  Input:  _match_state = next player (0=P1, 1=P2, already toggled)
;;  Output: -
;;  Modified: AF, IX
;;
_match_check_no_pieces:
   ld a, (_match_state)
   or a
   jr nz, _mcnp_p2
   ld ix, #man_match_player1
   jr _mcnp_chk
_mcnp_p2:
   ld ix, #man_match_player2
_mcnp_chk:
   ld a, Player_cats(ix)
   or a
   ret nz                            ;; still has cats
   ld a, Player_kittens(ix)
   or a
   ret nz                            ;; still has kittens

   ;; state=0 (P1 out) → P2 wins; state=1 (P2 out) → P1 wins
   ;; winner = (state XOR 1) + 1: state=0→2, state=1→1
   ld a, (_match_state)
   xor #1
   inc a
   jp _match_declare_winner

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
