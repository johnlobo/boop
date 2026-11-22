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
;; Shows 4 difficulty options (icon + name) as in assets/ui/mockups/ai_select.png. On confirmation
;; writes man_ai_level (defined in ai.h.s) with the chosen index (0-3).
;;------------------------------------------------------------------------------


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
