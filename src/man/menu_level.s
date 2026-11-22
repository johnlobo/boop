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

.include "man/menu_level.h.s"
.include "man/ai.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/render.h.s"
.include "sys/uitext.h.s"
.include "sys/util.h.s"

.module man_menu_level

;;==============================================================================
;; DATA
;;==============================================================================
.area _DATA

man_menu_level_done::     .db 0   ;; 1=confirmed, 2=cancelled (ESC)
man_menu_level_selected:: .db 0   ;; 0-3: highlighted row

_menu_level_debounce: .db 0

_menu_level_title:  .asciz "CHOOSE OPPONENT"
_menu_level_hint:   .asciz "ARROWS MOVE   ENTER SELECT"
_menu_level_esc:    .asciz "ESC BACK"

_menu_level_name_0:  .asciz "GATITO TIMIDO"
_menu_level_name_1:  .asciz "GATO JUGUETON"
_menu_level_name_3:  .asciz "GATA ASTUTA"
_menu_level_name_4:  .asciz "MAESTRO FELINO"

;; Por opcion: nombre, icono (mascara entrelazada)
_menu_level_opts:
   .dw _menu_level_name_0, _s_ai_icon_1
   .dw _menu_level_name_1, _s_ai_icon_2
   .dw _menu_level_name_3, _s_ai_icon_3
   .dw _menu_level_name_4, _s_ai_icon_4

;; Patrones de boton: borde izquierdo, borde (arriba/abajo), relleno,
;; borde derecho interior, tinta y fondo del texto
_mld_pats_sel:   .db PAT_BLUE_YELLOW, PAT_YELLOW, PAT_YELLOW, PAT_YELLOW, PEN_BLACK, PEN_YELLOW
_mld_pats_unsel: .db PAT_BLUE_BBLUE, PATTERN_BRIGHT_BLUE, PATTERN_BLUE, PAT_BLUE_BBLUE, PEN_WHITE, PEN_BLUE

;;==============================================================================
;; CODE
;;==============================================================================
.area _CODE

;; Geometria de assets/ui/mockups/ai_select.png. Boton i: y0 = 57 + 25*i,
;; cuerpo x 25..133 (bytes 12..66, borde izquierdo en pixel impar), sombra
;; negra en x 134 y en las 2 lineas de debajo.
MLD_Y0        = 57
MLD_STEP      = 25
MLD_ICON_X    = 16         ;; bytes (x 32)
MLD_ICON_DY   = 5
MLD_NAME_X    = 26         ;; celda en x 51: byte 26 con UITEXT_SHIFT
MLD_NAME_DY   = 6
MLD_NUM_OPTS  = 4

;;-----------------------------------------------------------------
;;
;; man_menu_level_init
;;
;;  Clears the screen and draws the AI level selection screen.
;;  Input:  -
;;  Output: man_menu_level_done=0, man_menu_level_selected=0
;;  Modified: AF, BC, DE, HL
;;
man_menu_level_init::
   xor a
   ld (man_menu_level_done), a
   ld (man_menu_level_selected), a
   ld (_menu_level_debounce), a

   call sys_util_fadeOut
   call _menu_level_draw_static
   call _menu_level_draw
   call sys_util_fadeIn
   ret

;;-----------------------------------------------------------------
;; _mld_box
;;   Solid box at (C bytes, B lines), L bytes wide, H lines high.
;;   Input: A = pattern, C, B, L, H
;;   Modified: AF, BC, DE, HL
;;
_mld_box:
   push af
   push hl
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   pop hl
   ld c, l
   ld b, h
   pop af
   jp cpct_drawSolidBox_asm

;;-----------------------------------------------------------------
;; _mld_text
;;   Input: HL = string, C = x bytes, B = y, A = uitext flags
;;   (colours already set)
;;   Modified: AF, BC, DE, HL
;;
_mld_text:
   push af
   push hl
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   pop hl
   pop af
   jp sys_uitext_draw

;; A = y0 of option B (MLD_Y0 + B*25). Modified: AF, C
_mld_option_y:
   ld a, b
   add a, a
   add a, a
   add a, a                          ;; *8
   ld c, a
   add a, a                          ;; *16
   add a, c                          ;; *24
   add a, b                          ;; *25
   add a, #MLD_Y0
   ret

;;-----------------------------------------------------------------
;;
;; _menu_level_draw_static
;;
;;  Background, logo, title, button shadows, separator and hints.
;;  Modified: AF, BC, DE, HL
;;
_menu_level_draw_static:
   ld a, #PATTERN_BLUE
   call sys_render_fill_screen

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 28, 17
   ld hl, #_s_logo_small
   ld c, #S_LOGO_SMALL_W
   ld b, #S_LOGO_SMALL_H
   call cpct_drawSprite_asm

   ld l, #PEN_PASTEL_CYAN
   ld h, #PEN_BLUE
   call sys_uitext_set_colors
   ld hl, #_menu_level_title
   ld c, #25
   ld b, #40
   ld a, #UITEXT_DOUBLE
   call _mld_text
   ld hl, #_menu_level_hint
   ld c, #14
   ld b, #170
   ld a, #UITEXT_DOUBLE
   call _mld_text
   ld hl, #_menu_level_esc
   ld c, #32
   ld b, #180
   ld a, #UITEXT_DOUBLE
   call _mld_text

   ;; Button shadows (same for both states)
   ld b, #0
_mlds_shadow:
   push bc
   call _mld_option_y
   push af
   inc a
   ld b, a
   ld c, #67
   ld hl, #0x1201                    ;; 1 x 18
   ld a, #PAT_BLACK_BLUE
   call _mld_box
   pop af
   push af
   add a, #19
   ld b, a
   ld c, #13
   ld hl, #0x0236                    ;; 54 x 2
   xor a
   call _mld_box
   pop af
   add a, #19
   ld b, a
   ld c, #67
   ld hl, #0x0201                    ;; 1 x 2
   ld a, #PAT_BLACK_BLUE
   call _mld_box
   pop bc
   inc b
   ld a, b
   cp #MLD_NUM_OPTS
   jr nz, _mlds_shadow

   ;; Separator, y 164, x 13..146 (66 middle bytes: two boxes, max 63)
   ld c, #6
   ld b, #164
   ld hl, #0x0101
   ld a, #PAT_BLUE_BBLUE
   call _mld_box
   ld c, #7
   ld b, #164
   ld hl, #0x0121                    ;; 33 x 1
   ld a, #PATTERN_BRIGHT_BLUE
   call _mld_box
   ld c, #40
   ld b, #164
   ld hl, #0x0121
   ld a, #PATTERN_BRIGHT_BLUE
   call _mld_box
   ld c, #73
   ld b, #164
   ld hl, #0x0101
   ld a, #PAT_BBLUE_BLUE
   jp _mld_box

;;-----------------------------------------------------------------
;;
;; _menu_level_draw
;;
;;  Draws the 4 option buttons: the selected one yellow with black text,
;;  the others blue with a bright blue frame and white text.
;;  Input:  man_menu_level_selected
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_menu_level_draw:
   push ix
   ld b, #0
_mld_loop:
   push bc
   ld ix, #_mld_pats_unsel
   ld a, (man_menu_level_selected)
   cp b
   jr nz, _mld_have_pats
   ld ix, #_mld_pats_sel
_mld_have_pats:
   call _mld_option_y
   ld (_mld_y0), a
   ;; left edge byte, 19 lines
   ld b, a
   ld c, #12
   ld hl, #0x1301
   ld a, 0(ix)
   call _mld_box
   ;; top border, 2 lines
   ld a, (_mld_y0)
   ld b, a
   ld c, #13
   ld hl, #0x0236
   ld a, 1(ix)
   call _mld_box
   ;; fill, 16 lines
   ld a, (_mld_y0)
   add a, #2
   ld b, a
   ld c, #13
   ld hl, #0x1035                    ;; 53 x 16
   ld a, 2(ix)
   call _mld_box
   ;; right inner edge byte
   ld a, (_mld_y0)
   add a, #2
   ld b, a
   ld c, #66
   ld hl, #0x1001
   ld a, 3(ix)
   call _mld_box
   ;; bottom border, 1 line
   ld a, (_mld_y0)
   add a, #18
   ld b, a
   ld c, #13
   ld hl, #0x0136
   ld a, 1(ix)
   call _mld_box
   ;; icon
   pop bc
   push bc
   ld a, b
   add a, a
   add a, a                          ;; *4: entry size
   ld e, a
   ld d, #0
   ld hl, #_menu_level_opts
   add hl, de
   push hl
   inc hl
   inc hl
   ld a, (hl)
   inc hl
   ld h, (hl)
   ld l, a                           ;; HL = icon
   push hl
   ld a, (_mld_y0)
   add a, #MLD_ICON_DY
   ld b, a
   ld c, #MLD_ICON_X
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   pop hl
   ld c, #S_AI_ICON_W
   ld b, #S_AI_ICON_H
   call cpct_drawSpriteMasked_asm
   ;; name
   ld l, 4(ix)
   ld h, 5(ix)
   call sys_uitext_set_colors
   pop hl
   ld a, (hl)
   inc hl
   ld h, (hl)
   ld l, a                           ;; HL = name
   ld a, (_mld_y0)
   add a, #MLD_NAME_DY
   ld b, a
   ld c, #MLD_NAME_X
   ld a, #UITEXT_DOUBLE|UITEXT_SHIFT
   call _mld_text
   pop bc
   inc b
   ld a, b
   cp #MLD_NUM_OPTS
   jp nz, _mld_loop
   pop ix
   ret
_mld_y0: .db 0

;;-----------------------------------------------------------------
;;
;; man_menu_level_update
;;
;;  Handles input on the level selection screen.
;;  Input:  -
;;  Output: man_menu_level_done: 1=confirmed, 2=cancelled
;;          man_ai_level set to selected option when confirmed
;;  Modified: AF, BC, DE, HL
;;
man_menu_level_update::
   ;; Debounce: wait for full key release
   ld a, (_menu_level_debounce)
   or a
   jr z, _mlu_check_keys
   call cpct_isAnyKeyPressed_asm
   or a
   ret nz
   xor a
   ld (_menu_level_debounce), a
   ret

_mlu_check_keys:
   ;; Cursor Up
   ld hl, #Key_CursorUp
   call cpct_isKeyPressed_asm
   jr z, _mlu_check_down
   ld a, (man_menu_level_selected)
   or a
   jr z, _mlu_up_wrap
   dec a
   jr _mlu_up_done
_mlu_up_wrap:
   ld a, #3
_mlu_up_done:
   ld (man_menu_level_selected), a
   call _menu_level_draw
   jr _mlu_debounce

_mlu_check_down:
   ld hl, #Key_CursorDown
   call cpct_isKeyPressed_asm
   jr z, _mlu_check_enter
   ld a, (man_menu_level_selected)
   cp #3
   jr z, _mlu_down_wrap
   inc a
   jr _mlu_down_done
_mlu_down_wrap:
   xor a
_mlu_down_done:
   ld (man_menu_level_selected), a
   call _menu_level_draw
   jr _mlu_debounce

_mlu_check_enter:
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   jr z, _mlu_check_esc
   ;; Confirm: copy selected to man_ai_level, signal done
   ld a, (man_menu_level_selected)
   ld (man_ai_level), a
   ld a, #1
   ld (man_menu_level_done), a
   jr _mlu_debounce

_mlu_check_esc:
   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   jr z, _mlu_done
   ;; Cancel: signal caller to return to menu
   ld a, #2
   ld (man_menu_level_done), a

_mlu_debounce:
   ld a, #1
   ld (_menu_level_debounce), a
_mlu_done:
   ret
