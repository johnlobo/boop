ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 
                              3 ;;
                              4 ;;  This program is free software: you can redistribute it and/or modify
                              5 ;;  it under the terms of the GNU Lesser General Public License as published by
                              6 ;;  the Free Software Foundation, either version 3 of the License, or
                              7 ;;  (at your option) any later version.
                              8 ;;
                              9 ;;  This program is distributed in the hope that it will be useful,
                             10 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             11 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             12 ;;  GNU Lesser General Public License for more details.
                             13 ;;
                             14 ;;  You should have received a copy of the GNU Lesser General Public License
                             15 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             16 ;;-------------------------------------------------------------------------------
                             17 
                             18 ;;===============================================================================
                             19 ;; SPRITES
                             20 ;;===============================================================================
                             21 .globl _g_palette0
                             22 .globl _s_font_0
                             23 .globl _s_small_numbers_00
                             24 .globl _s_small_numbers_01
                             25 .globl _s_small_numbers_02
                             26 .globl _s_small_numbers_03
                             27 .globl _s_small_numbers_04
                             28 .globl _s_small_numbers_05
                             29 .globl _s_small_numbers_06
                             30 .globl _s_small_numbers_07
                             31 .globl _s_small_numbers_08
                             32 .globl _s_small_numbers_09
                             33 .globl _s_big_numbers_00
                             34 .globl _s_big_numbers_01
                             35 .globl _s_big_numbers_02
                             36 .globl _s_big_numbers_03
                             37 .globl _s_big_numbers_04
                             38 .globl _s_big_numbers_05
                             39 .globl _s_big_numbers_06
                             40 .globl _s_big_numbers_07
                             41 .globl _s_big_numbers_08
                             42 .globl _s_big_numbers_09
                             43 .globl _s_catty_0
                             44 .globl _s_catty_1
                             45 .globl _s_cat_0  
                             46 .globl _s_cat_1  
                             47 .globl _s_basket 
                             48 .globl _bg_header
                             49 .globl _bg_grid
                             50 
                             51 .globl transparency_table
                             52 
                             53 
                             54 
                             55 ;;===============================================================================
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             56 ;; CPCTELERA FUNCTIONS
                             57 ;;===============================================================================
                             58 .globl cpct_disableFirmware_asm
                             59 .globl cpct_getScreenPtr_asm
                             60 .globl cpct_drawSprite_asm
                             61 .globl cpct_setVideoMode_asm
                             62 .globl cpct_setPalette_asm
                             63 .globl cpct_scanKeyboard_if_asm
                             64 .globl cpct_isKeyPressed_asm
                             65 .globl cpct_waitHalts_asm
                             66 .globl cpct_drawSolidBox_asm
                             67 .globl cpct_setSeed_mxor_asm
                             68 .globl cpct_isAnyKeyPressed_asm
                             69 .globl cpct_setInterruptHandler_asm
                             70 .globl cpct_waitVSYNC_asm
                             71 .globl _cpct_keyboardStatusBuffer
                             72 .globl cpct_waitVSYNCStart_asm
                             73 .globl cpct_getScreenToSprite_asm
                             74 .globl cpct_drawSpriteMaskedAlignedTable_asm
                             75 .globl cpct_pens2pixelPatternPairM0_asm
                             76 .globl sys_render_drawSpriteMaskedAlignedColorizeM0_asm
                             77 .globl cpct_getRandom_mxor_u8_asm
                             78 .globl cpct_px2byteM0_asm
                             79 .globl cpct_setPALColour_asm
                             80 
                             81 ;;===============================================================================
                             82 ;; PUBLIC VARIBLES
                             83 ;;===============================================================================
                             84 
                             85 ;; Keyboard constants
                     000A    86 BUFFER_SIZE = 10
                     00FF    87 ZERO_KEYS_ACTIVATED = #0xFF
                             88 
                     0005    89 S_CATTY_W = 5
                     0011    90 S_CATTY_H = 17
                     0005    91 S_CAT_W = 5
                     0011    92 S_CAT_H = 17
                     0012    93 S_BASKET_W = 18
                     004A    94 S_BASKET_H = 74
                             95 
                     002C    96 BG_GRID_W = 44
                     0094    97 BG_GRID_H = 148
                             98 
                     002C    99 BG_HEADER_W = 44
                     0014   100 BG_HEADER_H = 20    
                            101 
                            102 ;; Font constants
                     0002   103 FONT_WIDTH = 2
                     0009   104 FONT_HEIGHT = 9
                            105 
                            106 ;; Score constants
                     0004   107 SCORE_NUM_BYTES = 4
                            108 
                            109 ;; Sprites sizes
                     0002   110 S_SMALL_NUMBERS_WIDTH = 2
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                     0005   111 S_SMALL_NUMBERS_HEIGHT = 5
                            112 
                            113 ;; Sprites sizes
                     0003   114 S_BIG_NUMBERS_WIDTH = 3
                     000D   115 S_BIG_NUMBERS_HEIGHT = 13
                            116 
                            117 
                            118 ;;===============================================================================
                            119 ;; DEFINED MACROS
                            120 ;;===============================================================================
                            121 .mdelete BeginStruct
                            122 .macro BeginStruct struct
                            123     struct'_offset = 0
                            124 .endm
                            125 
                            126 .mdelete Field
                            127 .macro Field struct, field, size
                            128     struct'_'field = struct'_offset
                            129     struct'_offset = struct'_offset + size
                            130 .endm
                            131 
                            132 .mdelete EndStruct
                            133 .macro EndStruct struct
                            134     sizeof_'struct = struct'_offset
                            135 .endm
                            136 
                            137 .mdelete ld__hl__hl_with_a
                            138 .macro ld__hl__hl_with_a
                            139     ld a,(hl)
                            140     inc hl
                            141     ld h,(hl)
                            142     ld l,a
                            143 .endm
                            144 
                            145 .mdelete test_hl_0
                            146 .macro test_hl_0
                            147     ld a, l
                            148     or h
                            149 .endm
                            150 
                            151 .mdelete m_msg_w_background
                            152 .macro m_msg_w_background bk
                            153     ld h, #(bk)                         ;;
                            154     ld l, #(bk)                         ;;
                            155     call cpct_px2byteM0_asm             ;;
                            156     ex af, af'                          ;;
                            157     ld a, l                             ;;
                            158     ex af, af'                          ;;
                            159 .endm
                            160 
