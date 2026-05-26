;;-----------------------------LICENSE NOTICE------------------------------------
;;  GNU LGPL v3 — see main source for full license text
;;-------------------------------------------------------------------------------

;;===============================================================================
;; sys/sound.h.s — Arkos Player 2 (AKG) sound engine interface
;;
;; Music data and player are compiled together in src/audio/At2FilesAKG.s.
;; PLY_AKG_PLAY is called every frame from interrupt handler 5.
;;===============================================================================

;;
;; Arkos Player 2 symbols (defined in src/audio/At2FilesAKG.s)
;;
.globl _PLY_AKG_PLAY
.globl _PLY_AKG_INIT
.globl _PLY_AKG_STOP
.globl _PLY_AKG_INITSOUNDEFFECTS
.globl _PLY_AKG_PLAYSOUNDEFFECT
.globl _DRROLANDSOUNDTRACK_START
.globl _FX_SOUNDEFFECTS

;;
;; Subsong indices (must match the .aks compilation order in At2FilesAKG.s)
;;
SUBSONG_GAME    = 0    ;; background game music
SUBSONG_WIN     = 4    ;; win jingle
SUBSONG_SILENCE = 6    ;; silent subsong

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
