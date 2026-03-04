                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module basket
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _s_basket
                             12 ;--------------------------------------------------------
                             13 ; special function registers
                             14 ;--------------------------------------------------------
                             15 ;--------------------------------------------------------
                             16 ; ram data
                             17 ;--------------------------------------------------------
                             18 	.area _DATA
                             19 ;--------------------------------------------------------
                             20 ; ram data
                             21 ;--------------------------------------------------------
                             22 	.area _INITIALIZED
                             23 ;--------------------------------------------------------
                             24 ; absolute external ram data
                             25 ;--------------------------------------------------------
                             26 	.area _DABS (ABS)
                             27 ;--------------------------------------------------------
                             28 ; global & static initialisations
                             29 ;--------------------------------------------------------
                             30 	.area _HOME
                             31 	.area _GSINIT
                             32 	.area _GSFINAL
                             33 	.area _GSINIT
                             34 ;--------------------------------------------------------
                             35 ; Home
                             36 ;--------------------------------------------------------
                             37 	.area _HOME
                             38 	.area _HOME
                             39 ;--------------------------------------------------------
                             40 ; code
                             41 ;--------------------------------------------------------
                             42 	.area _CODE
                             43 	.area _CODE
   5CE0                      44 _s_basket:
   5CE0 00                   45 	.db #0x00	; 0
   5CE1 00                   46 	.db #0x00	; 0
   5CE2 00                   47 	.db #0x00	; 0
   5CE3 00                   48 	.db #0x00	; 0
   5CE4 00                   49 	.db #0x00	; 0
   5CE5 00                   50 	.db #0x00	; 0
   5CE6 00                   51 	.db #0x00	; 0
   5CE7 44                   52 	.db #0x44	; 68	'D'
   5CE8 CC                   53 	.db #0xcc	; 204
   5CE9 CC                   54 	.db #0xcc	; 204
   5CEA CC                   55 	.db #0xcc	; 204
   5CEB CC                   56 	.db #0xcc	; 204
   5CEC 00                   57 	.db #0x00	; 0
   5CED 00                   58 	.db #0x00	; 0
   5CEE 00                   59 	.db #0x00	; 0
   5CEF 00                   60 	.db #0x00	; 0
   5CF0 00                   61 	.db #0x00	; 0
   5CF1 00                   62 	.db #0x00	; 0
   5CF2 00                   63 	.db #0x00	; 0
   5CF3 00                   64 	.db #0x00	; 0
   5CF4 00                   65 	.db #0x00	; 0
   5CF5 00                   66 	.db #0x00	; 0
   5CF6 00                   67 	.db #0x00	; 0
   5CF7 44                   68 	.db #0x44	; 68	'D'
   5CF8 CC                   69 	.db #0xcc	; 204
   5CF9 CC                   70 	.db #0xcc	; 204
   5CFA 30                   71 	.db #0x30	; 48	'0'
   5CFB CC                   72 	.db #0xcc	; 204
   5CFC CC                   73 	.db #0xcc	; 204
   5CFD 30                   74 	.db #0x30	; 48	'0'
   5CFE CC                   75 	.db #0xcc	; 204
   5CFF 00                   76 	.db #0x00	; 0
   5D00 00                   77 	.db #0x00	; 0
   5D01 00                   78 	.db #0x00	; 0
   5D02 00                   79 	.db #0x00	; 0
   5D03 00                   80 	.db #0x00	; 0
   5D04 00                   81 	.db #0x00	; 0
   5D05 00                   82 	.db #0x00	; 0
   5D06 00                   83 	.db #0x00	; 0
   5D07 00                   84 	.db #0x00	; 0
   5D08 44                   85 	.db #0x44	; 68	'D'
   5D09 CC                   86 	.db #0xcc	; 204
   5D0A CC                   87 	.db #0xcc	; 204
   5D0B CC                   88 	.db #0xcc	; 204
   5D0C CC                   89 	.db #0xcc	; 204
   5D0D 98                   90 	.db #0x98	; 152
   5D0E 64                   91 	.db #0x64	; 100	'd'
   5D0F 98                   92 	.db #0x98	; 152
   5D10 64                   93 	.db #0x64	; 100	'd'
   5D11 88                   94 	.db #0x88	; 136
   5D12 00                   95 	.db #0x00	; 0
   5D13 00                   96 	.db #0x00	; 0
   5D14 00                   97 	.db #0x00	; 0
   5D15 00                   98 	.db #0x00	; 0
   5D16 00                   99 	.db #0x00	; 0
   5D17 00                  100 	.db #0x00	; 0
   5D18 00                  101 	.db #0x00	; 0
   5D19 00                  102 	.db #0x00	; 0
   5D1A CC                  103 	.db #0xcc	; 204
   5D1B 98                  104 	.db #0x98	; 152
   5D1C CC                  105 	.db #0xcc	; 204
   5D1D 30                  106 	.db #0x30	; 48	'0'
   5D1E 64                  107 	.db #0x64	; 100	'd'
   5D1F CC                  108 	.db #0xcc	; 204
   5D20 CC                  109 	.db #0xcc	; 204
   5D21 CC                  110 	.db #0xcc	; 204
   5D22 30                  111 	.db #0x30	; 48	'0'
   5D23 88                  112 	.db #0x88	; 136
   5D24 00                  113 	.db #0x00	; 0
   5D25 00                  114 	.db #0x00	; 0
   5D26 00                  115 	.db #0x00	; 0
   5D27 00                  116 	.db #0x00	; 0
   5D28 00                  117 	.db #0x00	; 0
   5D29 00                  118 	.db #0x00	; 0
   5D2A 00                  119 	.db #0x00	; 0
   5D2B 44                  120 	.db #0x44	; 68	'D'
   5D2C 98                  121 	.db #0x98	; 152
   5D2D CC                  122 	.db #0xcc	; 204
   5D2E 98                  123 	.db #0x98	; 152
   5D2F 64                  124 	.db #0x64	; 100	'd'
   5D30 CC                  125 	.db #0xcc	; 204
   5D31 98                  126 	.db #0x98	; 152
   5D32 64                  127 	.db #0x64	; 100	'd'
   5D33 CC                  128 	.db #0xcc	; 204
   5D34 30                  129 	.db #0x30	; 48	'0'
   5D35 64                  130 	.db #0x64	; 100	'd'
   5D36 00                  131 	.db #0x00	; 0
   5D37 00                  132 	.db #0x00	; 0
   5D38 00                  133 	.db #0x00	; 0
   5D39 00                  134 	.db #0x00	; 0
   5D3A 00                  135 	.db #0x00	; 0
   5D3B 00                  136 	.db #0x00	; 0
   5D3C 44                  137 	.db #0x44	; 68	'D'
   5D3D CC                  138 	.db #0xcc	; 204
   5D3E 64                  139 	.db #0x64	; 100	'd'
   5D3F 98                  140 	.db #0x98	; 152
   5D40 30                  141 	.db #0x30	; 48	'0'
   5D41 CC                  142 	.db #0xcc	; 204
   5D42 30                  143 	.db #0x30	; 48	'0'
   5D43 30                  144 	.db #0x30	; 48	'0'
   5D44 30                  145 	.db #0x30	; 48	'0'
   5D45 64                  146 	.db #0x64	; 100	'd'
   5D46 CC                  147 	.db #0xcc	; 204
   5D47 CC                  148 	.db #0xcc	; 204
   5D48 CC                  149 	.db #0xcc	; 204
   5D49 00                  150 	.db #0x00	; 0
   5D4A 00                  151 	.db #0x00	; 0
   5D4B 00                  152 	.db #0x00	; 0
   5D4C 00                  153 	.db #0x00	; 0
   5D4D 00                  154 	.db #0x00	; 0
   5D4E CC                  155 	.db #0xcc	; 204
   5D4F CC                  156 	.db #0xcc	; 204
   5D50 CC                  157 	.db #0xcc	; 204
   5D51 98                  158 	.db #0x98	; 152
   5D52 30                  159 	.db #0x30	; 48	'0'
   5D53 30                  160 	.db #0x30	; 48	'0'
   5D54 30                  161 	.db #0x30	; 48	'0'
   5D55 30                  162 	.db #0x30	; 48	'0'
   5D56 30                  163 	.db #0x30	; 48	'0'
   5D57 30                  164 	.db #0x30	; 48	'0'
   5D58 30                  165 	.db #0x30	; 48	'0'
   5D59 30                  166 	.db #0x30	; 48	'0'
   5D5A CC                  167 	.db #0xcc	; 204
   5D5B 88                  168 	.db #0x88	; 136
   5D5C 00                  169 	.db #0x00	; 0
   5D5D 00                  170 	.db #0x00	; 0
   5D5E 00                  171 	.db #0x00	; 0
   5D5F 44                  172 	.db #0x44	; 68	'D'
   5D60 CC                  173 	.db #0xcc	; 204
   5D61 98                  174 	.db #0x98	; 152
   5D62 CC                  175 	.db #0xcc	; 204
   5D63 30                  176 	.db #0x30	; 48	'0'
   5D64 64                  177 	.db #0x64	; 100	'd'
   5D65 CC                  178 	.db #0xcc	; 204
   5D66 CC                  179 	.db #0xcc	; 204
   5D67 CC                  180 	.db #0xcc	; 204
   5D68 CC                  181 	.db #0xcc	; 204
   5D69 CC                  182 	.db #0xcc	; 204
   5D6A 98                  183 	.db #0x98	; 152
   5D6B 30                  184 	.db #0x30	; 48	'0'
   5D6C CC                  185 	.db #0xcc	; 204
   5D6D 88                  186 	.db #0x88	; 136
   5D6E 00                  187 	.db #0x00	; 0
   5D6F 00                  188 	.db #0x00	; 0
   5D70 00                  189 	.db #0x00	; 0
   5D71 44                  190 	.db #0x44	; 68	'D'
   5D72 CC                  191 	.db #0xcc	; 204
   5D73 64                  192 	.db #0x64	; 100	'd'
   5D74 98                  193 	.db #0x98	; 152
   5D75 64                  194 	.db #0x64	; 100	'd'
   5D76 DC                  195 	.db #0xdc	; 220
   5D77 EC                  196 	.db #0xec	; 236
   5D78 CC                  197 	.db #0xcc	; 204
   5D79 EC                  198 	.db #0xec	; 236
   5D7A CC                  199 	.db #0xcc	; 204
   5D7B 98                  200 	.db #0x98	; 152
   5D7C 64                  201 	.db #0x64	; 100	'd'
   5D7D 30                  202 	.db #0x30	; 48	'0'
   5D7E 64                  203 	.db #0x64	; 100	'd'
   5D7F CC                  204 	.db #0xcc	; 204
   5D80 00                  205 	.db #0x00	; 0
   5D81 00                  206 	.db #0x00	; 0
   5D82 00                  207 	.db #0x00	; 0
   5D83 CC                  208 	.db #0xcc	; 204
   5D84 98                  209 	.db #0x98	; 152
   5D85 CC                  210 	.db #0xcc	; 204
   5D86 30                  211 	.db #0x30	; 48	'0'
   5D87 CC                  212 	.db #0xcc	; 204
   5D88 FC                  213 	.db #0xfc	; 252
   5D89 CC                  214 	.db #0xcc	; 204
   5D8A FC                  215 	.db #0xfc	; 252
   5D8B FC                  216 	.db #0xfc	; 252
   5D8C FC                  217 	.db #0xfc	; 252
   5D8D CC                  218 	.db #0xcc	; 204
   5D8E 64                  219 	.db #0x64	; 100	'd'
   5D8F 98                  220 	.db #0x98	; 152
   5D90 64                  221 	.db #0x64	; 100	'd'
   5D91 CC                  222 	.db #0xcc	; 204
   5D92 00                  223 	.db #0x00	; 0
   5D93 00                  224 	.db #0x00	; 0
   5D94 00                  225 	.db #0x00	; 0
   5D95 98                  226 	.db #0x98	; 152
   5D96 CC                  227 	.db #0xcc	; 204
   5D97 98                  228 	.db #0x98	; 152
   5D98 64                  229 	.db #0x64	; 100	'd'
   5D99 DC                  230 	.db #0xdc	; 220
   5D9A FC                  231 	.db #0xfc	; 252
   5D9B FC                  232 	.db #0xfc	; 252
   5D9C FC                  233 	.db #0xfc	; 252
   5D9D C3                  234 	.db #0xc3	; 195
   5D9E FC                  235 	.db #0xfc	; 252
   5D9F EC                  236 	.db #0xec	; 236
   5DA0 98                  237 	.db #0x98	; 152
   5DA1 98                  238 	.db #0x98	; 152
   5DA2 30                  239 	.db #0x30	; 48	'0'
   5DA3 CC                  240 	.db #0xcc	; 204
   5DA4 88                  241 	.db #0x88	; 136
   5DA5 00                  242 	.db #0x00	; 0
   5DA6 00                  243 	.db #0x00	; 0
   5DA7 98                  244 	.db #0x98	; 152
   5DA8 CC                  245 	.db #0xcc	; 204
   5DA9 30                  246 	.db #0x30	; 48	'0'
   5DAA CC                  247 	.db #0xcc	; 204
   5DAB FC                  248 	.db #0xfc	; 252
   5DAC E9                  249 	.db #0xe9	; 233
   5DAD C3                  250 	.db #0xc3	; 195
   5DAE C3                  251 	.db #0xc3	; 195
   5DAF D6                  252 	.db #0xd6	; 214
   5DB0 C3                  253 	.db #0xc3	; 195
   5DB1 92                  254 	.db #0x92	; 146
   5DB2 CC                  255 	.db #0xcc	; 204
   5DB3 64                  256 	.db #0x64	; 100	'd'
   5DB4 30                  257 	.db #0x30	; 48	'0'
   5DB5 98                  258 	.db #0x98	; 152
   5DB6 88                  259 	.db #0x88	; 136
   5DB7 00                  260 	.db #0x00	; 0
   5DB8 00                  261 	.db #0x00	; 0
   5DB9 98                  262 	.db #0x98	; 152
   5DBA CC                  263 	.db #0xcc	; 204
   5DBB 64                  264 	.db #0x64	; 100	'd'
   5DBC DC                  265 	.db #0xdc	; 220
   5DBD FC                  266 	.db #0xfc	; 252
   5DBE FC                  267 	.db #0xfc	; 252
   5DBF FC                  268 	.db #0xfc	; 252
   5DC0 FC                  269 	.db #0xfc	; 252
   5DC1 FC                  270 	.db #0xfc	; 252
   5DC2 FC                  271 	.db #0xfc	; 252
   5DC3 C3                  272 	.db #0xc3	; 195
   5DC4 C6                  273 	.db #0xc6	; 198
   5DC5 CC                  274 	.db #0xcc	; 204
   5DC6 30                  275 	.db #0x30	; 48	'0'
   5DC7 CC                  276 	.db #0xcc	; 204
   5DC8 88                  277 	.db #0x88	; 136
   5DC9 00                  278 	.db #0x00	; 0
   5DCA 00                  279 	.db #0x00	; 0
   5DCB 98                  280 	.db #0x98	; 152
   5DCC 98                  281 	.db #0x98	; 152
   5DCD CC                  282 	.db #0xcc	; 204
   5DCE FC                  283 	.db #0xfc	; 252
   5DCF FC                  284 	.db #0xfc	; 252
   5DD0 FC                  285 	.db #0xfc	; 252
   5DD1 FC                  286 	.db #0xfc	; 252
   5DD2 AD                  287 	.db #0xad	; 173
   5DD3 5E                  288 	.db #0x5e	; 94
   5DD4 FC                  289 	.db #0xfc	; 252
   5DD5 FC                  290 	.db #0xfc	; 252
   5DD6 C3                  291 	.db #0xc3	; 195
   5DD7 EC                  292 	.db #0xec	; 236
   5DD8 98                  293 	.db #0x98	; 152
   5DD9 64                  294 	.db #0x64	; 100	'd'
   5DDA CC                  295 	.db #0xcc	; 204
   5DDB 00                  296 	.db #0x00	; 0
   5DDC 44                  297 	.db #0x44	; 68	'D'
   5DDD 30                  298 	.db #0x30	; 48	'0'
   5DDE 98                  299 	.db #0x98	; 152
   5DDF DC                  300 	.db #0xdc	; 220
   5DE0 FC                  301 	.db #0xfc	; 252
   5DE1 FC                  302 	.db #0xfc	; 252
   5DE2 FC                  303 	.db #0xfc	; 252
   5DE3 5E                  304 	.db #0x5e	; 94
   5DE4 0F                  305 	.db #0x0f	; 15
   5DE5 FC                  306 	.db #0xfc	; 252
   5DE6 FC                  307 	.db #0xfc	; 252
   5DE7 FC                  308 	.db #0xfc	; 252
   5DE8 E9                  309 	.db #0xe9	; 233
   5DE9 FC                  310 	.db #0xfc	; 252
   5DEA 98                  311 	.db #0x98	; 152
   5DEB 64                  312 	.db #0x64	; 100	'd'
   5DEC 64                  313 	.db #0x64	; 100	'd'
   5DED 00                  314 	.db #0x00	; 0
   5DEE 44                  315 	.db #0x44	; 68	'D'
   5DEF 64                  316 	.db #0x64	; 100	'd'
   5DF0 CC                  317 	.db #0xcc	; 204
   5DF1 DC                  318 	.db #0xdc	; 220
   5DF2 FC                  319 	.db #0xfc	; 252
   5DF3 FC                  320 	.db #0xfc	; 252
   5DF4 FC                  321 	.db #0xfc	; 252
   5DF5 AD                  322 	.db #0xad	; 173
   5DF6 5E                  323 	.db #0x5e	; 94
   5DF7 FC                  324 	.db #0xfc	; 252
   5DF8 FC                  325 	.db #0xfc	; 252
   5DF9 FC                  326 	.db #0xfc	; 252
   5DFA FC                  327 	.db #0xfc	; 252
   5DFB D6                  328 	.db #0xd6	; 214
   5DFC EC                  329 	.db #0xec	; 236
   5DFD 64                  330 	.db #0x64	; 100	'd'
   5DFE 64                  331 	.db #0x64	; 100	'd'
   5DFF 00                  332 	.db #0x00	; 0
   5E00 44                  333 	.db #0x44	; 68	'D'
   5E01 64                  334 	.db #0x64	; 100	'd'
   5E02 CC                  335 	.db #0xcc	; 204
   5E03 FC                  336 	.db #0xfc	; 252
   5E04 AD                  337 	.db #0xad	; 173
   5E05 0F                  338 	.db #0x0f	; 15
   5E06 5E                  339 	.db #0x5e	; 94
   5E07 FC                  340 	.db #0xfc	; 252
   5E08 FC                  341 	.db #0xfc	; 252
   5E09 FC                  342 	.db #0xfc	; 252
   5E0A FC                  343 	.db #0xfc	; 252
   5E0B FC                  344 	.db #0xfc	; 252
   5E0C FC                  345 	.db #0xfc	; 252
   5E0D C3                  346 	.db #0xc3	; 195
   5E0E EC                  347 	.db #0xec	; 236
   5E0F 64                  348 	.db #0x64	; 100	'd'
   5E10 64                  349 	.db #0x64	; 100	'd'
   5E11 00                  350 	.db #0x00	; 0
   5E12 44                  351 	.db #0x44	; 68	'D'
   5E13 CC                  352 	.db #0xcc	; 204
   5E14 64                  353 	.db #0x64	; 100	'd'
   5E15 E9                  354 	.db #0xe9	; 233
   5E16 0F                  355 	.db #0x0f	; 15
   5E17 FC                  356 	.db #0xfc	; 252
   5E18 0F                  357 	.db #0x0f	; 15
   5E19 FC                  358 	.db #0xfc	; 252
   5E1A FC                  359 	.db #0xfc	; 252
   5E1B FC                  360 	.db #0xfc	; 252
   5E1C 0F                  361 	.db #0x0f	; 15
   5E1D 0F                  362 	.db #0x0f	; 15
   5E1E 5E                  363 	.db #0x5e	; 94
   5E1F E9                  364 	.db #0xe9	; 233
   5E20 EC                  365 	.db #0xec	; 236
   5E21 30                  366 	.db #0x30	; 48	'0'
   5E22 CC                  367 	.db #0xcc	; 204
   5E23 00                  368 	.db #0x00	; 0
   5E24 44                  369 	.db #0x44	; 68	'D'
   5E25 CC                  370 	.db #0xcc	; 204
   5E26 64                  371 	.db #0x64	; 100	'd'
   5E27 E9                  372 	.db #0xe9	; 233
   5E28 5E                  373 	.db #0x5e	; 94
   5E29 FC                  374 	.db #0xfc	; 252
   5E2A AD                  375 	.db #0xad	; 173
   5E2B 5E                  376 	.db #0x5e	; 94
   5E2C AD                  377 	.db #0xad	; 173
   5E2D 0F                  378 	.db #0x0f	; 15
   5E2E 5E                  379 	.db #0x5e	; 94
   5E2F FC                  380 	.db #0xfc	; 252
   5E30 0F                  381 	.db #0x0f	; 15
   5E31 4B                  382 	.db #0x4b	; 75	'K'
   5E32 EC                  383 	.db #0xec	; 236
   5E33 30                  384 	.db #0x30	; 48	'0'
   5E34 CC                  385 	.db #0xcc	; 204
   5E35 88                  386 	.db #0x88	; 136
   5E36 CC                  387 	.db #0xcc	; 204
   5E37 CC                  388 	.db #0xcc	; 204
   5E38 64                  389 	.db #0x64	; 100	'd'
   5E39 C3                  390 	.db #0xc3	; 195
   5E3A FC                  391 	.db #0xfc	; 252
   5E3B FC                  392 	.db #0xfc	; 252
   5E3C FC                  393 	.db #0xfc	; 252
   5E3D AD                  394 	.db #0xad	; 173
   5E3E 0F                  395 	.db #0x0f	; 15
   5E3F FC                  396 	.db #0xfc	; 252
   5E40 FC                  397 	.db #0xfc	; 252
   5E41 FC                  398 	.db #0xfc	; 252
   5E42 FC                  399 	.db #0xfc	; 252
   5E43 E9                  400 	.db #0xe9	; 233
   5E44 C6                  401 	.db #0xc6	; 198
   5E45 30                  402 	.db #0x30	; 48	'0'
   5E46 98                  403 	.db #0x98	; 152
   5E47 88                  404 	.db #0x88	; 136
   5E48 CC                  405 	.db #0xcc	; 204
   5E49 64                  406 	.db #0x64	; 100	'd'
   5E4A 64                  407 	.db #0x64	; 100	'd'
   5E4B D6                  408 	.db #0xd6	; 214
   5E4C E9                  409 	.db #0xe9	; 233
   5E4D C3                  410 	.db #0xc3	; 195
   5E4E C3                  411 	.db #0xc3	; 195
   5E4F D6                  412 	.db #0xd6	; 214
   5E50 FC                  413 	.db #0xfc	; 252
   5E51 FC                  414 	.db #0xfc	; 252
   5E52 FC                  415 	.db #0xfc	; 252
   5E53 FC                  416 	.db #0xfc	; 252
   5E54 FC                  417 	.db #0xfc	; 252
   5E55 FC                  418 	.db #0xfc	; 252
   5E56 C6                  419 	.db #0xc6	; 198
   5E57 30                  420 	.db #0x30	; 48	'0'
   5E58 98                  421 	.db #0x98	; 152
   5E59 88                  422 	.db #0x88	; 136
   5E5A CC                  423 	.db #0xcc	; 204
   5E5B 64                  424 	.db #0x64	; 100	'd'
   5E5C CC                  425 	.db #0xcc	; 204
   5E5D D6                  426 	.db #0xd6	; 214
   5E5E FC                  427 	.db #0xfc	; 252
   5E5F FC                  428 	.db #0xfc	; 252
   5E60 FC                  429 	.db #0xfc	; 252
   5E61 C3                  430 	.db #0xc3	; 195
   5E62 C3                  431 	.db #0xc3	; 195
   5E63 C3                  432 	.db #0xc3	; 195
   5E64 C3                  433 	.db #0xc3	; 195
   5E65 D6                  434 	.db #0xd6	; 214
   5E66 FC                  435 	.db #0xfc	; 252
   5E67 FC                  436 	.db #0xfc	; 252
   5E68 92                  437 	.db #0x92	; 146
   5E69 98                  438 	.db #0x98	; 152
   5E6A 98                  439 	.db #0x98	; 152
   5E6B 88                  440 	.db #0x88	; 136
   5E6C CC                  441 	.db #0xcc	; 204
   5E6D 64                  442 	.db #0x64	; 100	'd'
   5E6E 98                  443 	.db #0x98	; 152
   5E6F D6                  444 	.db #0xd6	; 214
   5E70 FC                  445 	.db #0xfc	; 252
   5E71 FC                  446 	.db #0xfc	; 252
   5E72 FC                  447 	.db #0xfc	; 252
   5E73 FC                  448 	.db #0xfc	; 252
   5E74 FC                  449 	.db #0xfc	; 252
   5E75 FC                  450 	.db #0xfc	; 252
   5E76 FC                  451 	.db #0xfc	; 252
   5E77 C3                  452 	.db #0xc3	; 195
   5E78 C3                  453 	.db #0xc3	; 195
   5E79 D6                  454 	.db #0xd6	; 214
   5E7A 92                  455 	.db #0x92	; 146
   5E7B 98                  456 	.db #0x98	; 152
   5E7C 98                  457 	.db #0x98	; 152
   5E7D 88                  458 	.db #0x88	; 136
   5E7E CC                  459 	.db #0xcc	; 204
   5E7F 98                  460 	.db #0x98	; 152
   5E80 CC                  461 	.db #0xcc	; 204
   5E81 D6                  462 	.db #0xd6	; 214
   5E82 FC                  463 	.db #0xfc	; 252
   5E83 FC                  464 	.db #0xfc	; 252
   5E84 FC                  465 	.db #0xfc	; 252
   5E85 FC                  466 	.db #0xfc	; 252
   5E86 FC                  467 	.db #0xfc	; 252
   5E87 FC                  468 	.db #0xfc	; 252
   5E88 FC                  469 	.db #0xfc	; 252
   5E89 FC                  470 	.db #0xfc	; 252
   5E8A FC                  471 	.db #0xfc	; 252
   5E8B FC                  472 	.db #0xfc	; 252
   5E8C C3                  473 	.db #0xc3	; 195
   5E8D 98                  474 	.db #0x98	; 152
   5E8E 98                  475 	.db #0x98	; 152
   5E8F CC                  476 	.db #0xcc	; 204
   5E90 98                  477 	.db #0x98	; 152
   5E91 98                  478 	.db #0x98	; 152
   5E92 CC                  479 	.db #0xcc	; 204
   5E93 D6                  480 	.db #0xd6	; 214
   5E94 FC                  481 	.db #0xfc	; 252
   5E95 FC                  482 	.db #0xfc	; 252
   5E96 FC                  483 	.db #0xfc	; 252
   5E97 FC                  484 	.db #0xfc	; 252
   5E98 FC                  485 	.db #0xfc	; 252
   5E99 FC                  486 	.db #0xfc	; 252
   5E9A FC                  487 	.db #0xfc	; 252
   5E9B FC                  488 	.db #0xfc	; 252
   5E9C FC                  489 	.db #0xfc	; 252
   5E9D FC                  490 	.db #0xfc	; 252
   5E9E E9                  491 	.db #0xe9	; 233
   5E9F 98                  492 	.db #0x98	; 152
   5EA0 98                  493 	.db #0x98	; 152
   5EA1 CC                  494 	.db #0xcc	; 204
   5EA2 98                  495 	.db #0x98	; 152
   5EA3 98                  496 	.db #0x98	; 152
   5EA4 CC                  497 	.db #0xcc	; 204
   5EA5 87                  498 	.db #0x87	; 135
   5EA6 0F                  499 	.db #0x0f	; 15
   5EA7 0F                  500 	.db #0x0f	; 15
   5EA8 0F                  501 	.db #0x0f	; 15
   5EA9 FC                  502 	.db #0xfc	; 252
   5EAA FC                  503 	.db #0xfc	; 252
   5EAB FC                  504 	.db #0xfc	; 252
   5EAC FC                  505 	.db #0xfc	; 252
   5EAD FC                  506 	.db #0xfc	; 252
   5EAE FC                  507 	.db #0xfc	; 252
   5EAF FC                  508 	.db #0xfc	; 252
   5EB0 E9                  509 	.db #0xe9	; 233
   5EB1 CC                  510 	.db #0xcc	; 204
   5EB2 CC                  511 	.db #0xcc	; 204
   5EB3 CC                  512 	.db #0xcc	; 204
   5EB4 98                  513 	.db #0x98	; 152
   5EB5 98                  514 	.db #0x98	; 152
   5EB6 98                  515 	.db #0x98	; 152
   5EB7 87                  516 	.db #0x87	; 135
   5EB8 FC                  517 	.db #0xfc	; 252
   5EB9 FC                  518 	.db #0xfc	; 252
   5EBA AD                  519 	.db #0xad	; 173
   5EBB 5E                  520 	.db #0x5e	; 94
   5EBC FC                  521 	.db #0xfc	; 252
   5EBD FC                  522 	.db #0xfc	; 252
   5EBE FC                  523 	.db #0xfc	; 252
   5EBF FC                  524 	.db #0xfc	; 252
   5EC0 FC                  525 	.db #0xfc	; 252
   5EC1 FC                  526 	.db #0xfc	; 252
   5EC2 E9                  527 	.db #0xe9	; 233
   5EC3 EC                  528 	.db #0xec	; 236
   5EC4 64                  529 	.db #0x64	; 100	'd'
   5EC5 98                  530 	.db #0x98	; 152
   5EC6 98                  531 	.db #0x98	; 152
   5EC7 98                  532 	.db #0x98	; 152
   5EC8 98                  533 	.db #0x98	; 152
   5EC9 D6                  534 	.db #0xd6	; 214
   5ECA FC                  535 	.db #0xfc	; 252
   5ECB FC                  536 	.db #0xfc	; 252
   5ECC FC                  537 	.db #0xfc	; 252
   5ECD AD                  538 	.db #0xad	; 173
   5ECE 0F                  539 	.db #0x0f	; 15
   5ECF FC                  540 	.db #0xfc	; 252
   5ED0 FC                  541 	.db #0xfc	; 252
   5ED1 FC                  542 	.db #0xfc	; 252
   5ED2 FC                  543 	.db #0xfc	; 252
   5ED3 FC                  544 	.db #0xfc	; 252
   5ED4 E9                  545 	.db #0xe9	; 233
   5ED5 EC                  546 	.db #0xec	; 236
   5ED6 64                  547 	.db #0x64	; 100	'd'
   5ED7 98                  548 	.db #0x98	; 152
   5ED8 CC                  549 	.db #0xcc	; 204
   5ED9 98                  550 	.db #0x98	; 152
   5EDA CC                  551 	.db #0xcc	; 204
   5EDB D6                  552 	.db #0xd6	; 214
   5EDC FC                  553 	.db #0xfc	; 252
   5EDD FC                  554 	.db #0xfc	; 252
   5EDE FC                  555 	.db #0xfc	; 252
   5EDF FC                  556 	.db #0xfc	; 252
   5EE0 AD                  557 	.db #0xad	; 173
   5EE1 5E                  558 	.db #0x5e	; 94
   5EE2 FC                  559 	.db #0xfc	; 252
   5EE3 AD                  560 	.db #0xad	; 173
   5EE4 0F                  561 	.db #0x0f	; 15
   5EE5 0F                  562 	.db #0x0f	; 15
   5EE6 4B                  563 	.db #0x4b	; 75	'K'
   5EE7 EC                  564 	.db #0xec	; 236
   5EE8 CC                  565 	.db #0xcc	; 204
   5EE9 98                  566 	.db #0x98	; 152
   5EEA CC                  567 	.db #0xcc	; 204
   5EEB 98                  568 	.db #0x98	; 152
   5EEC 64                  569 	.db #0x64	; 100	'd'
   5EED 4B                  570 	.db #0x4b	; 75	'K'
   5EEE FC                  571 	.db #0xfc	; 252
   5EEF FC                  572 	.db #0xfc	; 252
   5EF0 FC                  573 	.db #0xfc	; 252
   5EF1 FC                  574 	.db #0xfc	; 252
   5EF2 FC                  575 	.db #0xfc	; 252
   5EF3 AD                  576 	.db #0xad	; 173
   5EF4 0F                  577 	.db #0x0f	; 15
   5EF5 0F                  578 	.db #0x0f	; 15
   5EF6 FC                  579 	.db #0xfc	; 252
   5EF7 FC                  580 	.db #0xfc	; 252
   5EF8 E9                  581 	.db #0xe9	; 233
   5EF9 D6                  582 	.db #0xd6	; 214
   5EFA CC                  583 	.db #0xcc	; 204
   5EFB 98                  584 	.db #0x98	; 152
   5EFC CC                  585 	.db #0xcc	; 204
   5EFD 98                  586 	.db #0x98	; 152
   5EFE 64                  587 	.db #0x64	; 100	'd'
   5EFF 4B                  588 	.db #0x4b	; 75	'K'
   5F00 FC                  589 	.db #0xfc	; 252
   5F01 FC                  590 	.db #0xfc	; 252
   5F02 C3                  591 	.db #0xc3	; 195
   5F03 D6                  592 	.db #0xd6	; 214
   5F04 FC                  593 	.db #0xfc	; 252
   5F05 FC                  594 	.db #0xfc	; 252
   5F06 FC                  595 	.db #0xfc	; 252
   5F07 FC                  596 	.db #0xfc	; 252
   5F08 FC                  597 	.db #0xfc	; 252
   5F09 FC                  598 	.db #0xfc	; 252
   5F0A FC                  599 	.db #0xfc	; 252
   5F0B D6                  600 	.db #0xd6	; 214
   5F0C 98                  601 	.db #0x98	; 152
   5F0D 30                  602 	.db #0x30	; 48	'0'
   5F0E CC                  603 	.db #0xcc	; 204
   5F0F 30                  604 	.db #0x30	; 48	'0'
   5F10 CC                  605 	.db #0xcc	; 204
   5F11 4B                  606 	.db #0x4b	; 75	'K'
   5F12 E9                  607 	.db #0xe9	; 233
   5F13 C3                  608 	.db #0xc3	; 195
   5F14 D6                  609 	.db #0xd6	; 214
   5F15 E9                  610 	.db #0xe9	; 233
   5F16 C3                  611 	.db #0xc3	; 195
   5F17 FC                  612 	.db #0xfc	; 252
   5F18 FC                  613 	.db #0xfc	; 252
   5F19 FC                  614 	.db #0xfc	; 252
   5F1A 0F                  615 	.db #0x0f	; 15
   5F1B 0F                  616 	.db #0x0f	; 15
   5F1C 5E                  617 	.db #0x5e	; 94
   5F1D D6                  618 	.db #0xd6	; 214
   5F1E 98                  619 	.db #0x98	; 152
   5F1F 30                  620 	.db #0x30	; 48	'0'
   5F20 98                  621 	.db #0x98	; 152
   5F21 30                  622 	.db #0x30	; 48	'0'
   5F22 8D                  623 	.db #0x8d	; 141
   5F23 4B                  624 	.db #0x4b	; 75	'K'
   5F24 FC                  625 	.db #0xfc	; 252
   5F25 FC                  626 	.db #0xfc	; 252
   5F26 FC                  627 	.db #0xfc	; 252
   5F27 FC                  628 	.db #0xfc	; 252
   5F28 E9                  629 	.db #0xe9	; 233
   5F29 D6                  630 	.db #0xd6	; 214
   5F2A FC                  631 	.db #0xfc	; 252
   5F2B FC                  632 	.db #0xfc	; 252
   5F2C FC                  633 	.db #0xfc	; 252
   5F2D FC                  634 	.db #0xfc	; 252
   5F2E 0F                  635 	.db #0x0f	; 15
   5F2F D6                  636 	.db #0xd6	; 214
   5F30 98                  637 	.db #0x98	; 152
   5F31 98                  638 	.db #0x98	; 152
   5F32 98                  639 	.db #0x98	; 152
   5F33 98                  640 	.db #0x98	; 152
   5F34 8D                  641 	.db #0x8d	; 141
   5F35 C3                  642 	.db #0xc3	; 195
   5F36 FC                  643 	.db #0xfc	; 252
   5F37 FC                  644 	.db #0xfc	; 252
   5F38 FC                  645 	.db #0xfc	; 252
   5F39 FC                  646 	.db #0xfc	; 252
   5F3A FC                  647 	.db #0xfc	; 252
   5F3B C3                  648 	.db #0xc3	; 195
   5F3C FC                  649 	.db #0xfc	; 252
   5F3D FC                  650 	.db #0xfc	; 252
   5F3E FC                  651 	.db #0xfc	; 252
   5F3F FC                  652 	.db #0xfc	; 252
   5F40 FC                  653 	.db #0xfc	; 252
   5F41 D6                  654 	.db #0xd6	; 214
   5F42 98                  655 	.db #0x98	; 152
   5F43 CC                  656 	.db #0xcc	; 204
   5F44 98                  657 	.db #0x98	; 152
   5F45 98                  658 	.db #0x98	; 152
   5F46 8D                  659 	.db #0x8d	; 141
   5F47 D6                  660 	.db #0xd6	; 214
   5F48 FC                  661 	.db #0xfc	; 252
   5F49 FC                  662 	.db #0xfc	; 252
   5F4A FC                  663 	.db #0xfc	; 252
   5F4B FC                  664 	.db #0xfc	; 252
   5F4C FC                  665 	.db #0xfc	; 252
   5F4D E9                  666 	.db #0xe9	; 233
   5F4E D6                  667 	.db #0xd6	; 214
   5F4F FC                  668 	.db #0xfc	; 252
   5F50 FC                  669 	.db #0xfc	; 252
   5F51 FC                  670 	.db #0xfc	; 252
   5F52 FC                  671 	.db #0xfc	; 252
   5F53 FC                  672 	.db #0xfc	; 252
   5F54 98                  673 	.db #0x98	; 152
   5F55 CC                  674 	.db #0xcc	; 204
   5F56 98                  675 	.db #0x98	; 152
   5F57 CC                  676 	.db #0xcc	; 204
   5F58 8D                  677 	.db #0x8d	; 141
   5F59 D6                  678 	.db #0xd6	; 214
   5F5A FC                  679 	.db #0xfc	; 252
   5F5B FC                  680 	.db #0xfc	; 252
   5F5C FC                  681 	.db #0xfc	; 252
   5F5D FC                  682 	.db #0xfc	; 252
   5F5E FC                  683 	.db #0xfc	; 252
   5F5F FC                  684 	.db #0xfc	; 252
   5F60 C3                  685 	.db #0xc3	; 195
   5F61 FC                  686 	.db #0xfc	; 252
   5F62 FC                  687 	.db #0xfc	; 252
   5F63 FC                  688 	.db #0xfc	; 252
   5F64 FC                  689 	.db #0xfc	; 252
   5F65 FC                  690 	.db #0xfc	; 252
   5F66 98                  691 	.db #0x98	; 152
   5F67 CC                  692 	.db #0xcc	; 204
   5F68 98                  693 	.db #0x98	; 152
   5F69 CC                  694 	.db #0xcc	; 204
   5F6A C9                  695 	.db #0xc9	; 201
   5F6B D6                  696 	.db #0xd6	; 214
   5F6C FC                  697 	.db #0xfc	; 252
   5F6D 0F                  698 	.db #0x0f	; 15
   5F6E 0F                  699 	.db #0x0f	; 15
   5F6F FC                  700 	.db #0xfc	; 252
   5F70 FC                  701 	.db #0xfc	; 252
   5F71 FC                  702 	.db #0xfc	; 252
   5F72 E9                  703 	.db #0xe9	; 233
   5F73 C3                  704 	.db #0xc3	; 195
   5F74 C3                  705 	.db #0xc3	; 195
   5F75 C3                  706 	.db #0xc3	; 195
   5F76 FC                  707 	.db #0xfc	; 252
   5F77 C3                  708 	.db #0xc3	; 195
   5F78 98                  709 	.db #0x98	; 152
   5F79 98                  710 	.db #0x98	; 152
   5F7A 98                  711 	.db #0x98	; 152
   5F7B CC                  712 	.db #0xcc	; 204
   5F7C C9                  713 	.db #0xc9	; 201
   5F7D AD                  714 	.db #0xad	; 173
   5F7E 0F                  715 	.db #0x0f	; 15
   5F7F 5E                  716 	.db #0x5e	; 94
   5F80 FC                  717 	.db #0xfc	; 252
   5F81 5E                  718 	.db #0x5e	; 94
   5F82 FC                  719 	.db #0xfc	; 252
   5F83 FC                  720 	.db #0xfc	; 252
   5F84 FC                  721 	.db #0xfc	; 252
   5F85 FC                  722 	.db #0xfc	; 252
   5F86 FC                  723 	.db #0xfc	; 252
   5F87 FC                  724 	.db #0xfc	; 252
   5F88 D6                  725 	.db #0xd6	; 214
   5F89 E9                  726 	.db #0xe9	; 233
   5F8A 98                  727 	.db #0x98	; 152
   5F8B CC                  728 	.db #0xcc	; 204
   5F8C 98                  729 	.db #0x98	; 152
   5F8D 64                  730 	.db #0x64	; 100	'd'
   5F8E C9                  731 	.db #0xc9	; 201
   5F8F FC                  732 	.db #0xfc	; 252
   5F90 FC                  733 	.db #0xfc	; 252
   5F91 FC                  734 	.db #0xfc	; 252
   5F92 FC                  735 	.db #0xfc	; 252
   5F93 AD                  736 	.db #0xad	; 173
   5F94 FC                  737 	.db #0xfc	; 252
   5F95 FC                  738 	.db #0xfc	; 252
   5F96 FC                  739 	.db #0xfc	; 252
   5F97 FC                  740 	.db #0xfc	; 252
   5F98 0F                  741 	.db #0x0f	; 15
   5F99 0F                  742 	.db #0x0f	; 15
   5F9A 5E                  743 	.db #0x5e	; 94
   5F9B E9                  744 	.db #0xe9	; 233
   5F9C 98                  745 	.db #0x98	; 152
   5F9D CC                  746 	.db #0xcc	; 204
   5F9E CC                  747 	.db #0xcc	; 204
   5F9F CC                  748 	.db #0xcc	; 204
   5FA0 61                  749 	.db #0x61	; 97	'a'
   5FA1 FC                  750 	.db #0xfc	; 252
   5FA2 E9                  751 	.db #0xe9	; 233
   5FA3 C3                  752 	.db #0xc3	; 195
   5FA4 C3                  753 	.db #0xc3	; 195
   5FA5 87                  754 	.db #0x87	; 135
   5FA6 0F                  755 	.db #0x0f	; 15
   5FA7 FC                  756 	.db #0xfc	; 252
   5FA8 FC                  757 	.db #0xfc	; 252
   5FA9 0F                  758 	.db #0x0f	; 15
   5FAA 5E                  759 	.db #0x5e	; 94
   5FAB FC                  760 	.db #0xfc	; 252
   5FAC FC                  761 	.db #0xfc	; 252
   5FAD E9                  762 	.db #0xe9	; 233
   5FAE 98                  763 	.db #0x98	; 152
   5FAF CC                  764 	.db #0xcc	; 204
   5FB0 98                  765 	.db #0x98	; 152
   5FB1 CC                  766 	.db #0xcc	; 204
   5FB2 61                  767 	.db #0x61	; 97	'a'
   5FB3 FC                  768 	.db #0xfc	; 252
   5FB4 E9                  769 	.db #0xe9	; 233
   5FB5 FC                  770 	.db #0xfc	; 252
   5FB6 FC                  771 	.db #0xfc	; 252
   5FB7 D6                  772 	.db #0xd6	; 214
   5FB8 AD                  773 	.db #0xad	; 173
   5FB9 0F                  774 	.db #0x0f	; 15
   5FBA 0F                  775 	.db #0x0f	; 15
   5FBB 5E                  776 	.db #0x5e	; 94
   5FBC FC                  777 	.db #0xfc	; 252
   5FBD FC                  778 	.db #0xfc	; 252
   5FBE FC                  779 	.db #0xfc	; 252
   5FBF E9                  780 	.db #0xe9	; 233
   5FC0 98                  781 	.db #0x98	; 152
   5FC1 CC                  782 	.db #0xcc	; 204
   5FC2 CC                  783 	.db #0xcc	; 204
   5FC3 CC                  784 	.db #0xcc	; 204
   5FC4 C9                  785 	.db #0xc9	; 201
   5FC5 FC                  786 	.db #0xfc	; 252
   5FC6 D6                  787 	.db #0xd6	; 214
   5FC7 FC                  788 	.db #0xfc	; 252
   5FC8 FC                  789 	.db #0xfc	; 252
   5FC9 FC                  790 	.db #0xfc	; 252
   5FCA FC                  791 	.db #0xfc	; 252
   5FCB FC                  792 	.db #0xfc	; 252
   5FCC FC                  793 	.db #0xfc	; 252
   5FCD FC                  794 	.db #0xfc	; 252
   5FCE FC                  795 	.db #0xfc	; 252
   5FCF FC                  796 	.db #0xfc	; 252
   5FD0 FC                  797 	.db #0xfc	; 252
   5FD1 C3                  798 	.db #0xc3	; 195
   5FD2 CC                  799 	.db #0xcc	; 204
   5FD3 CC                  800 	.db #0xcc	; 204
   5FD4 CC                  801 	.db #0xcc	; 204
   5FD5 CC                  802 	.db #0xcc	; 204
   5FD6 C9                  803 	.db #0xc9	; 201
   5FD7 D6                  804 	.db #0xd6	; 214
   5FD8 FC                  805 	.db #0xfc	; 252
   5FD9 FC                  806 	.db #0xfc	; 252
   5FDA FC                  807 	.db #0xfc	; 252
   5FDB FC                  808 	.db #0xfc	; 252
   5FDC FC                  809 	.db #0xfc	; 252
   5FDD FC                  810 	.db #0xfc	; 252
   5FDE FC                  811 	.db #0xfc	; 252
   5FDF FC                  812 	.db #0xfc	; 252
   5FE0 FC                  813 	.db #0xfc	; 252
   5FE1 FC                  814 	.db #0xfc	; 252
   5FE2 FC                  815 	.db #0xfc	; 252
   5FE3 87                  816 	.db #0x87	; 135
   5FE4 CC                  817 	.db #0xcc	; 204
   5FE5 64                  818 	.db #0x64	; 100	'd'
   5FE6 CC                  819 	.db #0xcc	; 204
   5FE7 64                  820 	.db #0x64	; 100	'd'
   5FE8 98                  821 	.db #0x98	; 152
   5FE9 D6                  822 	.db #0xd6	; 214
   5FEA FC                  823 	.db #0xfc	; 252
   5FEB FC                  824 	.db #0xfc	; 252
   5FEC FC                  825 	.db #0xfc	; 252
   5FED E9                  826 	.db #0xe9	; 233
   5FEE D6                  827 	.db #0xd6	; 214
   5FEF FC                  828 	.db #0xfc	; 252
   5FF0 FC                  829 	.db #0xfc	; 252
   5FF1 C3                  830 	.db #0xc3	; 195
   5FF2 C3                  831 	.db #0xc3	; 195
   5FF3 C3                  832 	.db #0xc3	; 195
   5FF4 D6                  833 	.db #0xd6	; 214
   5FF5 E9                  834 	.db #0xe9	; 233
   5FF6 CC                  835 	.db #0xcc	; 204
   5FF7 64                  836 	.db #0x64	; 100	'd'
   5FF8 CC                  837 	.db #0xcc	; 204
   5FF9 64                  838 	.db #0x64	; 100	'd'
   5FFA 98                  839 	.db #0x98	; 152
   5FFB D6                  840 	.db #0xd6	; 214
   5FFC FC                  841 	.db #0xfc	; 252
   5FFD FC                  842 	.db #0xfc	; 252
   5FFE FC                  843 	.db #0xfc	; 252
   5FFF FC                  844 	.db #0xfc	; 252
   6000 C3                  845 	.db #0xc3	; 195
   6001 C3                  846 	.db #0xc3	; 195
   6002 C3                  847 	.db #0xc3	; 195
   6003 D6                  848 	.db #0xd6	; 214
   6004 FC                  849 	.db #0xfc	; 252
   6005 FC                  850 	.db #0xfc	; 252
   6006 FC                  851 	.db #0xfc	; 252
   6007 E9                  852 	.db #0xe9	; 233
   6008 CC                  853 	.db #0xcc	; 204
   6009 64                  854 	.db #0x64	; 100	'd'
   600A CC                  855 	.db #0xcc	; 204
   600B CC                  856 	.db #0xcc	; 204
   600C 98                  857 	.db #0x98	; 152
   600D D6                  858 	.db #0xd6	; 214
   600E FC                  859 	.db #0xfc	; 252
   600F FC                  860 	.db #0xfc	; 252
   6010 FC                  861 	.db #0xfc	; 252
   6011 FC                  862 	.db #0xfc	; 252
   6012 FC                  863 	.db #0xfc	; 252
   6013 FC                  864 	.db #0xfc	; 252
   6014 FC                  865 	.db #0xfc	; 252
   6015 FC                  866 	.db #0xfc	; 252
   6016 FC                  867 	.db #0xfc	; 252
   6017 FC                  868 	.db #0xfc	; 252
   6018 FC                  869 	.db #0xfc	; 252
   6019 E9                  870 	.db #0xe9	; 233
   601A CC                  871 	.db #0xcc	; 204
   601B 64                  872 	.db #0x64	; 100	'd'
   601C 44                  873 	.db #0x44	; 68	'D'
   601D CC                  874 	.db #0xcc	; 204
   601E CC                  875 	.db #0xcc	; 204
   601F C3                  876 	.db #0xc3	; 195
   6020 FC                  877 	.db #0xfc	; 252
   6021 FC                  878 	.db #0xfc	; 252
   6022 FC                  879 	.db #0xfc	; 252
   6023 FC                  880 	.db #0xfc	; 252
   6024 FC                  881 	.db #0xfc	; 252
   6025 FC                  882 	.db #0xfc	; 252
   6026 FC                  883 	.db #0xfc	; 252
   6027 FC                  884 	.db #0xfc	; 252
   6028 0F                  885 	.db #0x0f	; 15
   6029 FC                  886 	.db #0xfc	; 252
   602A FC                  887 	.db #0xfc	; 252
   602B B8                  888 	.db #0xb8	; 184
   602C CC                  889 	.db #0xcc	; 204
   602D 64                  890 	.db #0x64	; 100	'd'
   602E 44                  891 	.db #0x44	; 68	'D'
   602F CC                  892 	.db #0xcc	; 204
   6030 64                  893 	.db #0x64	; 100	'd'
   6031 E9                  894 	.db #0xe9	; 233
   6032 FC                  895 	.db #0xfc	; 252
   6033 0F                  896 	.db #0x0f	; 15
   6034 0F                  897 	.db #0x0f	; 15
   6035 5E                  898 	.db #0x5e	; 94
   6036 FC                  899 	.db #0xfc	; 252
   6037 FC                  900 	.db #0xfc	; 252
   6038 FC                  901 	.db #0xfc	; 252
   6039 AD                  902 	.db #0xad	; 173
   603A 5E                  903 	.db #0x5e	; 94
   603B FC                  904 	.db #0xfc	; 252
   603C FC                  905 	.db #0xfc	; 252
   603D 92                  906 	.db #0x92	; 146
   603E CC                  907 	.db #0xcc	; 204
   603F 64                  908 	.db #0x64	; 100	'd'
   6040 44                  909 	.db #0x44	; 68	'D'
   6041 CC                  910 	.db #0xcc	; 204
   6042 64                  911 	.db #0x64	; 100	'd'
   6043 E9                  912 	.db #0xe9	; 233
   6044 0F                  913 	.db #0x0f	; 15
   6045 5E                  914 	.db #0x5e	; 94
   6046 FC                  915 	.db #0xfc	; 252
   6047 FC                  916 	.db #0xfc	; 252
   6048 FC                  917 	.db #0xfc	; 252
   6049 AD                  918 	.db #0xad	; 173
   604A 0F                  919 	.db #0x0f	; 15
   604B 0F                  920 	.db #0x0f	; 15
   604C FC                  921 	.db #0xfc	; 252
   604D FC                  922 	.db #0xfc	; 252
   604E FC                  923 	.db #0xfc	; 252
   604F C6                  924 	.db #0xc6	; 198
   6050 64                  925 	.db #0x64	; 100	'd'
   6051 64                  926 	.db #0x64	; 100	'd'
   6052 44                  927 	.db #0x44	; 68	'D'
   6053 64                  928 	.db #0x64	; 100	'd'
   6054 64                  929 	.db #0x64	; 100	'd'
   6055 E9                  930 	.db #0xe9	; 233
   6056 5E                  931 	.db #0x5e	; 94
   6057 FC                  932 	.db #0xfc	; 252
   6058 FC                  933 	.db #0xfc	; 252
   6059 AD                  934 	.db #0xad	; 173
   605A FC                  935 	.db #0xfc	; 252
   605B AD                  936 	.db #0xad	; 173
   605C FC                  937 	.db #0xfc	; 252
   605D FC                  938 	.db #0xfc	; 252
   605E FC                  939 	.db #0xfc	; 252
   605F 0F                  940 	.db #0x0f	; 15
   6060 5E                  941 	.db #0x5e	; 94
   6061 C6                  942 	.db #0xc6	; 198
   6062 64                  943 	.db #0x64	; 100	'd'
   6063 64                  944 	.db #0x64	; 100	'd'
   6064 44                  945 	.db #0x44	; 68	'D'
   6065 64                  946 	.db #0x64	; 100	'd'
   6066 64                  947 	.db #0x64	; 100	'd'
   6067 E9                  948 	.db #0xe9	; 233
   6068 FC                  949 	.db #0xfc	; 252
   6069 FC                  950 	.db #0xfc	; 252
   606A C3                  951 	.db #0xc3	; 195
   606B AD                  952 	.db #0xad	; 173
   606C 5E                  953 	.db #0x5e	; 94
   606D FC                  954 	.db #0xfc	; 252
   606E FC                  955 	.db #0xfc	; 252
   606F FC                  956 	.db #0xfc	; 252
   6070 AD                  957 	.db #0xad	; 173
   6071 5E                  958 	.db #0x5e	; 94
   6072 FC                  959 	.db #0xfc	; 252
   6073 C6                  960 	.db #0xc6	; 198
   6074 64                  961 	.db #0x64	; 100	'd'
   6075 64                  962 	.db #0x64	; 100	'd'
   6076 44                  963 	.db #0x44	; 68	'D'
   6077 64                  964 	.db #0x64	; 100	'd'
   6078 CC                  965 	.db #0xcc	; 204
   6079 E9                  966 	.db #0xe9	; 233
   607A E9                  967 	.db #0xe9	; 233
   607B C3                  968 	.db #0xc3	; 195
   607C D6                  969 	.db #0xd6	; 214
   607D 87                  970 	.db #0x87	; 135
   607E 0F                  971 	.db #0x0f	; 15
   607F 5E                  972 	.db #0x5e	; 94
   6080 FC                  973 	.db #0xfc	; 252
   6081 AD                  974 	.db #0xad	; 173
   6082 0F                  975 	.db #0x0f	; 15
   6083 FC                  976 	.db #0xfc	; 252
   6084 FC                  977 	.db #0xfc	; 252
   6085 C6                  978 	.db #0xc6	; 198
   6086 64                  979 	.db #0x64	; 100	'd'
   6087 64                  980 	.db #0x64	; 100	'd'
   6088 44                  981 	.db #0x44	; 68	'D'
   6089 64                  982 	.db #0x64	; 100	'd'
   608A CC                  983 	.db #0xcc	; 204
   608B E9                  984 	.db #0xe9	; 233
   608C C3                  985 	.db #0xc3	; 195
   608D FC                  986 	.db #0xfc	; 252
   608E FC                  987 	.db #0xfc	; 252
   608F E9                  988 	.db #0xe9	; 233
   6090 FC                  989 	.db #0xfc	; 252
   6091 0F                  990 	.db #0x0f	; 15
   6092 0F                  991 	.db #0x0f	; 15
   6093 0F                  992 	.db #0x0f	; 15
   6094 FC                  993 	.db #0xfc	; 252
   6095 FC                  994 	.db #0xfc	; 252
   6096 FC                  995 	.db #0xfc	; 252
   6097 C6                  996 	.db #0xc6	; 198
   6098 98                  997 	.db #0x98	; 152
   6099 64                  998 	.db #0x64	; 100	'd'
   609A 44                  999 	.db #0x44	; 68	'D'
   609B 64                 1000 	.db #0x64	; 100	'd'
   609C CC                 1001 	.db #0xcc	; 204
   609D E9                 1002 	.db #0xe9	; 233
   609E FC                 1003 	.db #0xfc	; 252
   609F FC                 1004 	.db #0xfc	; 252
   60A0 FC                 1005 	.db #0xfc	; 252
   60A1 E9                 1006 	.db #0xe9	; 233
   60A2 D6                 1007 	.db #0xd6	; 214
   60A3 FC                 1008 	.db #0xfc	; 252
   60A4 FC                 1009 	.db #0xfc	; 252
   60A5 FC                 1010 	.db #0xfc	; 252
   60A6 FC                 1011 	.db #0xfc	; 252
   60A7 FC                 1012 	.db #0xfc	; 252
   60A8 E9                 1013 	.db #0xe9	; 233
   60A9 C6                 1014 	.db #0xc6	; 198
   60AA 98                 1015 	.db #0x98	; 152
   60AB 64                 1016 	.db #0x64	; 100	'd'
   60AC 44                 1017 	.db #0x44	; 68	'D'
   60AD CC                 1018 	.db #0xcc	; 204
   60AE 64                 1019 	.db #0x64	; 100	'd'
   60AF E9                 1020 	.db #0xe9	; 233
   60B0 FC                 1021 	.db #0xfc	; 252
   60B1 FC                 1022 	.db #0xfc	; 252
   60B2 FC                 1023 	.db #0xfc	; 252
   60B3 FC                 1024 	.db #0xfc	; 252
   60B4 C3                 1025 	.db #0xc3	; 195
   60B5 FC                 1026 	.db #0xfc	; 252
   60B6 FC                 1027 	.db #0xfc	; 252
   60B7 FC                 1028 	.db #0xfc	; 252
   60B8 FC                 1029 	.db #0xfc	; 252
   60B9 FC                 1030 	.db #0xfc	; 252
   60BA E9                 1031 	.db #0xe9	; 233
   60BB 98                 1032 	.db #0x98	; 152
   60BC 98                 1033 	.db #0x98	; 152
   60BD 64                 1034 	.db #0x64	; 100	'd'
   60BE 00                 1035 	.db #0x00	; 0
   60BF CC                 1036 	.db #0xcc	; 204
   60C0 64                 1037 	.db #0x64	; 100	'd'
   60C1 C9                 1038 	.db #0xc9	; 201
   60C2 FC                 1039 	.db #0xfc	; 252
   60C3 FC                 1040 	.db #0xfc	; 252
   60C4 FC                 1041 	.db #0xfc	; 252
   60C5 FC                 1042 	.db #0xfc	; 252
   60C6 E9                 1043 	.db #0xe9	; 233
   60C7 C3                 1044 	.db #0xc3	; 195
   60C8 FC                 1045 	.db #0xfc	; 252
   60C9 FC                 1046 	.db #0xfc	; 252
   60CA FC                 1047 	.db #0xfc	; 252
   60CB FC                 1048 	.db #0xfc	; 252
   60CC E9                 1049 	.db #0xe9	; 233
   60CD 98                 1050 	.db #0x98	; 152
   60CE 98                 1051 	.db #0x98	; 152
   60CF CC                 1052 	.db #0xcc	; 204
   60D0 00                 1053 	.db #0x00	; 0
   60D1 CC                 1054 	.db #0xcc	; 204
   60D2 64                 1055 	.db #0x64	; 100	'd'
   60D3 C9                 1056 	.db #0xc9	; 201
   60D4 D6                 1057 	.db #0xd6	; 214
   60D5 FC                 1058 	.db #0xfc	; 252
   60D6 FC                 1059 	.db #0xfc	; 252
   60D7 FC                 1060 	.db #0xfc	; 252
   60D8 FC                 1061 	.db #0xfc	; 252
   60D9 FC                 1062 	.db #0xfc	; 252
   60DA C3                 1063 	.db #0xc3	; 195
   60DB D6                 1064 	.db #0xd6	; 214
   60DC FC                 1065 	.db #0xfc	; 252
   60DD FC                 1066 	.db #0xfc	; 252
   60DE C3                 1067 	.db #0xc3	; 195
   60DF CC                 1068 	.db #0xcc	; 204
   60E0 98                 1069 	.db #0x98	; 152
   60E1 88                 1070 	.db #0x88	; 136
   60E2 00                 1071 	.db #0x00	; 0
   60E3 CC                 1072 	.db #0xcc	; 204
   60E4 64                 1073 	.db #0x64	; 100	'd'
   60E5 98                 1074 	.db #0x98	; 152
   60E6 C3                 1075 	.db #0xc3	; 195
   60E7 FC                 1076 	.db #0xfc	; 252
   60E8 FC                 1077 	.db #0xfc	; 252
   60E9 AD                 1078 	.db #0xad	; 173
   60EA 0F                 1079 	.db #0x0f	; 15
   60EB FC                 1080 	.db #0xfc	; 252
   60EC FC                 1081 	.db #0xfc	; 252
   60ED C3                 1082 	.db #0xc3	; 195
   60EE D6                 1083 	.db #0xd6	; 214
   60EF E9                 1084 	.db #0xe9	; 233
   60F0 C6                 1085 	.db #0xc6	; 198
   60F1 64                 1086 	.db #0x64	; 100	'd'
   60F2 30                 1087 	.db #0x30	; 48	'0'
   60F3 88                 1088 	.db #0x88	; 136
   60F4 00                 1089 	.db #0x00	; 0
   60F5 CC                 1090 	.db #0xcc	; 204
   60F6 64                 1091 	.db #0x64	; 100	'd'
   60F7 CC                 1092 	.db #0xcc	; 204
   60F8 61                 1093 	.db #0x61	; 97	'a'
   60F9 D6                 1094 	.db #0xd6	; 214
   60FA FC                 1095 	.db #0xfc	; 252
   60FB 5E                 1096 	.db #0x5e	; 94
   60FC AD                 1097 	.db #0xad	; 173
   60FD 0F                 1098 	.db #0x0f	; 15
   60FE 5E                 1099 	.db #0x5e	; 94
   60FF FC                 1100 	.db #0xfc	; 252
   6100 FC                 1101 	.db #0xfc	; 252
   6101 C3                 1102 	.db #0xc3	; 195
   6102 CC                 1103 	.db #0xcc	; 204
   6103 64                 1104 	.db #0x64	; 100	'd'
   6104 30                 1105 	.db #0x30	; 48	'0'
   6105 88                 1106 	.db #0x88	; 136
   6106 00                 1107 	.db #0x00	; 0
   6107 44                 1108 	.db #0x44	; 68	'D'
   6108 30                 1109 	.db #0x30	; 48	'0'
   6109 CC                 1110 	.db #0xcc	; 204
   610A 30                 1111 	.db #0x30	; 48	'0'
   610B C3                 1112 	.db #0xc3	; 195
   610C C3                 1113 	.db #0xc3	; 195
   610D FC                 1114 	.db #0xfc	; 252
   610E FC                 1115 	.db #0xfc	; 252
   610F FC                 1116 	.db #0xfc	; 252
   6110 0F                 1117 	.db #0x0f	; 15
   6111 FC                 1118 	.db #0xfc	; 252
   6112 C3                 1119 	.db #0xc3	; 195
   6113 92                 1120 	.db #0x92	; 146
   6114 98                 1121 	.db #0x98	; 152
   6115 64                 1122 	.db #0x64	; 100	'd'
   6116 64                 1123 	.db #0x64	; 100	'd'
   6117 00                 1124 	.db #0x00	; 0
   6118 00                 1125 	.db #0x00	; 0
   6119 44                 1126 	.db #0x44	; 68	'D'
   611A 98                 1127 	.db #0x98	; 152
   611B CC                 1128 	.db #0xcc	; 204
   611C 98                 1129 	.db #0x98	; 152
   611D C3                 1130 	.db #0xc3	; 195
   611E 0F                 1131 	.db #0x0f	; 15
   611F C3                 1132 	.db #0xc3	; 195
   6120 FC                 1133 	.db #0xfc	; 252
   6121 FC                 1134 	.db #0xfc	; 252
   6122 E9                 1135 	.db #0xe9	; 233
   6123 C3                 1136 	.db #0xc3	; 195
   6124 92                 1137 	.db #0x92	; 146
   6125 64                 1138 	.db #0x64	; 100	'd'
   6126 98                 1139 	.db #0x98	; 152
   6127 CC                 1140 	.db #0xcc	; 204
   6128 64                 1141 	.db #0x64	; 100	'd'
   6129 00                 1142 	.db #0x00	; 0
   612A 00                 1143 	.db #0x00	; 0
   612B 44                 1144 	.db #0x44	; 68	'D'
   612C 98                 1145 	.db #0x98	; 152
   612D 64                 1146 	.db #0x64	; 100	'd'
   612E CC                 1147 	.db #0xcc	; 204
   612F 61                 1148 	.db #0x61	; 97	'a'
   6130 C3                 1149 	.db #0xc3	; 195
   6131 C3                 1150 	.db #0xc3	; 195
   6132 C3                 1151 	.db #0xc3	; 195
   6133 E9                 1152 	.db #0xe9	; 233
   6134 C3                 1153 	.db #0xc3	; 195
   6135 30                 1154 	.db #0x30	; 48	'0'
   6136 30                 1155 	.db #0x30	; 48	'0'
   6137 CC                 1156 	.db #0xcc	; 204
   6138 64                 1157 	.db #0x64	; 100	'd'
   6139 98                 1158 	.db #0x98	; 152
   613A CC                 1159 	.db #0xcc	; 204
   613B 00                 1160 	.db #0x00	; 0
   613C 00                 1161 	.db #0x00	; 0
   613D 00                 1162 	.db #0x00	; 0
   613E 98                 1163 	.db #0x98	; 152
   613F 30                 1164 	.db #0x30	; 48	'0'
   6140 CC                 1165 	.db #0xcc	; 204
   6141 98                 1166 	.db #0x98	; 152
   6142 D6                 1167 	.db #0xd6	; 214
   6143 FC                 1168 	.db #0xfc	; 252
   6144 C3                 1169 	.db #0xc3	; 195
   6145 C3                 1170 	.db #0xc3	; 195
   6146 FC                 1171 	.db #0xfc	; 252
   6147 CC                 1172 	.db #0xcc	; 204
   6148 CC                 1173 	.db #0xcc	; 204
   6149 98                 1174 	.db #0x98	; 152
   614A 64                 1175 	.db #0x64	; 100	'd'
   614B 30                 1176 	.db #0x30	; 48	'0'
   614C 88                 1177 	.db #0x88	; 136
   614D 00                 1178 	.db #0x00	; 0
   614E 00                 1179 	.db #0x00	; 0
   614F 00                 1180 	.db #0x00	; 0
   6150 CC                 1181 	.db #0xcc	; 204
   6151 30                 1182 	.db #0x30	; 48	'0'
   6152 64                 1183 	.db #0x64	; 100	'd'
   6153 CC                 1184 	.db #0xcc	; 204
   6154 FC                 1185 	.db #0xfc	; 252
   6155 FC                 1186 	.db #0xfc	; 252
   6156 FC                 1187 	.db #0xfc	; 252
   6157 FC                 1188 	.db #0xfc	; 252
   6158 EC                 1189 	.db #0xec	; 236
   6159 98                 1190 	.db #0x98	; 152
   615A CC                 1191 	.db #0xcc	; 204
   615B 30                 1192 	.db #0x30	; 48	'0'
   615C CC                 1193 	.db #0xcc	; 204
   615D 64                 1194 	.db #0x64	; 100	'd'
   615E 88                 1195 	.db #0x88	; 136
   615F 00                 1196 	.db #0x00	; 0
   6160 00                 1197 	.db #0x00	; 0
   6161 00                 1198 	.db #0x00	; 0
   6162 44                 1199 	.db #0x44	; 68	'D'
   6163 30                 1200 	.db #0x30	; 48	'0'
   6164 64                 1201 	.db #0x64	; 100	'd'
   6165 30                 1202 	.db #0x30	; 48	'0'
   6166 CC                 1203 	.db #0xcc	; 204
   6167 CC                 1204 	.db #0xcc	; 204
   6168 DC                 1205 	.db #0xdc	; 220
   6169 FC                 1206 	.db #0xfc	; 252
   616A CC                 1207 	.db #0xcc	; 204
   616B 64                 1208 	.db #0x64	; 100	'd'
   616C 30                 1209 	.db #0x30	; 48	'0'
   616D 64                 1210 	.db #0x64	; 100	'd'
   616E 98                 1211 	.db #0x98	; 152
   616F CC                 1212 	.db #0xcc	; 204
   6170 00                 1213 	.db #0x00	; 0
   6171 00                 1214 	.db #0x00	; 0
   6172 00                 1215 	.db #0x00	; 0
   6173 00                 1216 	.db #0x00	; 0
   6174 00                 1217 	.db #0x00	; 0
   6175 CC                 1218 	.db #0xcc	; 204
   6176 64                 1219 	.db #0x64	; 100	'd'
   6177 98                 1220 	.db #0x98	; 152
   6178 30                 1221 	.db #0x30	; 48	'0'
   6179 30                 1222 	.db #0x30	; 48	'0'
   617A 64                 1223 	.db #0x64	; 100	'd'
   617B EC                 1224 	.db #0xec	; 236
   617C CC                 1225 	.db #0xcc	; 204
   617D CC                 1226 	.db #0xcc	; 204
   617E 30                 1227 	.db #0x30	; 48	'0'
   617F CC                 1228 	.db #0xcc	; 204
   6180 64                 1229 	.db #0x64	; 100	'd'
   6181 88                 1230 	.db #0x88	; 136
   6182 00                 1231 	.db #0x00	; 0
   6183 00                 1232 	.db #0x00	; 0
   6184 00                 1233 	.db #0x00	; 0
   6185 00                 1234 	.db #0x00	; 0
   6186 00                 1235 	.db #0x00	; 0
   6187 CC                 1236 	.db #0xcc	; 204
   6188 98                 1237 	.db #0x98	; 152
   6189 98                 1238 	.db #0x98	; 152
   618A CC                 1239 	.db #0xcc	; 204
   618B 30                 1240 	.db #0x30	; 48	'0'
   618C 64                 1241 	.db #0x64	; 100	'd'
   618D CC                 1242 	.db #0xcc	; 204
   618E CC                 1243 	.db #0xcc	; 204
   618F 30                 1244 	.db #0x30	; 48	'0'
   6190 CC                 1245 	.db #0xcc	; 204
   6191 98                 1246 	.db #0x98	; 152
   6192 64                 1247 	.db #0x64	; 100	'd'
   6193 88                 1248 	.db #0x88	; 136
   6194 00                 1249 	.db #0x00	; 0
   6195 00                 1250 	.db #0x00	; 0
   6196 00                 1251 	.db #0x00	; 0
   6197 00                 1252 	.db #0x00	; 0
   6198 00                 1253 	.db #0x00	; 0
   6199 00                 1254 	.db #0x00	; 0
   619A CC                 1255 	.db #0xcc	; 204
   619B CC                 1256 	.db #0xcc	; 204
   619C 64                 1257 	.db #0x64	; 100	'd'
   619D 64                 1258 	.db #0x64	; 100	'd'
   619E 64                 1259 	.db #0x64	; 100	'd'
   619F 64                 1260 	.db #0x64	; 100	'd'
   61A0 98                 1261 	.db #0x98	; 152
   61A1 64                 1262 	.db #0x64	; 100	'd'
   61A2 CC                 1263 	.db #0xcc	; 204
   61A3 30                 1264 	.db #0x30	; 48	'0'
   61A4 CC                 1265 	.db #0xcc	; 204
   61A5 00                 1266 	.db #0x00	; 0
   61A6 00                 1267 	.db #0x00	; 0
   61A7 00                 1268 	.db #0x00	; 0
   61A8 00                 1269 	.db #0x00	; 0
   61A9 00                 1270 	.db #0x00	; 0
   61AA 00                 1271 	.db #0x00	; 0
   61AB 00                 1272 	.db #0x00	; 0
   61AC CC                 1273 	.db #0xcc	; 204
   61AD 64                 1274 	.db #0x64	; 100	'd'
   61AE 30                 1275 	.db #0x30	; 48	'0'
   61AF CC                 1276 	.db #0xcc	; 204
   61B0 CC                 1277 	.db #0xcc	; 204
   61B1 CC                 1278 	.db #0xcc	; 204
   61B2 30                 1279 	.db #0x30	; 48	'0'
   61B3 CC                 1280 	.db #0xcc	; 204
   61B4 30                 1281 	.db #0x30	; 48	'0'
   61B5 CC                 1282 	.db #0xcc	; 204
   61B6 88                 1283 	.db #0x88	; 136
   61B7 00                 1284 	.db #0x00	; 0
   61B8 00                 1285 	.db #0x00	; 0
   61B9 00                 1286 	.db #0x00	; 0
   61BA 00                 1287 	.db #0x00	; 0
   61BB 00                 1288 	.db #0x00	; 0
   61BC 00                 1289 	.db #0x00	; 0
   61BD 00                 1290 	.db #0x00	; 0
   61BE 44                 1291 	.db #0x44	; 68	'D'
   61BF 30                 1292 	.db #0x30	; 48	'0'
   61C0 98                 1293 	.db #0x98	; 152
   61C1 30                 1294 	.db #0x30	; 48	'0'
   61C2 30                 1295 	.db #0x30	; 48	'0'
   61C3 30                 1296 	.db #0x30	; 48	'0'
   61C4 64                 1297 	.db #0x64	; 100	'd'
   61C5 CC                 1298 	.db #0xcc	; 204
   61C6 64                 1299 	.db #0x64	; 100	'd'
   61C7 CC                 1300 	.db #0xcc	; 204
   61C8 00                 1301 	.db #0x00	; 0
   61C9 00                 1302 	.db #0x00	; 0
   61CA 00                 1303 	.db #0x00	; 0
   61CB 00                 1304 	.db #0x00	; 0
   61CC 00                 1305 	.db #0x00	; 0
   61CD 00                 1306 	.db #0x00	; 0
   61CE 00                 1307 	.db #0x00	; 0
   61CF 00                 1308 	.db #0x00	; 0
   61D0 00                 1309 	.db #0x00	; 0
   61D1 98                 1310 	.db #0x98	; 152
   61D2 64                 1311 	.db #0x64	; 100	'd'
   61D3 CC                 1312 	.db #0xcc	; 204
   61D4 30                 1313 	.db #0x30	; 48	'0'
   61D5 64                 1314 	.db #0x64	; 100	'd'
   61D6 CC                 1315 	.db #0xcc	; 204
   61D7 CC                 1316 	.db #0xcc	; 204
   61D8 CC                 1317 	.db #0xcc	; 204
   61D9 88                 1318 	.db #0x88	; 136
   61DA 00                 1319 	.db #0x00	; 0
   61DB 00                 1320 	.db #0x00	; 0
   61DC 00                 1321 	.db #0x00	; 0
   61DD 00                 1322 	.db #0x00	; 0
   61DE 00                 1323 	.db #0x00	; 0
   61DF 00                 1324 	.db #0x00	; 0
   61E0 00                 1325 	.db #0x00	; 0
   61E1 00                 1326 	.db #0x00	; 0
   61E2 00                 1327 	.db #0x00	; 0
   61E3 44                 1328 	.db #0x44	; 68	'D'
   61E4 30                 1329 	.db #0x30	; 48	'0'
   61E5 CC                 1330 	.db #0xcc	; 204
   61E6 CC                 1331 	.db #0xcc	; 204
   61E7 CC                 1332 	.db #0xcc	; 204
   61E8 30                 1333 	.db #0x30	; 48	'0'
   61E9 64                 1334 	.db #0x64	; 100	'd'
   61EA 88                 1335 	.db #0x88	; 136
   61EB 00                 1336 	.db #0x00	; 0
   61EC 00                 1337 	.db #0x00	; 0
   61ED 00                 1338 	.db #0x00	; 0
   61EE 00                 1339 	.db #0x00	; 0
   61EF 00                 1340 	.db #0x00	; 0
   61F0 00                 1341 	.db #0x00	; 0
   61F1 00                 1342 	.db #0x00	; 0
   61F2 00                 1343 	.db #0x00	; 0
   61F3 00                 1344 	.db #0x00	; 0
   61F4 00                 1345 	.db #0x00	; 0
   61F5 00                 1346 	.db #0x00	; 0
   61F6 CC                 1347 	.db #0xcc	; 204
   61F7 98                 1348 	.db #0x98	; 152
   61F8 64                 1349 	.db #0x64	; 100	'd'
   61F9 98                 1350 	.db #0x98	; 152
   61FA 64                 1351 	.db #0x64	; 100	'd'
   61FB 88                 1352 	.db #0x88	; 136
   61FC 00                 1353 	.db #0x00	; 0
   61FD 00                 1354 	.db #0x00	; 0
   61FE 00                 1355 	.db #0x00	; 0
   61FF 00                 1356 	.db #0x00	; 0
   6200 00                 1357 	.db #0x00	; 0
   6201 00                 1358 	.db #0x00	; 0
   6202 00                 1359 	.db #0x00	; 0
   6203 00                 1360 	.db #0x00	; 0
   6204 00                 1361 	.db #0x00	; 0
   6205 00                 1362 	.db #0x00	; 0
   6206 00                 1363 	.db #0x00	; 0
   6207 00                 1364 	.db #0x00	; 0
   6208 44                 1365 	.db #0x44	; 68	'D'
   6209 CC                 1366 	.db #0xcc	; 204
   620A CC                 1367 	.db #0xcc	; 204
   620B CC                 1368 	.db #0xcc	; 204
   620C CC                 1369 	.db #0xcc	; 204
   620D 00                 1370 	.db #0x00	; 0
   620E 00                 1371 	.db #0x00	; 0
   620F 00                 1372 	.db #0x00	; 0
   6210 00                 1373 	.db #0x00	; 0
   6211 00                 1374 	.db #0x00	; 0
   6212 00                 1375 	.db #0x00	; 0
   6213 00                 1376 	.db #0x00	; 0
                           1377 	.area _INITIALIZER
                           1378 	.area _CABS (ABS)
