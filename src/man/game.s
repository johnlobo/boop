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

.include "man/game.h.s"
.include "man/menu.h.s"
.include "man/match.h.s"
.include "man/help.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/render.h.s"
.include "sys/messages.h.s"
.include "sys/input.h.s"

.module game_system

;;
;; Game state constants
;;
GAME_STATE_MENU    = 0
GAME_STATE_PLAYING = 1
GAME_STATE_HELP    = 2

;;
;; Start of _DATA area
;;
.area _DATA

_game_state:         .db 0
_game_loaded_string: .asciz " GAME LOADED - V.003"

;;
;; Start of _CODE area
;;
.area _CODE

;;-----------------------------------------------------------------
;;
;; sys_game_init
;;
;;  Initializes the game: render, splash screen, random seed, menu
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
sys_game_init::
   call sys_render_init

   m_msg_w_background 3
   ld e, #6                            ;; x
   ld d, #78                           ;; y
   ld b, #44                           ;; h
   ld c, #60                           ;; w
   ld a, #1                            ;; wait for a key
   ld hl, #_game_loaded_string         ;; message
   call sys_messages_show

   ;; set random seed using hl from message show
   call cpct_setSeed_mxor_asm

   ;; Start in menu state
   xor a
   ld (_game_state), a
   call man_menu_init

   ret

;;-----------------------------------------------------------------
;;
;; sys_game_update
;;
;;  Main game update, called every frame. Dispatches by state.
;;  Input:
;;  Output:
;;  Modified: AF, BC, DE, HL
;;
sys_game_update::
   call cpct_waitVSYNC_asm

   ld a, (_game_state)
   or a
   jr z, _sgu_menu
   cp #GAME_STATE_PLAYING
   jr z, _sgu_playing
   jr _sgu_help

_sgu_menu:
   call man_menu_update

   ;; Check if player confirmed a selection
   ld a, (man_menu_confirmed)
   or a
   ret z                               ;; not confirmed yet, stay in menu

   ;; confirmed=3 means HELP was selected
   cp #3
   jr z, _sgu_goto_help

   ;; Transition to playing: init match (reads selection, resets players, draws screen)
   ld a, #GAME_STATE_PLAYING
   ld (_game_state), a
   call man_match_init
   ret

_sgu_goto_help:
   ld a, #GAME_STATE_HELP
   ld (_game_state), a
   call man_help_init
   ret

_sgu_playing:
   call man_match_update
   ret

_sgu_help:
   call man_help_update

   ;; Return to menu when done
   ld a, (man_help_done)
   or a
   ret z                               ;; not done yet, stay on help screen

   xor a
   ld (_game_state), a
   call man_menu_init
   ret
