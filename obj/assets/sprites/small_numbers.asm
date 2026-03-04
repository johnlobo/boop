;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module small_numbers
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _s_small_numbers_09
	.globl _s_small_numbers_08
	.globl _s_small_numbers_07
	.globl _s_small_numbers_06
	.globl _s_small_numbers_05
	.globl _s_small_numbers_04
	.globl _s_small_numbers_03
	.globl _s_small_numbers_02
	.globl _s_small_numbers_01
	.globl _s_small_numbers_00
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
_s_small_numbers_00:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_01:
	.db #0x55	; 85	'U'
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
_s_small_numbers_02:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_03:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x55	; 85	'U'
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_04:
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
_s_small_numbers_05:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_06:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_07:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
_s_small_numbers_08:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
_s_small_numbers_09:
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xaa	; 170
	.db #0xff	; 255
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.db #0x00	; 0
	.db #0xaa	; 170
	.area _INITIALIZER
	.area _CABS (ABS)
