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
HUD_P1_CATS_X    = 5    ;; below P1 cat   sprite (render x=4,  w=5)
HUD_P1_KITTENS_X = 10   ;; below P1 catty sprite (render x=9,  w=5)
HUD_P2_CATS_X    = 67   ;; below P2 cat   sprite (render x=66, w=5)
HUD_P2_KITTENS_X = 72   ;; below P2 catty sprite (render x=71, w=5)
HUD_Y            = 89   ;; y = 68 (sprites top) + 17 (height) + 4 (gap)

;; Basket sprite origins (must match sys_render_draw_screen /
;; man_match_draw_hud's own basket redraw). S_BASKET_H=74 means the basket
;; art bleeds all the way down under the HUD digit row (Y=89) — the digit
;; area is NOT flat black background, it's basket artwork.
HUD_BASKET_P1_X  = 0
HUD_BASKET_P2_X  = 62
HUD_BASKET_Y     = 50

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
GRID_FIRST_CELL_X    = 19   ;; byte 18 (bg origin) + 1 left border byte
GRID_FIRST_CELL_Y    = 24   ;; px  20 (bg origin) + 4 px top gap
GRID_CELL_W          = 7    ;; byte pitch between cell origins (7 bytes = 4px gap)
GRID_CELL_H          = 24   ;; px pitch between cell origins  (24 px)
GRID_COLS            = 6
GRID_ROWS            = 6

;;------------------------------------------------------------------------------
;; Cursor color: pen 6 (bright yellow, firmware 24) encoded for Mode 0 solid-box
;;   Both pixels = pen 6 → byte bits [7..0] = 0011 1100 = 0x3C
;;------------------------------------------------------------------------------
CURSOR_COLOR         = 0x3C
BLOCKED_CURSOR_COLOR = 0xF0  ;; pen 3 (Red) both pixels in Mode 0 → blocked-toggle flash

;; Last-move marker: pen 15 (bright white, firmware 26) — maximum contrast
;; against the board art; distinct from cursor (yellow) and the blocked-cursor
;; flash (0xF0, which despite its old comment is actually pen 5 / Orange, not
;; Red — see g_palette0.c's "Firmware Palette Converted" list).
LAST_MOVE_COLOR      = 0xFF

;; Cat-triple win-line blink: pen 6 (bright yellow, firmware 24) — same
;; pattern byte as CURSOR_COLOR, fine since the cursor isn't drawn during
;; the win sequence.
WIN_FLASH_COLOR      = 0x3C

;; Victory/defeat fanfare duration, in vsync frames (50/sec). The AT3
;; export's win/lose subsongs loop forever once started (this player build
;; has no "play once" flag), so _match_declare_winner lets the fanfare run
;; for this long, then stops it explicitly before showing the banner.
;; Tune if the .aks fanfare length changes.
WIN_MUSIC_FRAMES     = 150   ;; ~3 seconds

;;------------------------------------------------------------------------------
;; Global variables
;;------------------------------------------------------------------------------
.globl man_match_player1
.globl man_match_player2
.globl man_match_num_players      ;; 1 or 2
.globl _match_cancelled           ;; 1 when player confirmed abandon

;; Exported for AI module use
.globl _match_board               ;; 36-byte row-major board array
.globl _cursor_col                ;; current cursor column (0..5)
.globl _cursor_row                ;; current cursor row    (0..5)
.globl _cursor_piece              ;; PIECE_CAT or PIECE_KITTEN
.globl _match_simulation_mode     ;; nonzero while AI evaluates hypothetical moves

;;------------------------------------------------------------------------------
;; Global routines
;;------------------------------------------------------------------------------
.globl man_match_init
.globl man_match_update
.globl man_match_draw_hud

;; Exported for AI module use
.globl _match_place_piece         ;; place current cursor piece on board
.globl _match_boop                ;; kitten boop (uses _cursor_row/_col)
.globl _match_boop_cat            ;; cat boop    (uses _cursor_row/_col)
.globl _match_restore_cell        ;; restore grid at (C=col, B=row), redraw piece
.globl _match_draw_cursor         ;; draw cursor at current _cursor_col/_row
