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
.include "sys/text.h.s"
.include "sys/input.h.s"

.module man_menu

;;
;; Start of _DATA area
;;
.area _DATA

_menu_opt1_string:  .asciz "ONE PLAYER"
_menu_opt2_string:  .asciz "TWO PLAYERS"

man_menu_selected::  .db 0      ;; 0 = ONE PLAYER, 1 = TWO PLAYERS
man_menu_confirmed:: .db 0      ;; 0 = not confirmed, 1 = ONE PLAYER, 2 = TWO PLAYERS

_menu_key_debounce: .db 0       ;; 1 if a key was held last frame

;;
;; Start of _CODE area
;;
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_menu_draw
;;
;;  Draws both menu options. Selected option in yellow, other in white.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_menu_draw::
   ;; Draw option 1: ONE PLAYER  (x=31 bytes, y=90 px)
   ld de, #CPCT_VMEM_START_ASM
   ld c, #31
   ld b, #90
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_opt1_string
   ld a, (man_menu_selected)
   or a
   jr nz, _draw_opt1_white
   ld c, #1                          ;; Bright Yellow = selected
   jr _draw_opt1
_draw_opt1_white:
   ld c, #0                          ;; Bright White = unselected
_draw_opt1:
   call sys_text_draw_string

   ;; Draw option 2: TWO PLAYERS  (x=30 bytes, y=110 px)
   ld de, #CPCT_VMEM_START_ASM
   ld c, #30
   ld b, #110
   call cpct_getScreenPtr_asm
   ex de, hl
   ld hl, #_menu_opt2_string
   ld a, (man_menu_selected)
   or a
   jr z, _draw_opt2_white
   ld c, #1                          ;; Bright Yellow = selected
   jr _draw_opt2
_draw_opt2_white:
   ld c, #0                          ;; Bright White = unselected
_draw_opt2:
   call sys_text_draw_string

   ret

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
   ld (_menu_key_debounce), a

   call sys_render_clear_buffer
   call man_menu_draw

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
   ;; Debounce: if a key was held last frame, wait for full release
   ld a, (_menu_key_debounce)
   or a
   jr z, _mmu_check_keys
   call cpct_isAnyKeyPressed_asm
   or a
   ret nz                            ;; still held, do nothing this frame
   xor a
   ld (_menu_key_debounce), a
   ret

_mmu_check_keys:
   ;; Cursor Up: move selection up (toggle between 0 and 1)
   ld hl, #Key_CursorUp
   call cpct_isKeyPressed_asm
   jr z, _mmu_check_down
   ld a, (man_menu_selected)
   xor #1
   ld (man_menu_selected), a
   call man_menu_draw
   jr _mmu_set_debounce

_mmu_check_down:
   ;; Cursor Down: move selection down (toggle between 0 and 1)
   ld hl, #Key_CursorDown
   call cpct_isKeyPressed_asm
   jr z, _mmu_check_enter
   ld a, (man_menu_selected)
   xor #1
   ld (man_menu_selected), a
   call man_menu_draw
   jr _mmu_set_debounce

_mmu_check_enter:
   ;; Enter: confirm current selection
   ld hl, #Key_Return
   call cpct_isKeyPressed_asm
   jr z, _mmu_done
   ld a, (man_menu_selected)
   inc a                             ;; 1 = ONE PLAYER, 2 = TWO PLAYERS
   ld (man_menu_confirmed), a

_mmu_set_debounce:
   ld a, #1
   ld (_menu_key_debounce), a

_mmu_done:
   ret
