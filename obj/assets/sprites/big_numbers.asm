;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module big_numbers
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _s_big_numbers_09
	.globl _s_big_numbers_08
	.globl _s_big_numbers_07
	.globl _s_big_numbers_06
	.globl _s_big_numbers_05
	.globl _s_big_numbers_04
	.globl _s_big_numbers_03
	.globl _s_big_numbers_02
	.globl _s_big_numbers_01
	.globl _s_big_numbers_00
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
_s_big_numbers_00:
	.db #0xf3	; 243
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xf7	; 247
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_01:
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xa2	; 162
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x51	; 81	'Q'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x51	; 81	'Q'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x51	; 81	'Q'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x3f	; 63
_s_big_numbers_02:
	.db #0xfb	; 251
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0x3f	; 63
	.db #0x3f	; 63
	.db #0xff	; 255
	.db #0x2a	; 42
	.db #0x00	; 0
	.db #0xf7	; 247
	.db #0x2a	; 42
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_03:
	.db #0xfb	; 251
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_04:
	.db #0xf3	; 243
	.db #0x51	; 81	'Q'
	.db #0xaa	; 170
	.db #0xf7	; 247
	.db #0x7f	; 127
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x7f	; 127
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x7f	; 127
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x7f	; 127
	.db #0xb7	; 183
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x3f	; 63
_s_big_numbers_05:
	.db #0xf3	; 243
	.db #0xf3	; 243
	.db #0xaa	; 170
	.db #0xf7	; 247
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x3f	; 63
	.db #0x3f	; 63
	.db #0xff	; 255
	.db #0x2a	; 42
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x2a	; 42
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_06:
	.db #0xf3	; 243
	.db #0xf3	; 243
	.db #0xaa	; 170
	.db #0xf7	; 247
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x3f	; 63
	.db #0x3f	; 63
	.db #0xff	; 255
	.db #0x2a	; 42
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_07:
	.db #0xfb	; 251
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xa2	; 162
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x51	; 81	'Q'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x51	; 81	'Q'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x3f	; 63
_s_big_numbers_08:
	.db #0xfb	; 251
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0x55	; 85	'U'
	.db #0xff	; 255
	.db #0x3f	; 63
	.db #0x55	; 85	'U'
	.db #0xff	; 255
	.db #0x2a	; 42
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xf7	; 247
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x15	; 21
	.db #0x3f	; 63
	.db #0x3f	; 63
_s_big_numbers_09:
	.db #0xfb	; 251
	.db #0xf3	; 243
	.db #0xa2	; 162
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xb7	; 183
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x3f	; 63
	.area _INITIALIZER
	.area _CABS (ABS)
