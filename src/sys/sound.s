;;-----------------------------LICENSE NOTICE------------------------------------
;;  GNU LGPL v3 — see main source for full license text
;;-------------------------------------------------------------------------------

.include "sys/sound.h.s"
.include "../common.h.s"

.module sys_sound

;;
;; Start of _DATA area
;;
.area _DATA

_snd_music_active:: .db 0    ;; 1 = interrupt handler calls PLY_AKG_PLAY each frame
_snd_lines_found::  .db 0    ;; set by _match_check_lines when a conversion occurs

;;
;; Start of _CODE area
;;
.area _CODE

;;-----------------------------------------------------------------
;;
;; sys_sound_init
;;
;;  Initializes Arkos Tracker 3 AKG with the game subsong and SFX table.
;;  Call once at game start. Music does NOT start playing yet.
;;
sys_sound_init::
   ;; AT3 ABI: HL = music, A = subsong.
   ld hl, #_START
   ld a, #SUBSONG_GAME
   call _PLY_AKG_INIT
   ld hl, #_BOOP_FXSOUNDEFFECTS
   call _PLY_AKG_INITSOUNDEFFECTS
   xor a
   ld (_snd_music_active), a
   ld (_snd_lines_found), a
   ret

;;-----------------------------------------------------------------
;;
;; sys_sound_start_music
;;
;;  (Re)initializes with the game subsong and enables playback.
;;
sys_sound_start_music::
   ld hl, #_START
   ld a, #SUBSONG_GAME
   call _PLY_AKG_INIT
   ld a, #1
   ld (_snd_music_active), a
   ret

;;-----------------------------------------------------------------
;;
;; sys_sound_start_menu_music
;;
;;  Switches to the menu subsong and enables playback.
;;  Call when entering any menu screen (main menu, help, AI select).
;;
sys_sound_start_menu_music::
   ld hl, #_START
   ld a, #SUBSONG_MENU
   call _PLY_AKG_INIT
   ld a, #1
   ld (_snd_music_active), a
   ret

;;-----------------------------------------------------------------
;; Starts the one-position victory fanfare.
;;
sys_sound_start_win_music::
   ld hl, #_START
   ld a, #SUBSONG_WIN
   call _PLY_AKG_INIT
   ld a, #1
   ld (_snd_music_active), a
   ret

;;-----------------------------------------------------------------
;; Starts the one-position defeat fanfare.
;;
sys_sound_start_lose_music::
   ld hl, #_START
   ld a, #SUBSONG_LOSE
   call _PLY_AKG_INIT
   ld a, #1
   ld (_snd_music_active), a
   ret

;;-----------------------------------------------------------------
;;
;; sys_sound_stop
;;
;;  Stops playback immediately.
;;
sys_sound_stop::
   xor a
   ld (_snd_music_active), a   ;; disable interrupt calls BEFORE stopping player
   call _PLY_AKG_STOP
   ret

;;-----------------------------------------------------------------
;;
;; sys_sound_play_sfx
;;
;;  Triggers a sound effect on channel B.
;;
;;  Input:  A = SFX_xxx id (SFX_CURSOR/KITTEN/CAT/EJECT/LINE)
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
sys_sound_play_sfx::
   or a
   ret z                 ;; SFX id 0 means that this event has no assigned sound
   ;; AT3 ABI: A = SFX id, B = inverted volume, C = channel.
   ld b, #0            ;; volume = 0
   ld c, #SND_CH_B     ;; channel = B
   call _PLY_AKG_PLAYSOUNDEFFECT
   ret
