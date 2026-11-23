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
;; Debug build flag — set to 0 to produce a build with NO debug code at all
;; (not just disabled: the .if/.endif blocks it guards are excluded from
;; assembly entirely). See _match_debug_fill_board in match.s.
;;------------------------------------------------------------------------------
BOOP_DEBUG_BUILD = 0

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
;; HUD positions (bytes / pixels), from assets/ui/mockups/match.png. P1 digits
;; sit on an odd pixel and are drawn with UITEXT_SHIFT.
;;------------------------------------------------------------------------------
HUD_P1_DIGIT_X   = 15
HUD_P2_DIGIT_X   = 69
HUD_P1_ICON_X    = 7
HUD_P2_ICON_X    = 61
HUD_CATS_Y       = 96
HUD_KITTENS_Y    = 122   ;; kitten icon top; its digit starts 1 px above
TURN_BAR_X       = 33    ;; "Pn TURN" text
TURN_BAR_Y       = 37

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
GRID_FIRST_CELL_X    = 25   ;; px 50
GRID_FIRST_CELL_Y    = 55
GRID_CELL_W          = 5    ;; byte pitch (9 px body + 1 px black)
GRID_CELL_H          = 19   ;; px pitch (17 px body + 2 px black)
GRID_FRAME_H         = 17   ;; px of the cell covered by cursor/markers
GRID_PIECE_DY        = 3    ;; piece top inside the cell
GRID_COLS            = 6
GRID_ROWS            = 6

;; Max simultaneous trio candidates a single move can create. A player never
;; has more than 8 pieces on the board (8 kittens/cats total, by construction
;; — see MATCH_INITIAL_KITTENS/CATS in match.s); the max number of length-3
;; windows (any orientation) fully coverable by 8 cells on this 6x6 board is
;; 6 (verified by exhaustive local search), so 8 leaves headroom.
MATCH_MAX_TRIO_CANDIDATES = 8

;; Max on-board kittens a player can have when _match_graduate_or_win runs.
;; It only runs once that player's reserve is 0 cats/0 kittens, i.e. all 8
;; of their pieces are already on the board — trivially at most 8 kittens.
MATCH_MAX_GRADUATE_CANDIDATES = 8

;;------------------------------------------------------------------------------
;; Cursor color: pen 6 (bright yellow, firmware 24) encoded for Mode 0 solid-box
;;   Both pixels = pen 6 → byte bits [7..0] = 0011 1100 = 0x3C
;;------------------------------------------------------------------------------
CURSOR_COLOR         = 0x3C
BLOCKED_CURSOR_COLOR = 0xF0  ;; pen 5 (Orange) both pixels: blocked-toggle flash

;; Last-move marker: pen 15 (bright white, firmware 26) — maximum contrast
;; against the board art; distinct from cursor (yellow) and the blocked-cursor
;; flash (0xF0, which despite its old comment is actually pen 5 / Orange, not
;; Red — see g_palette0.c's "Firmware Palette Converted" list).
LAST_MOVE_COLOR      = 0xFF

;; Cat-triple win-line blink: pen 6 (bright yellow, firmware 24) — same
;; pattern byte as CURSOR_COLOR, fine since the cursor isn't drawn during
;; the win sequence.
WIN_FLASH_COLOR      = 0x3C

;; Trio-choice selector frame: pen 13 (Bright Cyan, firmware 20) — green
;; (pen 9) was tried first but didn't stand out against the board art;
;; boop's fixed 16-colour palette has no lighter green, so bright cyan
;; instead — distinct from the yellow win/combo flashes (still-choosing
;; vs. resolving) and from the white last-move marker (0xFF).
TRIO_SELECT_COLOR    = 0xF3

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
.globl _match_threat_windows      ;; 80 length-3 board-offset windows (h/v/diag)
.globl _match_state               ;; MATCH_STATE_P1/P2 (exported for tests/run_rules.c)

;; Exported for tests/run_rules.c only (headless rules coverage) — not used
;; cross-module otherwise.
.globl _match_collect_trio_candidates
.globl _match_candidate_list
.globl _match_candidate_count
.globl _match_graduate_or_win
.globl _match_check_cat_lines
.globl _last_move_row

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
