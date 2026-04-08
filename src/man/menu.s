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
_menu_opt3_string:  .asciz "HELP"
_menu_hint1_string: .asciz "ARROWS - MOVE"
_menu_hint2_string: .asciz "ENTER - SELECT"

man_menu_selected::  .db 0      ;; 0 = ONE PLAYER, 1 = TWO PLAYERS, 2 = HELP
man_menu_confirmed:: .db 0      ;; 0 = not confirmed, 1 = ONE PLAYER, 2 = TWO PLAYERS, 3 = HELP

_menu_key_debounce: .db 0       ;; 1 if a key was held last frame

;; Walking cat animation state
_menu_anim_x:      .db 0        ;; current X position in bytes (0..75)
_menu_anim_tick:   .db 0        ;; frame counter (0..MENU_ANIM_PERIOD-1)
_menu_anim_phase:  .db 0        ;; walk cycle index (0..3)
_menu_anim_state:  .db 0        ;; 0=WALKING, 1=STOPPED
_menu_walk_steps:  .db 20       ;; X-moves remaining before stopping
_menu_stop_timer:  .db 0        ;; stop units remaining (each unit = 4 frames)
_menu_stop_subtick:.db 0        ;; 0..3 sub-tick to divide frames by 4
_menu_anim_sprites:              ;; sprite table: cycle = 0,1,2,1
    .dw _s_gatito_walking_0
    .dw _s_gatito_walking_1
    .dw _s_gatito_walking_2
    .dw _s_gatito_walking_1

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
   call sys_render_draw_header             ;; title at top (X=26, Y=2, yellow)

   ;; Cats between header (ends Y=17) and menu (starts Y=90), bottom-aligned at Y=62
   ;; Layout: big-orange(5B) +2 small-blue(4B) +2 small-orange(4B) +2 big-blue(5B) = 24B
   ;; Centered: (80-24)/2=28  →  X=28, 35, 41, 47
   ;; Big cats (17px tall): Y=46   Small cats (14px tall): Y=49

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 28, 46   ;; big orange cat
   ld bc, #_s_gato_orange
   ld__ixl S_GATO_W
   ld__ixh S_GATO_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 35, 49   ;; small blue cat
   ld bc, #_s_gatito_blue
   ld__ixl S_GATITO_S_W
   ld__ixh S_GATITO_S_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 41, 49   ;; small orange cat
   ld bc, #_s_gatito_orange
   ld__ixl S_GATITO_S_W
   ld__ixh S_GATITO_S_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 47, 46   ;; big blue cat
   ld bc, #_s_gato_blue
   ld__ixl S_GATO_W
   ld__ixh S_GATO_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm

   ;; Draw option 1: ONE PLAYER  (x=31 bytes, y=90 px)
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 31, 90  ;; Get pointer to video memory for drawing the first option of the menu
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
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 30, 110  ;; Get pointer to video memory for drawing the second option of the menu
   ld hl, #_menu_opt2_string
   ld a, (man_menu_selected)
   cp #1
   jr nz, _draw_opt2_white
   ld c, #1                          ;; Bright Yellow = selected
   jr _draw_opt2
_draw_opt2_white:
   ld c, #0                          ;; Bright White = unselected
_draw_opt2:
   call sys_text_draw_string

   ;; Draw option 3: HELP  (x=34 bytes, y=130 px)
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 34, 130  ;; Get pointer to video memory for drawing the third option of the menu
   ld hl, #_menu_opt3_string
   ld a, (man_menu_selected)
   cp #2
   jr nz, _draw_opt3_white
   ld c, #1                          ;; Bright Yellow = selected
   jr _draw_opt3
_draw_opt3_white:
   ld c, #0                          ;; Bright White = unselected
_draw_opt3:
   call sys_text_draw_string

   ;; Hint line 1: "ARROWS - MOVE"  13 chars * 2 = 26 bytes  x=(80-26)/2=27  y=175
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 27, 175
   ld hl, #_menu_hint1_string
   ld c, #3                          ;; Blue = subdued hint
   call sys_text_draw_string

   ;; Hint line 2: "ENTER   SELECT"  14 chars * 2 = 28 bytes  x=(80-28)/2=26  y=187
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 26, 187
   ld hl, #_menu_hint2_string
   ld c, #3                          ;; Blue = subdued hint
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
   ld (_menu_anim_x), a
   ld (_menu_anim_tick), a
   ld (_menu_anim_phase), a
   ld (_menu_anim_state), a
   ld (_menu_stop_subtick), a
   ld a, #20
   ld (_menu_walk_steps), a
   xor a

   call sys_render_clear_buffer
   call man_menu_draw
   call _menu_draw_gatito

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
MENU_CAT_Y       = 158  ;; Y position of the walking cat (px)
MENU_ANIM_PERIOD = 16   ;; frames per animation step (~3 changes/sec at 50Hz)

man_menu_update::
   call _menu_update_gatito        ;; animate cat every frame

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
   ;; Cursor Up: move selection up, wrapping 0 -> 2
   ld hl, #Key_CursorUp
   call cpct_isKeyPressed_asm
   jr z, _mmu_check_down
   ld a, (man_menu_selected)
   or a
   jr z, _mmu_up_wrap
   dec a
   jr _mmu_up_done
_mmu_up_wrap:
   ld a, #2
_mmu_up_done:
   ld (man_menu_selected), a
   call man_menu_draw
   jr _mmu_set_debounce

_mmu_check_down:
   ;; Cursor Down: move selection down, wrapping 2 -> 0
   ld hl, #Key_CursorDown
   call cpct_isKeyPressed_asm
   jr z, _mmu_check_enter
   ld a, (man_menu_selected)
   cp #2
   jr z, _mmu_down_wrap
   inc a
   jr _mmu_down_done
_mmu_down_wrap:
   xor a
_mmu_down_done:
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

;;-----------------------------------------------------------------
;;
;; _menu_update_gatito
;;
;;  Called every frame. Every MENU_ANIM_PERIOD frames: erases old
;;  sprite, advances X and phase, draws new sprite.
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
_menu_update_gatito:
   ld a, (_menu_anim_state)
   or a
   jr nz, _mug_stopped              ;; state=1 → STOPPED

   ;; ── WALKING state ────────────────────────────────────────────
   ld a, (_menu_anim_tick)
   inc a
   cp #MENU_ANIM_PERIOD
   jr nc, _mug_walk_step
   ld (_menu_anim_tick), a
   ret

_mug_walk_step:
   xor a
   ld (_menu_anim_tick), a

   ;; Erase old position (full walking width)
   ld a, (_menu_anim_x)
   ld c, a
   ld b, #MENU_CAT_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld b, #S_GATITO_H
   ld c, #S_GATITO_W
   xor a
   call cpct_drawSolidBox_asm

   ;; Advance phase (0→1→2→3→0)
   ld a, (_menu_anim_phase)
   inc a
   and #3
   ld (_menu_anim_phase), a

   ;; On even phases: decrement walk steps and advance X
   and #1
   jr nz, _mug_draw_walking         ;; odd phase: skip

   ld a, (_menu_walk_steps)
   dec a
   ld (_menu_walk_steps), a
   jr z, _mug_stop                  ;; steps exhausted: stop

   ld a, (_menu_anim_x)
   inc a
   cp #(80 - S_GATITO_W + 1)        ;; wrap at right edge
   jr c, _mug_x_ok
   xor a
_mug_x_ok:
   ld (_menu_anim_x), a

_mug_draw_walking:
   jp _menu_draw_gatito              ;; tail call

_mug_stop:
   ;; → STOPPED: draw static cat, load random timer
   ld a, #1
   ld (_menu_anim_state), a
   xor a
   ld (_menu_stop_subtick), a
   call cpct_getRandom_mxor_u8_asm
   ld a, l
   and #63                          ;; 0..63
   add a, #50                       ;; 50..113 units × 4 frames = 200..452 frames ≈ 4–9 sec
   ld (_menu_stop_timer), a
   jp _menu_draw_gatito_stopped      ;; tail call

   ;; ── STOPPED state ────────────────────────────────────────────
_mug_stopped:
   ;; Advance sub-tick (0..3); only decrement timer every 4 frames
   ld a, (_menu_stop_subtick)
   inc a
   and #3
   ld (_menu_stop_subtick), a
   ret nz                            ;; not on a timer tick yet

   ld hl, #_menu_stop_timer
   ld a, (hl)
   dec a
   ld (hl), a
   ret nz                            ;; still waiting

   ;; Timer done → WALKING: erase stopped sprite, load random steps
   ld a, (_menu_anim_x)
   ld c, a
   ld b, #MENU_CAT_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl
   ld b, #S_GATITO_H
   ld c, #S_GATITO_W                ;; erase 5B to cover full walking width too
   xor a
   call cpct_drawSolidBox_asm

   call cpct_getRandom_mxor_u8_asm
   ld a, l
   and #7                           ;; 0..7
   add a, #20                       ;; 20..27 X-movements ≈ half-screen per stretch
   ld (_menu_walk_steps), a
   xor a
   ld (_menu_anim_state), a
   ld (_menu_anim_tick), a

   jp _menu_draw_gatito              ;; tail call: first walking frame

;;-----------------------------------------------------------------
;;
;; _menu_draw_gatito
;;
;;  Draws the gatito sprite at current _menu_anim_x / _menu_anim_phase.
;;  Input:  -
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
;;-----------------------------------------------------------------
;;
;; _menu_draw_gatito_stopped
;;
;;  Draws _s_gatito_orange (small static cat) at current position.
;;
_menu_draw_gatito_stopped:
   ld a, (_menu_anim_x)
   ld c, a
   ld b, #MENU_CAT_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm
   ex de, hl                        ;; DE = destination
   ld bc, #_s_gatito_orange
   ld__ixl S_GATITO_S_W
   ld__ixh S_GATITO_S_H
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm
   ret

;;-----------------------------------------------------------------
;;
;; _menu_draw_gatito
;;
_menu_draw_gatito:
   ;; Compute screen destination → DE
   ld a, (_menu_anim_x)
   ld c, a
   ld b, #MENU_CAT_Y
   ld de, #CPCT_VMEM_START_ASM
   call cpct_getScreenPtr_asm       ;; HL = screen address
   ex de, hl                        ;; DE = destination
   push de

   ;; Look up sprite pointer for current phase
   ld a, (_menu_anim_phase)
   add a, a                         ;; *2 (word size)
   ld c, a
   ld b, #0
   ld hl, #_menu_anim_sprites
   add hl, bc                       ;; HL = &_menu_anim_sprites[phase]
   ld__hl__hl_with_a                ;; HL = sprite ptr
   ld b, h
   ld c, l                          ;; BC = sprite ptr

   ld__ixl S_GATITO_W
   ld__ixh S_GATITO_H
   pop de                           ;; DE = destination
   ld hl, #transparency_table
   call cpct_drawSpriteMaskedAlignedTable_asm
   ret
