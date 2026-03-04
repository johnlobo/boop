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
                             17 .module system_system
                             18 
                             19 
                             20 ;;===============================================================================
                             21 ;; PUBLIC VARIABLES
                             22 ;;===============================================================================
                             23 .globl nInterrupt
                             24 
                             25 ;;===============================================================================
                             26 ;; PUBLIC MACROS
                             27 ;;===============================================================================
                             28 .mdelete m_inc_nInterrupt
                             29 .macro m_inc_nInterrupt
                             30     ld a, (nInterrupt)
                             31     inc a
                             32     ld (nInterrupt), a 
                             33 .endm
                             34 
                             35 .mdelete m_reset_nInterrupt
                             36 .macro m_reset_nInterrupt
                             37     xor a
                             38     ld (nInterrupt), a 
                             39 .endm
                             40 
                             41 
                             42 ;;===============================================================================
                             43 ;; PUBLIC METHODS
                             44 ;;===============================================================================
                             45 .globl sys_system_disable_firmware
