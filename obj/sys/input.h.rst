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
                             18 ;;------------------------------------------------------------------------------
                             19 ;; Global variables
                             20 ;;------------------------------------------------------------------------------
                             21 ;;.globl sys_input_key_actions
                             22 
                             23 ;;------------------------------------------------------------------------------
                             24 ;; Global routines
                             25 ;;------------------------------------------------------------------------------
                             26 .globl sys_input_init
                             27 .globl sys_input_clean_buffer
                             28 .globl sys_input_wait4anykey
                             29 .globl sys_input_waitKeyPressed
                             30 .globl sys_input_getKeyPressed
                             31 
                             32 .globl sys_input_update
                             33 
                             34 ;;.globl sys_input_main_screen_keys
                             35 ;;.globl sys_input_update
                             36 ;;.globl sys_input_score_entry_update
                             37 
