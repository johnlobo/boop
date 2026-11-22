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

.include "man/help.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/render.h.s"
.include "sys/uitext.h.s"
.include "sys/input.h.s"
.include "sys/util.h.s"

.module man_help

;;
;; Pantalla de ayuda: assets/ui/mockups/help.png.
;; Dos cajas negras con x 15..144 (borde izquierdo en pixel impar) y textos
;; en celdas x 21 (byte 11 con UITEXT_SHIFT), x 68 (byte 34) y x 34 (byte 17).
HELP_BOX_TOP1 = 44
HELP_BOX_H1   = 63
HELP_BOX_TOP2 = 112
HELP_BOX_H2   = 50
HELP_D        = UITEXT_DOUBLE
HELP_DS       = UITEXT_DOUBLE|UITEXT_SHIFT
HELP_SS       = UITEXT_SINGLE|UITEXT_SHIFT
HELP_S        = UITEXT_SINGLE

.area _DATA

man_help_done:: .db 0   ;; set to 1 when player presses Enter to exit

_help_str_goal_hdr: .asciz "GOAL"
_help_str_goal1:    .asciz "PLACE CATS AND KITTENS"
_help_str_goal2:    .asciz "ON A 6X6 BOARD."
_help_str_goal3:    .asciz "FILL A ROW, COLUMN OR"
_help_str_goal4:    .asciz "DIAGONAL TO WIN."
_help_str_ctrl_hdr: .asciz "CONTROLS"
_help_str_arrows:   .asciz "ARROWS"
_help_str_move:     .asciz "MOVE CURSOR"
_help_str_space:    .asciz "SPACE"
_help_str_toggle:   .asciz "TOGGLE PIECE"
_help_str_enter:    .asciz "ENTER"
_help_str_place:    .asciz "PLACE PIECE"
_help_str_back:     .asciz "PRESS ENTER TO CONTINUE"

;; x, y, flags, tinta, fondo, cadena
_help_texts:
   .db 11,  50, HELP_DS, PEN_YELLOW,        PEN_BLACK
   .dw _help_str_goal_hdr
   .db 11,  64, HELP_SS, PEN_WHITE,         PEN_BLACK
   .dw _help_str_goal1
   .db 11,  75, HELP_SS, PEN_WHITE,         PEN_BLACK
   .dw _help_str_goal2
   .db 11,  86, HELP_SS, PEN_WHITE,         PEN_BLACK
   .dw _help_str_goal3
   .db 11,  97, HELP_SS, PEN_WHITE,         PEN_BLACK
   .dw _help_str_goal4
   .db 11, 118, HELP_DS, PEN_YELLOW,        PEN_BLACK
   .dw _help_str_ctrl_hdr
   .db 11, 131, HELP_SS, PEN_PASTEL_CYAN,   PEN_BLACK
   .dw _help_str_arrows
   .db 34, 131, HELP_S,  PEN_WHITE,         PEN_BLACK
   .dw _help_str_move
   .db 11, 141, HELP_SS, PEN_PASTEL_CYAN,   PEN_BLACK
   .dw _help_str_space
   .db 34, 141, HELP_S,  PEN_WHITE,         PEN_BLACK
   .dw _help_str_toggle
   .db 11, 151, HELP_SS, PEN_PASTEL_CYAN,   PEN_BLACK
   .dw _help_str_enter
   .db 34, 151, HELP_S,  PEN_WHITE,         PEN_BLACK
   .dw _help_str_place
   .db 17, 176, HELP_D,  PEN_PASTEL_YELLOW, PEN_BLUE
   .dw _help_str_back
   .db UITEXT_END

.area _CODE

;;-----------------------------------------------------------------
;; _help_box
;;   Caja negra x 15..144 desde la linea B, C lineas de alto.
;;   Modified: AF, BC, DE, HL
;;
_help_box:
   push bc
   ld c, #7
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm        ;; HL = byte 7 (x 14, 15)
   pop bc
   ld b, c                           ;; B = height
   push hl
   push bc
   ex de, hl
   ld a, #PAT_BLUE_BLACK
   ld c, #1
   call cpct_drawSolidBox_asm
   pop bc
   pop hl
   inc hl                            ;; bytes 8..71: two boxes of 32 (max 63)
   push hl
   push bc
   ex de, hl
   xor a
   ld c, #32
   call cpct_drawSolidBox_asm
   pop bc
   pop hl
   ld de, #32
   add hl, de
   push hl
   push bc
   ex de, hl
   xor a
   ld c, #32
   call cpct_drawSolidBox_asm
   pop bc
   pop hl
   ld de, #32
   add hl, de                        ;; byte 72 (x 144, 145)
   ex de, hl
   ld a, #PAT_BLACK_BLUE
   ld c, #1
   jp cpct_drawSolidBox_asm

;;-----------------------------------------------------------------
;; man_help_draw
;;  Draws the static help screen content.
;;  Modified: AF, BC, DE, HL
;;
man_help_draw:
   ld a, #PATTERN_BLUE
   call sys_render_fill_screen

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 28, 19
   ld hl, #_s_logo_small
   ld c, #S_LOGO_SMALL_W
   ld b, #S_LOGO_SMALL_H
   call cpct_drawSprite_asm

   ld b, #HELP_BOX_TOP1
   ld c, #HELP_BOX_H1
   call _help_box
   ld b, #HELP_BOX_TOP2
   ld c, #HELP_BOX_H2
   call _help_box

   ld hl, #_help_texts
   jp sys_uitext_draw_list

;;-----------------------------------------------------------------
;;
;; man_help_init
;;
;;  Clears the screen and draws the help page.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_help_init::
   xor a
   ld (man_help_done), a

   call sys_util_fadeOut
   call man_help_draw
   call sys_util_fadeIn

   ret

;;-----------------------------------------------------------------
;;
;; man_help_update
;;
;;  Called every frame while the help screen is active.
;;  Waits for Enter; sets man_help_done=1 to signal game.s to
;;  return to the menu.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_help_update::
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   or a
   ret z                       ;; Enter not pressed, nothing to do

   ld a, #1
   ld (man_help_done), a

   ret
