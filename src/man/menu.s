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

.include "man/menu.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/render.h.s"
.include "sys/uitext.h.s"
.include "sys/input.h.s"
.include "sys/util.h.s"


.module man_menu

;; Pantalla de titulo (assets/ui/mockups/title.png).
;; Opciones: texto centrado (x = 40 - longitud, en bytes); la seleccionada va
;; sobre el boton amarillo en negro, las demas en blanco sobre azul.
MENU_BTN_X       = 18         ;; boton: x en bytes (36 px)
MENU_BTN_DY      = 3          ;; boton empieza 3 lineas sobre el texto
MENU_NUM_OPTIONS = 3

.area _DATA

_menu_opt1_string:  .asciz "ONE PLAYER"
_menu_opt2_string:  .asciz "TWO PLAYERS"
_menu_opt3_string:  .asciz "HELP"
_menu_hint_string:  .asciz "ARROWS MOVE   ENTER SELECT"
_menu_star_string:  .asciz "+"    ;; el caracter se cambia por estrella

;; Por opcion: cadena, x del texto en bytes, y del texto (de la maqueta)
_menu_options:
   .dw _menu_opt1_string
   .db 30, 112
   .dw _menu_opt2_string
   .db 29, 136
   .dw _menu_opt3_string
   .db 36, 154
MENU_OPT_SIZE = 4

;; Estrellas: x en bytes, y, pen, glyph ('+' centro en pixel impar, '*' par)
_menu_stars:
   .db 14, 59, PEN_BRIGHT_CYAN, '+
   .db 39, 60, PEN_PASTEL_BLUE, '+
   .db 64, 57, PEN_YELLOW,      '*
   .db 19, 74, PEN_SKY_BLUE,    '+
   .db 59, 72, PEN_SKY_BLUE,    '+
MENU_NUM_STARS = 5

man_menu_selected::  .db 0      ;; 0 = ONE PLAYER, 1 = TWO PLAYERS, 2 = HELP
man_menu_confirmed:: .db 0      ;; 0 = not confirmed, 1 = ONE PLAYER, 2 = TWO PLAYERS, 3 = HELP

.area _CODE

;;-----------------------------------------------------------------
;;
;; man_menu_draw
;;
;;  Draws the three options. Two passes: unselected options first (blue
;;  box + white text), then the selected one (yellow button + black
;;  text), because the button overlaps the next option's box.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_menu_draw::
   xor a
   call _mmd_pass                    ;; pass 0: unselected
   ld a, #1                          ;; pass 1: selected
_mmd_pass:
   ld (_mmd_want_sel), a
   ld hl, #_menu_options
   ld b, #0                          ;; option index
_mmd_loop:
   push bc
   push hl
   ld a, (man_menu_selected)
   sub b                             ;; 0 if this option is selected
   jr z, _mmd_is_sel
   ld a, #1
_mmd_is_sel:
   xor #1                            ;; A = 1 selected, 0 unselected
   ld c, a
   ld a, (_mmd_want_sel)
   cp c
   jr nz, _mmd_next
   inc hl                            ;; skip string pointer
   inc hl
   inc hl                            ;; skip x
   ld a, (hl)                        ;; text y
   ld (_mmd_text_y), a
   sub #MENU_BTN_DY
   ld b, a
   ld c, #MENU_BTN_X
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm        ;; HL = button area
   ex de, hl
   ld a, (_mmd_want_sel)
   or a
   jr z, _mmd_unselected
   ld hl, #_s_menu_button
   ld c, #S_MENU_BUTTON_W
   ld b, #S_MENU_BUTTON_H
   call cpct_drawSprite_asm
   ld l, #PEN_BLACK
   ld h, #PEN_YELLOW
   jr _mmd_text
_mmd_unselected:
   ld a, #PATTERN_BLUE
   ld c, #S_MENU_BUTTON_W
   ld b, #S_MENU_BUTTON_H
   call cpct_drawSolidBox_asm
   ld l, #PEN_WHITE
   ld h, #PEN_BLUE
_mmd_text:
   call sys_uitext_set_colors
   pop hl                            ;; option entry
   push hl
   ld e, (hl)
   inc hl
   ld d, (hl)
   inc hl
   ld c, (hl)                        ;; C = x
   push de                           ;; string
   ld a, (_mmd_text_y)
   ld b, a
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl                         ;; DE = video
   pop hl                            ;; HL = string
   ld a, #UITEXT_DOUBLE
   call sys_uitext_draw
_mmd_next:
   pop hl
   ld bc, #MENU_OPT_SIZE
   add hl, bc
   pop bc
   inc b
   ld a, b
   cp #MENU_NUM_OPTIONS
   jr nz, _mmd_loop
   ret
_mmd_want_sel: .db 0
_mmd_text_y: .db 0

;;-----------------------------------------------------------------
;;
;; _menu_draw_static
;;
;;  Draws everything on the title screen that never changes.
;;  Modified: AF, BC, DE, HL
;;
_menu_draw_static:
   ld a, #PATTERN_BLUE
   call sys_render_fill_screen

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 17, 20
   ld hl, #_s_logo_big
   ld c, #S_LOGO_BIG_W
   ld b, #S_LOGO_BIG_H
   call cpct_drawSprite_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 22, 69
   ld hl, #_s_title_cats
   ld c, #S_TITLE_CATS_W
   ld b, #S_TITLE_CATS_H
   call cpct_drawSprite_asm

   ld hl, #_menu_stars
   ld b, #MENU_NUM_STARS
_mds_star:
   push bc
   ld c, (hl)                        ;; x
   inc hl
   ld b, (hl)                        ;; y
   inc hl
   ld a, (hl)                        ;; pen
   inc hl
   ld e, (hl)                        ;; glyph
   inc hl
   push hl
   ld hl, #_menu_star_string
   ld (hl), e
   push bc
   ld l, a
   ld h, #PEN_BLUE
   call sys_uitext_set_colors
   pop bc
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_star_string
   ld a, #UITEXT_SINGLE
   call sys_uitext_draw
   pop hl
   pop bc
   djnz _mds_star

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 21, 174
   ld a, #PATTERN_BRIGHT_BLUE
   ld c, #38
   ld b, #1
   call cpct_drawSolidBox_asm

   ld l, #PEN_PASTEL_CYAN
   ld h, #PEN_BLUE
   call sys_uitext_set_colors
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 14, 183
   ld hl, #_menu_hint_string
   ld a, #UITEXT_DOUBLE
   jp sys_uitext_draw

;;-----------------------------------------------------------------
;;
;; man_menu_init
;;
;;  Initializes and draws the main menu
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_menu_init::
   xor a
   ld (man_menu_selected), a
   ld (man_menu_confirmed), a

   call sys_util_fadeOut
   call _menu_draw_static
   call man_menu_draw
   call sys_util_fadeIn
   ret

;;-----------------------------------------------------------------
;;
;; man_menu_update
;;
;;  Updates the main menu each frame: cursor navigation and confirm.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_menu_update::
   jp sys_input_menu_update          ;; tail call: debounced input dispatch

;;-----------------------------------------------------------------
;; Menu input action routines — called by sys_input_menu_update
;;-----------------------------------------------------------------

_menu_input_up::
   ld a, (man_menu_selected)
   or a
   jr z, _miu_up_wrap
   dec a
   jr _miu_up_done
_miu_up_wrap:
   ld a, #MENU_NUM_OPTIONS-1
_miu_up_done:
   ld (man_menu_selected), a
   jp man_menu_draw                  ;; tail call: redraw + ret to caller

_menu_input_down::
   ld a, (man_menu_selected)
   cp #MENU_NUM_OPTIONS-1
   jr z, _miu_down_wrap
   inc a
   jr _miu_down_done
_miu_down_wrap:
   xor a
_miu_down_done:
   ld (man_menu_selected), a
   jp man_menu_draw                  ;; tail call: redraw + ret to caller

_menu_input_confirm::
   ld a, (man_menu_selected)
   inc a                             ;; 1=ONE PLAYER, 2=TWO PLAYERS, 3=HELP
   ld (man_menu_confirmed), a
   ret
