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
_match_state:   .db 0   ;; MATCH_STATE_P1 or MATCH_STATE_P2
_cursor_col:    .db 0   ;; 0 .. GRID_COLS-1
_cursor_row:    .db 0   ;; 0 .. GRID_ROWS-1
_cursor_piece:  .db 0   ;; PIECE_CAT or PIECE_KITTEN
_turn_debounce: .db 0   ;; 1 while a key is held (same pattern as menu.s)

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
   ;; Erase old digit before drawing new one
   push de                           ;; save screen addr (DE still valid for drawSolidBox)
   push af                           ;; save digit
   ld a, #HUD_NUM_BG                 ;; fill color
   ld c, #S_BIG_NUMBERS_WIDTH
   ld b, #S_BIG_NUMBERS_HEIGHT
   call cpct_drawSolidBox_asm        ;; clears area; DE clobbered
   pop af                            ;; restore digit
   pop de                            ;; restore screen addr
   ;; Draw the digit sprite
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

   ;; Toggle state, reset piece selection to kitten
   ld a, (_match_state)
   xor #1
   ld (_match_state), a
   ld a, #PIECE_KITTEN
   ld (_cursor_piece), a

   call _match_redraw_all
   call man_match_draw_hud
   ret

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
   jr _mhi_set_debounce

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
   jr _mhi_set_debounce

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
   jr _mhi_set_debounce

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
   ld a, (_cursor_piece)
   xor #1                            ;; toggle 0<->1
   ld (_cursor_piece), a
   call _match_redraw_all
   jr _mhi_set_debounce

_mhi_check_enter:
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   jr z, _mhi_done
   call _match_place_piece

_mhi_set_debounce:
   ld a, #1
   ld (_turn_debounce), a

_mhi_done:
   ret

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

   ;; initialise cursor and turn state
   xor a
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

   ret

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
