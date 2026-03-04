ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;  This program is free software: you can redistribute it and/or modify
                              3 ;;  it under the terms of the GNU Lesser General Public License as published by
                              4 ;;  the Free Software Foundation, either version 3 of the License, or
                              5 ;;  (at your option) any later version.
                              6 ;;
                              7 ;;  This program is distributed in the hope that it will be useful,
                              8 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                              9 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             10 ;;  GNU Lesser General Public License for more details.
                             11 ;;
                             12 ;;  You should have received a copy of the GNU Lesser General Public License
                             13 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             14 ;;-------------------------------------------------------------------------------
                             15 
                             16 ;;===============================================================================
                             17 ;; PUBLIC VARIABLES
                             18 ;;===============================================================================
                             19 .globl aux_txt
                             20 
                             21 ;;===============================================================================
                             22 ;; PUBLIC METHODS
                             23 ;;===============================================================================
                             24 .globl sys_text_str_length
                             25 .globl sys_text_str_copy
                             26 .globl sys_text_str_cmp
                             27 .globl sys_text_draw_char
                             28 .globl sys_text_draw_string
                             29 .globl sys_text_num2str8
                             30 .globl sys_text_reset_aux_txt
                             31 .globl sys_text_draw_small_number
