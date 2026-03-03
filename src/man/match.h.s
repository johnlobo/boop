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

;;------------------------------------------------------------------------------
;; Player struct layout (offsets, no macro dependency)
;;   score   : 4 bytes BCD  (offset 0)
;;   cats    : 1 byte       (offset 4)
;;   kittens : 1 byte       (offset 5)
;;------------------------------------------------------------------------------
Player_score   = 0
Player_cats    = 4
Player_kittens = 5
sizeof_Player  = 6

;;------------------------------------------------------------------------------
;; HUD screen positions (bytes / pixels)
;;   Numbers drawn below the cat and catty sprites (y=68, h=17 → bottom y=84)
;;   big_numbers are 3 bytes wide; cat/catty sprites are 5 bytes wide
;;   X centering: sprite_x + (5-3)/2 = sprite_x + 1
;;------------------------------------------------------------------------------
HUD_P1_CATS_X    = 6    ;; below P1 cat   sprite (render x=5,  w=5)
HUD_P1_KITTENS_X = 11   ;; below P1 catty sprite (render x=10, w=5)
HUD_P2_CATS_X    = 66   ;; below P2 cat   sprite (render x=65, w=5)
HUD_P2_KITTENS_X = 71   ;; below P2 catty sprite (render x=70, w=5)
HUD_Y            = 89   ;; y = 68 (sprites top) + 17 (height) + 4 (gap)

;;------------------------------------------------------------------------------
;; Match state constants
;;------------------------------------------------------------------------------
MATCH_STATE_P1       = 0
MATCH_STATE_P2       = 1

;;------------------------------------------------------------------------------
;; Piece type constants
;;------------------------------------------------------------------------------
PIECE_CAT            = 0
PIECE_KITTEN         = 1

;;------------------------------------------------------------------------------
;; Board cell value constants
;;------------------------------------------------------------------------------
BOARD_EMPTY          = 0
BOARD_P1_CAT         = 1
BOARD_P1_KITTEN      = 2
BOARD_P2_CAT         = 3
BOARD_P2_KITTEN      = 4

;;------------------------------------------------------------------------------
;; Grid geometry constants (all tunable)
;;   GRID_FIRST_CELL_X : byte offset within screen row of first cell
;;   GRID_FIRST_CELL_Y : pixel row of first cell
;;   GRID_CELL_W       : cell width in bytes
;;   GRID_CELL_H       : cell height in pixels
;;   GRID_COLS / ROWS  : grid dimensions
;;------------------------------------------------------------------------------
GRID_FIRST_CELL_X    = 22   ;; byte 21 (bg origin) + 1 left border byte
GRID_FIRST_CELL_Y    = 35   ;; px  32 (bg origin) + 3 px top gap
GRID_CELL_W          = 7    ;; byte pitch between cell origins (7 bytes)
GRID_CELL_H          = 24   ;; px pitch between cell origins  (24 px)
GRID_COLS            = 6
GRID_ROWS            = 6

;;------------------------------------------------------------------------------
;; Cursor color: pen 1 (bright yellow) encoded for Mode 0 solid-box
;;   Both pixels = pen 1 → byte bits [7..0] = 0000 0011 = 0x03
;;------------------------------------------------------------------------------
CURSOR_COLOR         = 0x03

;;------------------------------------------------------------------------------
;; Global variables
;;------------------------------------------------------------------------------
.globl man_match_player1
.globl man_match_player2
.globl man_match_num_players      ;; 1 or 2

;;------------------------------------------------------------------------------
;; Global routines
;;------------------------------------------------------------------------------
.globl man_match_init
.globl man_match_update
.globl man_match_draw_hud
