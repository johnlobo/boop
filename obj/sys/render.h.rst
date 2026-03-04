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
                             23 
                             24 ;;===============================================================================
                             25 ;; PUBLIC CONSTANTS
                             26 ;;===============================================================================
                             27 
                             28 ;;===============================================================================
                             29 ;; MACRO
                             30 ;;===============================================================================
                             31 .mdelete ld_de_backbuffer
                             32 .macro ld_de_backbuffer
                             33    ld   a, (sys_render_back_buffer)          ;; DE = Pointer to start of the screen
                             34    ld   d, a
                             35    ld   e, #00
                             36 .endm
                             37 
                             38 .mdelete ld_de_frontbuffer
                             39 .macro ld_de_frontbuffer
                             40    ld   a, (sys_render_front_buffer)         ;; DE = Pointer to start of the screen
                             41    ld   d, a
                             42    ld   e, #00
                             43 .endm
                             44 
                             45 .mdelete m_screenPtr_backbuffer
                             46 .macro m_screenPtr_backbuffer X, Y
                             47    push hl
                             48    ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
                             49    ld a, (sys_render_back_buffer)
                             50    ld h, a
                             51    ld l, #0         
                             52    add hl, de
                             53    ex de, hl
                             54    pop hl
                             55 .endm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             56 
                             57 .mdelete m_screenPtr_frontbuffer
                             58 .macro m_screenPtr_frontbuffer X, Y
                             59    push hl
                             60    ld de, #(80 * (Y / 8) + 2048 * (Y & 7) + X)
                             61    ld a, (sys_render_front_buffer)
                             62    ld h, a
                             63    ld l, #0         
                             64    add hl, de
                             65    ex de, hl
                             66    pop hl
                             67 .endm
                             68 
                             69 
                             70 .mdelete m_draw_blank_small_number
                             71 .macro m_draw_blank_small_number BACKGROUND
                             72    push de
                             73    push hl
                             74    ld c, #4
                             75    ld b, #5
                             76    ;;ld a, #0                                ;; Patern of solid box
                             77    ;;ld a, #0x33                             ;; Patern of solid box blue (12)
                             78    ld a, #BACKGROUND                         ;; Patern of solid box blue (12)
                             79    call cpct_drawSolidBox_asm
                             80    pop hl
                             81    pop de
                             82 .endm
