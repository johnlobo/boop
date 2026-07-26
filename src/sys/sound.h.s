;;-----------------------------LICENSE NOTICE------------------------------------
;;  GNU LGPL v3 — see main source for full license text
;;-------------------------------------------------------------------------------

;;===============================================================================
;; sys/sound.h.s — Arkos Tracker 3 AKG sound engine interface
;;
;; Music data, temporary SFX and player are compiled together in
;; src/audio/BoopAudioAT3.s.
;; PLY_AKG_PLAY is called every frame from interrupt handler 5.
;;===============================================================================

;;
;; Arkos Tracker 3 AKG symbols (defined in src/audio/BoopAudioAT3.s)
;;
.globl _PLY_AKG_PLAY
.globl _PLY_AKG_INIT
.globl _PLY_AKG_STOP
.globl _PLY_AKG_INITSOUNDEFFECTS
.globl _PLY_AKG_PLAYSOUNDEFFECT
.globl _START
.globl _BOOP_FXSOUNDEFFECTS

;;
;; Subsong indices (must match the AT3 BoopAkg export order)
;;
SUBSONG_GAME = 1
SUBSONG_MENU = 0
SUBSONG_WIN  = 2
SUBSONG_LOSE = 3

;;
;; AY channel indices for PLY_AKG_PLAYSOUNDEFFECT
;;
SND_CH_A = 0
SND_CH_B = 1
SND_CH_C = 2

;;
;; sys/sound.s public symbols
;;
.globl _snd_music_active
.globl _snd_lines_found
.globl sys_sound_init
.globl sys_sound_stop
.globl sys_sound_start_music
.globl sys_sound_start_menu_music
.globl sys_sound_start_win_music
.globl sys_sound_start_lose_music
.globl sys_sound_play_sfx
