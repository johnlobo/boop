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
.include "cpctelera.h.s"
.include "../common.h.s"
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
_match_board: .ds 36

;;
;; Turn / cursor state
;;
_match_cancelled:: .db 0 ;; set to 1 when player confirms ESC → abandon match
_match_state:      .db 0 ;; MATCH_STATE_P1 or MATCH_STATE_P2
_cursor_col:    .db 0   ;; 0 .. GRID_COLS-1
_cursor_row:    .db 0   ;; 0 .. GRID_ROWS-1
_cursor_piece:  .db 0   ;; PIECE_CAT or PIECE_KITTEN
_turn_debounce: .db 0   ;; 1 while a key is held (same pattern as menu.s)

;;
;; Boop animation buffers
;;
_boop_anim_before: .ds 36     ;; pre-boop board snapshot (36 cells)
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
   .dw _s_cat_1
   .dw _s_catty_1

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
   ld bc, #_s_cat_1
   ld__ixl S_CAT_W
   ld__ixh S_CAT_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 71, 68  ;; P2 catty
   ld bc, #_s_catty_1
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
_match_draw_cursor:
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
   ld bc, #_s_cat_1
   jr _mdc_draw_sprite
_mdc_p2_kitten:
   ld bc, #_s_catty_1

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
_match_place_piece:
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
   jr _mpp_do_place

_mpp_check_kitten:
   ;; KITTEN
   ld a, Player_kittens(ix)
   or a
   ret z                             ;; no kittens left
   dec a
   ld Player_kittens(ix), a

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

   ;; Animate boop: frame0=placed, frame1=in-transit, frame2=destinations filled
   call _match_boop_animate
   call _match_check_lines           ;; check for 3 same-color pieces in a row

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
;; _match_handle_input
;;
;;  Reads directional keys, Space, and Enter each frame.
;;  Identical debounce pattern to menu.s.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
_match_handle_input:
   ;; Debounce: wait for full key release before accepting new input
   ld a, (_turn_debounce)
   or a
   jr z, _mhi_check_keys
   call cpct_isAnyKeyPressed_asm
   or a
   ret nz                            ;; key still held, do nothing
   xor a
   ld (_turn_debounce), a
   ret

_mhi_check_keys:
   ;; Cursor Up
   ld hl, #Key_CursorUp
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_down
   ld a, (_cursor_row)
   or a
   jr z, _mhi_check_down             ;; already at row 0
   dec a
   ld (_cursor_row), a
   call _match_redraw_all
   jp _mhi_set_debounce

_mhi_check_down:
   ld hl, #Key_CursorDown
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_left
   ld a, (_cursor_row)
   cp #(GRID_ROWS - 1)
   jr z, _mhi_check_left             ;; already at last row
   inc a
   ld (_cursor_row), a
   call _match_redraw_all
   jp _mhi_set_debounce

_mhi_check_left:
   ld hl, #Key_CursorLeft
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_right
   ld a, (_cursor_col)
   or a
   jr z, _mhi_check_right            ;; already at col 0
   dec a
   ld (_cursor_col), a
   call _match_redraw_all
   jp _mhi_set_debounce

_mhi_check_right:
   ld hl, #Key_CursorRight
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_space
   ld a, (_cursor_col)
   cp #(GRID_COLS - 1)
   jr z, _mhi_check_space            ;; already at last col
   inc a
   ld (_cursor_col), a
   call _match_redraw_all
   jr _mhi_set_debounce

_mhi_check_space:
   ld hl, #Key_Space
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_enter
   ;; Determine current player struct
   ld a, (_match_state)
   or a
   jr nz, _mhi_sp_p2
   ld ix, #man_match_player1
   jr _mhi_sp_check
_mhi_sp_p2:
   ld ix, #man_match_player2
_mhi_sp_check:
   ;; Check whether the target piece type has pieces available
   ld a, (_cursor_piece)
   cp #PIECE_CAT                     ;; currently on CAT?
   jr z, _mhi_sp_chk_kitten          ;; yes → trying to switch to KITTEN, check kittens
   ;; currently on KITTEN → trying to switch to CAT
   ld a, Player_cats(ix)
   or a
   jr z, _mhi_sp_blocked             ;; 0 cats → flash red and block
   jr _mhi_sp_do_toggle
_mhi_sp_chk_kitten:
   ld a, Player_kittens(ix)
   or a
   jr z, _mhi_sp_blocked             ;; 0 kittens → flash red and block
_mhi_sp_do_toggle:
   ld a, (_cursor_piece)
   xor #1
   ld (_cursor_piece), a
   call _match_redraw_all
   jr _mhi_set_debounce
_mhi_sp_blocked:
   ;; Flash cursor red for ~quarter second to signal blocked toggle
   ld a, (_cursor_col)
   ld c, a
   ld a, (_cursor_row)
   ld b, a
   call _match_col_row_to_screen_addr  ;; DE = cursor screen address
   inc de                              ;; same 1-byte offset as normal cursor draw
   ld a, #BLOCKED_CURSOR_COLOR
   ld c, #CURSOR_W
   ld b, #CURSOR_H
   call cpct_drawSolidBox_asm
   ld b, #13                           ;; ~quarter second (13 frames at 50Hz)
   call sys_util_delay
   call _match_redraw_all
   jr _mhi_set_debounce

_mhi_check_enter:
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   jr z, _mhi_check_esc
   call _match_place_piece
   jr _mhi_set_debounce

_mhi_check_esc:
   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   jr z, _mhi_done
   call _match_confirm_cancel

_mhi_set_debounce:
   ld a, #1
   ld (_turn_debounce), a

_mhi_done:
   ret

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
_match_boop:
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
_match_boop_cat:
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
   jr nc, _mbc_next_dir              ;; nr >= 6 → out of bounds

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
;;  Modified: AF, IX
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
_match_check_lines:
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
   jr z, _mcl_h_next                 ;; empty → skip
   ld d, a                           ;; D = v0
   cp #3
   jr nc, _mcl_h_v0_p2               ;; v0 >= 3 → P2 colour

   ;; P1 colour (v0 in {1,2}): v1 and v2 must be in {1,2}
   inc hl
   ld a, (hl)
   or a
   jr z, _mcl_h_next                 ;; empty
   cp #3
   jr nc, _mcl_h_next                ;; P2 piece → mismatch
   inc hl
   ld a, (hl)
   or a
   jr z, _mcl_h_next                 ;; empty
   cp #3
   jr nc, _mcl_h_next                ;; P2 piece → mismatch
   jr _mcl_h_match

_mcl_h_v0_p2:
   ;; P2 colour (v0 in {3,4}): v1 and v2 must be >= 3
   inc hl
   ld a, (hl)
   cp #3
   jr c, _mcl_h_next                 ;; empty or P1 → mismatch
   inc hl
   ld a, (hl)
   cp #3
   jr c, _mcl_h_next                 ;; mismatch

_mcl_h_match:
   ;; HL = ptr+2, A = v2, D = v0; process each cell
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
   jr c, _mcl_h_colloop
   inc b
   ld a, b
   cp #GRID_ROWS
   jr c, _mcl_h_rowloop

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
   jr z, _mcl_v_next                 ;; empty → skip
   ld d, a                           ;; D = v0
   cp #3
   jr c, _mcl_v_p1                   ;; v0 < 3 → P1 colour

   ;; P2 colour: v1 and v2 must be >= 3
   push hl                           ;; [ptr0, BC_outer]
   ld bc, #GRID_COLS
   add hl, bc                        ;; HL = ptr1
   ld a, (hl)
   cp #3
   jr c, _mcl_v_nm1                  ;; empty or P1 → mismatch
   push hl                           ;; [ptr1, ptr0, BC_outer]
   add hl, bc                        ;; HL = ptr2
   ld a, (hl)
   cp #3
   jr c, _mcl_v_nm2                  ;; mismatch
   jr _mcl_v_match

_mcl_v_p1:
   ;; P1 colour: v1 and v2 must be in {1,2}
   push hl                           ;; [ptr0, BC_outer]
   ld bc, #GRID_COLS
   add hl, bc                        ;; HL = ptr1
   ld a, (hl)
   or a
   jr z, _mcl_v_nm1                  ;; empty
   cp #3
   jr nc, _mcl_v_nm1                 ;; P2 → mismatch
   push hl                           ;; [ptr1, ptr0, BC_outer]
   add hl, bc                        ;; HL = ptr2
   ld a, (hl)
   or a
   jr z, _mcl_v_nm2                  ;; empty
   cp #3
   jr nc, _mcl_v_nm2                 ;; P2 → mismatch

_mcl_v_match:
   ;; HL = ptr2; stack = [ptr1, ptr0, BC_outer]
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
   jr c, _mcl_v_rowloop

   inc c
   ld a, c
   cp #GRID_COLS
   jr c, _mcl_v_colloop

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
_match_declare_winner:
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
   pop bc
   ld a, #1                          ;; default P1 wins (P1_CAT=1)
   ld a, d
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
   pop bc                            ;; restore outer BC
   ld a, d
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
   xor a
   ld (_turn_debounce), a

   ;; draw full screen: static elements once, then grid + board + cursor + HUD
   call sys_render_draw_screen
   call _match_redraw_all
   call man_match_draw_hud
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
   call _match_handle_input

   ret
