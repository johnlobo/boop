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

;;===============================================================================
;; UITEXT: texto 3x5 del nuevo interfaz (fuente en src/assets/ui/font3x5.s)
;;===============================================================================
.globl sys_uitext_set_colors
.globl sys_uitext_draw
.globl sys_uitext_draw_list
.globl _font3x5

UITEXT_SINGLE = 0      ;; A para sys_uitext_draw: 5 lineas
UITEXT_DOUBLE = 1      ;; A para sys_uitext_draw: 10 lineas (doble altura)
UITEXT_SHIFT  = 2      ;; A para sys_uitext_draw: 1 pixel a la izquierda
UITEXT_CHAR_W = 2
UITEXT_END    = 0xFF   ;; fin de lista de sys_uitext_draw_list      ;; bytes por caracter
