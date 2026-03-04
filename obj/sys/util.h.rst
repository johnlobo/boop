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
                             17 
                             18 ;;===============================================================================
                             19 ;; PUBLIC VARIABLES
                             20 ;;===============================================================================
                             21 .globl string_buffer
                             22 
                             23 ;;===============================================================================
                             24 ;; PUBLIC METHODS
                             25 ;;===============================================================================
                             26 .globl sys_util_h_times_e
                             27 .globl sys_util_hl_div_c
                             28 .globl sys_util_BCD_GetEnd
                             29 .globl sys_util_BCD_Add
                             30 .globl sys_util_BCD_Compare
                             31 .globl sys_util_get_random_number
                             32 .globl sys_util_delay
                             33 .globl sys_util_fadeOut
                             34 .globl sys_util_fadeIn
                             35 .globl sys_util_temblor
                             36 .globl sys_util_count_set_bits
                             37 .globl sys_utiL_reduce_a
