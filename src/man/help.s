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
.include "sys/text.h.s"
.include "sys/input.h.s"

.module man_help

;;
;; Color constants (match menu conventions)
;;
HELP_COLOR_TITLE   = 1   ;; Bright Yellow  – section headers
HELP_COLOR_BODY    = 0   ;; Bright White   – body text

;;
;; Start of _DATA area
;;
.area _DATA

man_help_done:: .db 0   ;; set to 1 when player presses Enter to exit

;; Section headers
_help_str_title:    .asciz "BOOP"
_help_str_goal_hdr: .asciz "GOAL"
_help_str_ctrl_hdr: .asciz "CONTROLS"
_help_str_back:     .asciz "PRESS ENTER TO CONTINUE"

;; Goal lines
_help_str_goal1: .asciz "PLACE CATS AND KITTENS"
_help_str_goal2: .asciz "ON A 6X6 BOARD."
_help_str_goal3: .asciz "FILL A ROW, COLUMN OR"
_help_str_goal4: .asciz "DIAGONAL TO WIN."

;; Control lines  (label left-aligned, action right of gap)
_help_str_ctrl1: .asciz "ARROWS   MOVE CURSOR"
_help_str_ctrl2: .asciz "SPACE    TOGGLE PIECE"
_help_str_ctrl3: .asciz "ENTER    PLACE PIECE"

;;
;; Start of _CODE area
;;
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_help_draw
;;
;;  Draws the static help screen content.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
man_help_draw:

   ;; ---- Title ------------------------------------------------
   ;; "BOOP"  centered: 4 chars * 2 bytes = 8 bytes  x=(80-8)/2=36  y=15
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 36, 15
   ld hl, #_help_str_title
   ld c, #HELP_COLOR_TITLE
   call sys_text_draw_string

   ;; ---- Goal section header ----------------------------------
   ;; "GOAL"  4 chars * 2 = 8 bytes  x=36  y=40
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 36, 40
   ld hl, #_help_str_goal_hdr
   ld c, #HELP_COLOR_TITLE
   call sys_text_draw_string

   ;; "PLACE CATS AND KITTENS"  22 chars * 2 = 44 bytes  x=(80-44)/2=18  y=55
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 18, 55
   ld hl, #_help_str_goal1
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; "ON A 6X6 BOARD."  16 chars * 2 = 32 bytes  x=(80-32)/2=24  y=67
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 24, 67
   ld hl, #_help_str_goal2
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; "FILL A ROW, COLUMN OR"  21 chars * 2 = 42 bytes  x=(80-42)/2=19  y=79
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 19, 79
   ld hl, #_help_str_goal3
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; "DIAGONAL TO WIN."  16 chars * 2 = 32 bytes  x=24  y=91
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 24, 91
   ld hl, #_help_str_goal4
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; ---- Controls section header ------------------------------
   ;; "CONTROLS"  8 chars * 2 = 16 bytes  x=(80-16)/2=32  y=115
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 32, 115
   ld hl, #_help_str_ctrl_hdr
   ld c, #HELP_COLOR_TITLE
   call sys_text_draw_string

   ;; "ARROWS   MOVE CURSOR"  20 chars * 2 = 40 bytes  x=(80-40)/2=20  y=130
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 20, 130
   ld hl, #_help_str_ctrl1
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; "SPACE    TOGGLE PIECE"  21 chars * 2 = 42 bytes  x=19  y=142
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 19, 142
   ld hl, #_help_str_ctrl2
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; "ENTER    PLACE PIECE"  20 chars * 2 = 40 bytes  x=20  y=154
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 20, 154
   ld hl, #_help_str_ctrl3
   ld c, #HELP_COLOR_BODY
   call sys_text_draw_string

   ;; ---- Footer prompt ----------------------------------------
   ;; "PRESS ENTER TO CONTINUE"  23 chars * 2 = 46 bytes  x=(80-46)/2=17  y=180
   cpctm_screenPtr_asm DE, CPCT_VMEM_START_ASM, 17, 180
   ld hl, #_help_str_back
   ld c, #HELP_COLOR_TITLE
   call sys_text_draw_string

   ret

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

   call sys_render_clear_buffer
   call man_help_draw

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
