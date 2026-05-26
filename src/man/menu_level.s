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
.include "sys/text.h.s"
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
_menu_level_hint1:  .asciz "ARROWS - MOVE"
_menu_level_hint2:  .asciz "ENTER - SELECT"
_menu_level_esc:    .asciz "ESC - BACK"

_menu_level_name_0:  .asciz "GATITO TIMIDO"
_menu_level_name_1:  .asciz "GATO JUGUETON"
_menu_level_name_3:  .asciz "GATA ASTUTA"
_menu_level_name_4:  .asciz "MAESTRO FELINO"

_menu_level_name_ptrs:
   .dw _menu_level_name_0
   .dw _menu_level_name_1
   .dw _menu_level_name_3
   .dw _menu_level_name_4

_menu_level_catty_ptrs:
   .dw _s_catty_1
   .dw _s_catty_2
   .dw _s_catty_3
   .dw _s_catty_4

;;==============================================================================
;; CODE
;;==============================================================================
.area _CODE

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
   call sys_render_clear_buffer
   call sys_render_draw_header
   call _menu_level_draw
   call sys_util_fadeIn
   ret

;;-----------------------------------------------------------------
;;
;; _menu_level_draw
;;
;;  Draws title, 4 options (catty sprite + name), and hint lines.
;;  Selected option in yellow, others in white.
;;  Input:  man_menu_level_selected
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_menu_level_draw:
   ;; Title
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 26, MENU_LEVEL_TITLE_Y
   ld hl, #_menu_level_title
   ld c, #1                          ;; yellow
   call sys_text_draw_string

   ;; Draw each of the 4 options
   ld b, #0        ;; option index
_mld_loop:
   ;; Compute Y = MENU_LEVEL_OPT_Y0 + b*20
   ld a, b
   add a, a        ;; b*2
   add a, a        ;; b*4
   ld c, a         ;; C = b*4
   add a, a        ;; b*8
   add a, a        ;; b*16
   add a, c        ;; b*20
   add a, #MENU_LEVEL_OPT_Y0   ;; A = Y

   push bc         ;; save option index in B

   ;; --- Draw catty sprite at (X=20, Y) ---
   ld b, a         ;; B = Y
   ld c, #20       ;; X = 20 bytes
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl       ;; DE = screen addr for sprite

   pop bc          ;; B = option_index
   push bc
   ld a, b
   add a, a        ;; b*2 (word index)
   ld hl, #_menu_level_catty_ptrs
   ld c, a
   ld b, #0
   add hl, bc
   ld c, (hl)
   inc hl
   ld b, (hl)      ;; BC = sprite ptr

   ld__ixl S_CATTY_W
   ld__ixh S_CATTY_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   ;; --- Draw text at (X=27, Y+4) ---
   pop bc          ;; B = option_index
   push bc

   ld a, b
   add a, a        ;; b*2
   add a, a        ;; b*4
   ld c, a         ;; C = b*4
   add a, a        ;; b*8
   add a, a        ;; b*16
   add a, c        ;; b*20
   add a, #MENU_LEVEL_OPT_Y0   ;; A = Y
   add a, #4                   ;; center text vertically within sprite height

   ld b, a         ;; B = Y+4
   ld c, #27       ;; X = 27 bytes
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl       ;; DE = screen addr for text

   ;; Look up name string pointer
   pop bc          ;; B = option_index
   push bc
   ld a, b
   add a, a        ;; b*2 (word index)
   ld hl, #_menu_level_name_ptrs
   ld c, a
   ld b, #0
   add hl, bc
   ld c, (hl)
   inc hl
   ld b, (hl)
   ld h, b
   ld l, c         ;; HL = name string pointer

   pop bc          ;; B = option_index
   push bc
   ld a, (man_menu_level_selected)
   cp b
   jr nz, _mld_white
   ld c, #1        ;; yellow = selected
   jr _mld_draw
_mld_white:
   ld c, #0        ;; white = unselected
_mld_draw:
   call sys_text_draw_string

   pop bc
   inc b
   ld a, b
   cp #4
   jr c, _mld_loop

   ;; Hint lines
   ld c, #27
   ld b, #MENU_LEVEL_HINT1_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_level_hint1
   ld c, #3
   call sys_text_draw_string

   ld c, #29
   ld b, #MENU_LEVEL_HINT2_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_level_hint2
   ld c, #3
   call sys_text_draw_string

   ld c, #32
   ld b, #(MENU_LEVEL_HINT2_Y + 12)
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_level_esc
   ld c, #3
   call sys_text_draw_string

   ret

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
