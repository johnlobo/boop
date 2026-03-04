ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;
                              3 ;;  This program is free software: you can redistribute it and/or modify
                              4 ;;  it under the terms of the GNU Lesser General Public License as published by
                              5 ;;  the Free Software Foundation, either version 3 of the License, or
                              6 ;;  (at your option) any later version.
                              7 ;;
                              8 ;;  This program is distributed in the hope that it will be useful,
                              9 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             10 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             11 ;;  GNU Lesser General Public License for more details.
                             12 ;;
                             13 ;;  You should have received a copy of the GNU Lesser General Public License
                             14 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             15 ;;-------------------------------------------------------------------------------
                             16 
                             17 ;;------------------------------------------------------------------------------
                             18 ;; Global routines
                             19 ;;------------------------------------------------------------------------------
                             20 .globl sys_render_init
                             21 .globl sys_render_clear_buffer
                             22 .globl sys_render_draw_screen
                             23 .globl sys_render_draw_grid
                             24 
                             25 ;;===============================================================================
                             26 ;; PUBLIC CONSTANTS
                             27 ;;===============================================================================
                             28 
                             29 ;;===============================================================================
                             30 ;; MACRO
                             31 ;;===============================================================================
                             32 .mdelete ld_de_backbuffer
                             33 .macro ld_de_backbuffer
                             34    ld   a, (sys_render_back_buffer)          ;; DE = Pointer to start of the screen
                             35    ld   d, a
                             36    ld   e, #00
                             37 .endm
                             38 
                             39 .mdelete ld_de_frontbuffer
                             40 .macro ld_de_frontbuffer
                             41    ld   a, (sys_render_front_buffer)         ;; DE = Pointer to start of the screen
                             42    ld   d, a
                             43    ld   e, #00
                             44 .endm
                             45 
                             46 .mdelete m_screenPtr_backbuffer
                             47 .macro m_screenPtr_backbuffer X, Y
                             48    push hl
                             49    ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
                             50    ld a, (sys_render_back_buffer)
                             51    ld h, a
                             52    ld l, #0         
                             53    add hl, de
                             54    ex de, hl
                             55    pop hl
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             56 .endm
                             57 
                             58 .mdelete m_screenPtr_frontbuffer
                             59 .macro m_screenPtr_frontbuffer X, Y
                             60    push hl
                             61    ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
                             62    ld a, (sys_render_front_buffer)
                             63    ld h, a
                             64    ld l, #0         
                             65    add hl, de
                             66    ex de, hl
                             67    pop hl
                             68 .endm
                             69 
                             70 
                             71 .mdelete m_draw_blank_small_number
                             72 .macro m_draw_blank_small_number BACKGROUND
                             73    push de
                             74    push hl
                             75    ld c, #4
                             76    ld b, #5
                             77    ;;ld a, #0                                ;; Patern of solid box
                             78    ;;ld a, #0x33                             ;; Patern of solid box blue (12)
                             79    ld a, #BACKGROUND                         ;; Patern of solid box blue (12)
                             80    call cpct_drawSolidBox_asm
                             81    pop hl
                             82    pop de
                             83 .endm
