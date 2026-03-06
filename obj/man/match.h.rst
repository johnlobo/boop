ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;
                              3 ;;  This program is free software: you can redistribute it and/or modify
                              4 ;;  it under the terms of the GNU Lesser General Public License as published by
                              5 ;;  the Free Software Foundation, either version 3 of the License, or
                              6 ;;  (at your option) any later version.
                              7 ;;
                              8 ;;  This program is distributed in the hope that it will be useful,
                              9 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             10 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             11 ;;  GNU Lesser General Public License for more details.
                             12 ;;
                             13 ;;  You should have received a copy of the GNU Lesser General Public License
                             14 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             15 ;;-------------------------------------------------------------------------------
                             16 
                             17 ;;------------------------------------------------------------------------------
                             18 ;; Player struct layout (offsets, no macro dependency)
                             19 ;;   score   : 4 bytes BCD  (offset 0)
                             20 ;;   cats    : 1 byte       (offset 4)
                             21 ;;   kittens : 1 byte       (offset 5)
                             22 ;;------------------------------------------------------------------------------
                     0000    23 Player_score   = 0
                     0004    24 Player_cats    = 4
                     0005    25 Player_kittens = 5
                     0006    26 sizeof_Player  = 6
                             27 
                             28 ;;------------------------------------------------------------------------------
                             29 ;; HUD screen positions (bytes / pixels)
                             30 ;;   Numbers drawn below the cat and catty sprites (y=68, h=17 → bottom y=84)
                             31 ;;   big_numbers are 3 bytes wide; cat/catty sprites are 5 bytes wide
                             32 ;;   X centering: sprite_x + (5-3)/2 = sprite_x + 1
                             33 ;;------------------------------------------------------------------------------
                     0005    34 HUD_P1_CATS_X    = 5    ;; below P1 cat   sprite (render x=4,  w=5)
                     000A    35 HUD_P1_KITTENS_X = 10   ;; below P1 catty sprite (render x=9,  w=5)
                     0043    36 HUD_P2_CATS_X    = 67   ;; below P2 cat   sprite (render x=66, w=5)
                     0048    37 HUD_P2_KITTENS_X = 72   ;; below P2 catty sprite (render x=71, w=5)
                     0059    38 HUD_Y            = 89   ;; y = 68 (sprites top) + 17 (height) + 4 (gap)
                             39 
                             40 ;;------------------------------------------------------------------------------
                             41 ;; Match state constants
                             42 ;;------------------------------------------------------------------------------
                     0000    43 MATCH_STATE_P1       = 0
                     0001    44 MATCH_STATE_P2       = 1
                             45 
                             46 ;;------------------------------------------------------------------------------
                             47 ;; Piece type constants
                             48 ;;------------------------------------------------------------------------------
                     0000    49 PIECE_CAT            = 0
                     0001    50 PIECE_KITTEN         = 1
                             51 
                             52 ;;------------------------------------------------------------------------------
                             53 ;; Board cell value constants
                             54 ;;------------------------------------------------------------------------------
                     0000    55 BOARD_EMPTY          = 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                     0001    56 BOARD_P1_CAT         = 1
                     0002    57 BOARD_P1_KITTEN      = 2
                     0003    58 BOARD_P2_CAT         = 3
                     0004    59 BOARD_P2_KITTEN      = 4
                             60 
                             61 ;;------------------------------------------------------------------------------
                             62 ;; Grid geometry constants (all tunable)
                             63 ;;   GRID_FIRST_CELL_X : byte offset within screen row of first cell
                             64 ;;   GRID_FIRST_CELL_Y : pixel row of first cell
                             65 ;;   GRID_CELL_W       : cell width in bytes
                             66 ;;   GRID_CELL_H       : cell height in pixels
                             67 ;;   GRID_COLS / ROWS  : grid dimensions
                             68 ;;------------------------------------------------------------------------------
                     0013    69 GRID_FIRST_CELL_X    = 19   ;; byte 18 (bg origin) + 1 left border byte
                     0024    70 GRID_FIRST_CELL_Y    = 36   ;; px  32 (bg origin) + 4 px top gap
                     0007    71 GRID_CELL_W          = 7    ;; byte pitch between cell origins (7 bytes = 4px gap)
                     0018    72 GRID_CELL_H          = 24   ;; px pitch between cell origins  (24 px)
                     0006    73 GRID_COLS            = 6
                     0006    74 GRID_ROWS            = 6
                             75 
                             76 ;;------------------------------------------------------------------------------
                             77 ;; Cursor color: pen 6 (bright yellow, firmware 24) encoded for Mode 0 solid-box
                             78 ;;   Both pixels = pen 6 → byte bits [7..0] = 0011 1100 = 0x3C
                             79 ;;------------------------------------------------------------------------------
                     003C    80 CURSOR_COLOR         = 0x3C
                             81 
                             82 ;;------------------------------------------------------------------------------
                             83 ;; Global variables
                             84 ;;------------------------------------------------------------------------------
                             85 .globl man_match_player1
                             86 .globl man_match_player2
                             87 .globl man_match_num_players      ;; 1 or 2
                             88 .globl _match_cancelled           ;; 1 when player confirmed abandon
                             89 
                             90 ;;------------------------------------------------------------------------------
                             91 ;; Global routines
                             92 ;;------------------------------------------------------------------------------
                             93 .globl man_match_init
                             94 .globl man_match_update
                             95 .globl man_match_draw_hud
