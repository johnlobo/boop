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

;;===============================================================================
;; SPRITES
;;===============================================================================
.globl _g_palette0
.globl _s_font_0
.globl _s_small_numbers_00
.globl _s_small_numbers_01
.globl _s_small_numbers_02
.globl _s_small_numbers_03
.globl _s_small_numbers_04
.globl _s_small_numbers_05
.globl _s_small_numbers_06
.globl _s_small_numbers_07
.globl _s_small_numbers_08
.globl _s_small_numbers_09
.globl _s_big_numbers_00
.globl _s_big_numbers_01
.globl _s_big_numbers_02
.globl _s_big_numbers_03
.globl _s_big_numbers_04
.globl _s_big_numbers_05
.globl _s_big_numbers_06
.globl _s_big_numbers_07
.globl _s_big_numbers_08
.globl _s_big_numbers_09
.globl _s_gatito_walking_0
.globl _s_gatito_walking_1
.globl _s_gatito_walking_2
.globl _s_gatito_blue
.globl _s_gatito_orange
.globl _s_gato_blue
.globl _s_gato_orange
.globl _s_catty_0
.globl _s_catty_1
.globl _s_cat_0
.globl _s_cat_1
.globl _s_basket 
.globl _bg_header
.globl _bg_grid

.globl transparency_table



;;===============================================================================
;; CPCTELERA FUNCTIONS
;;===============================================================================
.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm
.globl cpct_drawSprite_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPalette_asm
.globl cpct_scanKeyboard_if_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitHalts_asm
.globl cpct_drawSolidBox_asm
.globl cpct_setSeed_mxor_asm
.globl cpct_isAnyKeyPressed_asm
.globl cpct_setInterruptHandler_asm
.globl cpct_waitVSYNC_asm
.globl _cpct_keyboardStatusBuffer
.globl cpct_waitVSYNCStart_asm
.globl cpct_getScreenToSprite_asm
.globl cpct_drawSpriteMaskedAlignedTable_asm
.globl cpct_pens2pixelPatternPairM0_asm
.globl sys_render_drawSpriteMaskedAlignedColorizeM0_asm
.globl cpct_getRandom_mxor_u8_asm
.globl cpct_px2byteM0_asm
.globl cpct_setPALColour_asm

;;===============================================================================
;; PUBLIC VARIBLES
;;===============================================================================

;; Keyboard constants
BUFFER_SIZE = 10
ZERO_KEYS_ACTIVATED = #0xFF

S_GATITO_W      = 5    ;; walking cat frame: 10px = 5 bytes
S_GATITO_H      = 14
S_GATITO_S_W    = 5    ;; small static cat: 9px = 4 bytes
S_GATITO_S_H    = 14
S_GATO_W        = 5    ;; big static cat: 10px = 5 bytes
S_GATO_H        = 17

S_CATTY_W = 5
S_CATTY_H = 17
S_CAT_W = 5
S_CAT_H = 17
S_BASKET_W = 18
S_BASKET_H = 74

BG_GRID_W = 44
BG_GRID_H = 148

BG_HEADER_W = 28
BG_HEADER_H = 16

;; Font constants
FONT_WIDTH = 2
FONT_HEIGHT = 9

;; Score constants
SCORE_NUM_BYTES = 4

;; Sprites sizes
S_SMALL_NUMBERS_WIDTH = 2
S_SMALL_NUMBERS_HEIGHT = 5

;; Sprites sizes
S_BIG_NUMBERS_WIDTH = 3
S_BIG_NUMBERS_HEIGHT = 13


;;===============================================================================
;; DEFINED MACROS
;;===============================================================================
.mdelete BeginStruct
.macro BeginStruct struct
    struct'_offset = 0
.endm

.mdelete Field
.macro Field struct, field, size
    struct'_'field = struct'_offset
    struct'_offset = struct'_offset + size
.endm

.mdelete EndStruct
.macro EndStruct struct
    sizeof_'struct = struct'_offset
.endm

.mdelete ld__hl__hl_with_a
.macro ld__hl__hl_with_a
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
.endm

.mdelete test_hl_0
.macro test_hl_0
    ld a, l
    or h
.endm

.mdelete m_msg_w_background
.macro m_msg_w_background bk
    ld h, #(bk)                         ;;
    ld l, #(bk)                         ;;
    call cpct_px2byteM0_asm             ;;
    ex af, af'                          ;;
    ld a, l                             ;;
    ex af, af'                          ;;
.endm

