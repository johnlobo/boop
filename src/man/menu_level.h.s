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
;; menu_level: AI difficulty level selection screen.
;;
;; Shows 4 difficulty options with coloured catty sprites. On confirmation
;; writes man_ai_level (defined in ai.h.s) with the chosen index (0-3).
;;------------------------------------------------------------------------------

;; Y positions for each option row (20 px spacing)
MENU_LEVEL_OPT_Y0  = 55
MENU_LEVEL_OPT_Y1  = 75
MENU_LEVEL_OPT_Y2  = 95
MENU_LEVEL_OPT_Y3  = 115
MENU_LEVEL_TITLE_Y = 20
MENU_LEVEL_HINT1_Y = 160
MENU_LEVEL_HINT2_Y = 172

;;------------------------------------------------------------------------------
;; Public data
;;------------------------------------------------------------------------------
.globl man_menu_level_done     ;; byte: 1=confirmed, 2=cancelled (ESC)
.globl man_menu_level_selected ;; byte 0-3: currently highlighted option

;;------------------------------------------------------------------------------
;; Public routines
;;------------------------------------------------------------------------------
.globl man_menu_level_init     ;; draw level-selection screen (fadeOut/In included)
.globl man_menu_level_update   ;; handle input; sets done and man_ai_level on confirm
