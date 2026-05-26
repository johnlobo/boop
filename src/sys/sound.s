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
;;  Initializes Arkos Player 2 with the game subsong and SFX table.
;;  Call once at game start. Music does NOT start playing yet.
;;
sys_sound_init::
   ;; PLY_AKG_INIT(music_data_ptr, subsong) — __z88dk_callee
   ;; Stack convention: push subsong word, push music_ptr, call
   ld bc, #SUBSONG_GAME
   push bc
   ld hl, #_DRROLANDSOUNDTRACK_START
   push hl
   call _PLY_AKG_INIT
   ;; PLY_AKG_INITSOUNDEFFECTS(sfx_ptr) — __z88dk_fastcall via HL
   ld hl, #_FX_SOUNDEFFECTS
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
   ld bc, #SUBSONG_GAME
   push bc
   ld hl, #_DRROLANDSOUNDTRACK_START
   push hl
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
;;  SFX_END (255) switches to the WIN_SONG subsong instead.
;;
;;  Input:  A = SFX_xxx id (SFX_CURSOR/KITTEN/CAT/EJECT/LINE) or SFX_END
;;  Output: -
;;  Modified: AF, BC, DE, HL
;;
sys_sound_play_sfx::
   cp #SFX_END
   jr z, _ssps_win
   ;; PLY_AKG_PLAYSOUNDEFFECT(sfx_id, channel, volume) — __z88dk_callee
   ;; Push: packed word (B=volume, C=channel), then word (H=0, L=sfx_id)
   ld b, #0            ;; volume = 0
   ld c, #SND_CH_B     ;; channel = B
   push bc
   ld h, #0
   ld l, a             ;; L = sfx_id
   push hl
   call _PLY_AKG_PLAYSOUNDEFFECT
   ret
_ssps_win:
   ;; Switch to win jingle subsong
   ld bc, #SUBSONG_WIN
   push bc
   ld hl, #_DRROLANDSOUNDTRACK_START
   push hl
   call _PLY_AKG_INIT
   ret
