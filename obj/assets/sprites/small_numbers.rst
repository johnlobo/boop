                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module small_numbers
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _s_small_numbers_09
                             12 	.globl _s_small_numbers_08
                             13 	.globl _s_small_numbers_07
                             14 	.globl _s_small_numbers_06
                             15 	.globl _s_small_numbers_05
                             16 	.globl _s_small_numbers_04
                             17 	.globl _s_small_numbers_03
                             18 	.globl _s_small_numbers_02
                             19 	.globl _s_small_numbers_01
                             20 	.globl _s_small_numbers_00
                             21 ;--------------------------------------------------------
                             22 ; special function registers
                             23 ;--------------------------------------------------------
                             24 ;--------------------------------------------------------
                             25 ; ram data
                             26 ;--------------------------------------------------------
                             27 	.area _DATA
                             28 ;--------------------------------------------------------
                             29 ; ram data
                             30 ;--------------------------------------------------------
                             31 	.area _INITIALIZED
                             32 ;--------------------------------------------------------
                             33 ; absolute external ram data
                             34 ;--------------------------------------------------------
                             35 	.area _DABS (ABS)
                             36 ;--------------------------------------------------------
                             37 ; global & static initialisations
                             38 ;--------------------------------------------------------
                             39 	.area _HOME
                             40 	.area _GSINIT
                             41 	.area _GSFINAL
                             42 	.area _GSINIT
                             43 ;--------------------------------------------------------
                             44 ; Home
                             45 ;--------------------------------------------------------
                             46 	.area _HOME
                             47 	.area _HOME
                             48 ;--------------------------------------------------------
                             49 ; code
                             50 ;--------------------------------------------------------
                             51 	.area _CODE
                             52 	.area _CODE
   64EE                      53 _s_small_numbers_00:
   64EE FF                   54 	.db #0xff	; 255
   64EF AA                   55 	.db #0xaa	; 170
   64F0 AA                   56 	.db #0xaa	; 170
   64F1 AA                   57 	.db #0xaa	; 170
   64F2 AA                   58 	.db #0xaa	; 170
   64F3 AA                   59 	.db #0xaa	; 170
   64F4 AA                   60 	.db #0xaa	; 170
   64F5 AA                   61 	.db #0xaa	; 170
   64F6 FF                   62 	.db #0xff	; 255
   64F7 AA                   63 	.db #0xaa	; 170
   64F8                      64 _s_small_numbers_01:
   64F8 55                   65 	.db #0x55	; 85	'U'
   64F9 AA                   66 	.db #0xaa	; 170
   64FA 00                   67 	.db #0x00	; 0
   64FB AA                   68 	.db #0xaa	; 170
   64FC 00                   69 	.db #0x00	; 0
   64FD AA                   70 	.db #0xaa	; 170
   64FE 00                   71 	.db #0x00	; 0
   64FF AA                   72 	.db #0xaa	; 170
   6500 00                   73 	.db #0x00	; 0
   6501 AA                   74 	.db #0xaa	; 170
   6502                      75 _s_small_numbers_02:
   6502 FF                   76 	.db #0xff	; 255
   6503 AA                   77 	.db #0xaa	; 170
   6504 00                   78 	.db #0x00	; 0
   6505 AA                   79 	.db #0xaa	; 170
   6506 FF                   80 	.db #0xff	; 255
   6507 AA                   81 	.db #0xaa	; 170
   6508 AA                   82 	.db #0xaa	; 170
   6509 00                   83 	.db #0x00	; 0
   650A FF                   84 	.db #0xff	; 255
   650B AA                   85 	.db #0xaa	; 170
   650C                      86 _s_small_numbers_03:
   650C FF                   87 	.db #0xff	; 255
   650D AA                   88 	.db #0xaa	; 170
   650E 00                   89 	.db #0x00	; 0
   650F AA                   90 	.db #0xaa	; 170
   6510 55                   91 	.db #0x55	; 85	'U'
   6511 AA                   92 	.db #0xaa	; 170
   6512 00                   93 	.db #0x00	; 0
   6513 AA                   94 	.db #0xaa	; 170
   6514 FF                   95 	.db #0xff	; 255
   6515 AA                   96 	.db #0xaa	; 170
   6516                      97 _s_small_numbers_04:
   6516 AA                   98 	.db #0xaa	; 170
   6517 AA                   99 	.db #0xaa	; 170
   6518 AA                  100 	.db #0xaa	; 170
   6519 AA                  101 	.db #0xaa	; 170
   651A FF                  102 	.db #0xff	; 255
   651B AA                  103 	.db #0xaa	; 170
   651C 00                  104 	.db #0x00	; 0
   651D AA                  105 	.db #0xaa	; 170
   651E 00                  106 	.db #0x00	; 0
   651F AA                  107 	.db #0xaa	; 170
   6520                     108 _s_small_numbers_05:
   6520 FF                  109 	.db #0xff	; 255
   6521 AA                  110 	.db #0xaa	; 170
   6522 AA                  111 	.db #0xaa	; 170
   6523 00                  112 	.db #0x00	; 0
   6524 FF                  113 	.db #0xff	; 255
   6525 AA                  114 	.db #0xaa	; 170
   6526 00                  115 	.db #0x00	; 0
   6527 AA                  116 	.db #0xaa	; 170
   6528 FF                  117 	.db #0xff	; 255
   6529 AA                  118 	.db #0xaa	; 170
   652A                     119 _s_small_numbers_06:
   652A FF                  120 	.db #0xff	; 255
   652B AA                  121 	.db #0xaa	; 170
   652C AA                  122 	.db #0xaa	; 170
   652D 00                  123 	.db #0x00	; 0
   652E FF                  124 	.db #0xff	; 255
   652F AA                  125 	.db #0xaa	; 170
   6530 AA                  126 	.db #0xaa	; 170
   6531 AA                  127 	.db #0xaa	; 170
   6532 FF                  128 	.db #0xff	; 255
   6533 AA                  129 	.db #0xaa	; 170
   6534                     130 _s_small_numbers_07:
   6534 FF                  131 	.db #0xff	; 255
   6535 AA                  132 	.db #0xaa	; 170
   6536 00                  133 	.db #0x00	; 0
   6537 AA                  134 	.db #0xaa	; 170
   6538 00                  135 	.db #0x00	; 0
   6539 AA                  136 	.db #0xaa	; 170
   653A 00                  137 	.db #0x00	; 0
   653B AA                  138 	.db #0xaa	; 170
   653C 00                  139 	.db #0x00	; 0
   653D AA                  140 	.db #0xaa	; 170
   653E                     141 _s_small_numbers_08:
   653E FF                  142 	.db #0xff	; 255
   653F AA                  143 	.db #0xaa	; 170
   6540 AA                  144 	.db #0xaa	; 170
   6541 AA                  145 	.db #0xaa	; 170
   6542 FF                  146 	.db #0xff	; 255
   6543 AA                  147 	.db #0xaa	; 170
   6544 AA                  148 	.db #0xaa	; 170
   6545 AA                  149 	.db #0xaa	; 170
   6546 FF                  150 	.db #0xff	; 255
   6547 AA                  151 	.db #0xaa	; 170
   6548                     152 _s_small_numbers_09:
   6548 FF                  153 	.db #0xff	; 255
   6549 AA                  154 	.db #0xaa	; 170
   654A AA                  155 	.db #0xaa	; 170
   654B AA                  156 	.db #0xaa	; 170
   654C FF                  157 	.db #0xff	; 255
   654D AA                  158 	.db #0xaa	; 170
   654E 00                  159 	.db #0x00	; 0
   654F AA                  160 	.db #0xaa	; 170
   6550 00                  161 	.db #0x00	; 0
   6551 AA                  162 	.db #0xaa	; 170
                            163 	.area _INITIALIZER
                            164 	.area _CABS (ABS)
