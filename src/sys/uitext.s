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

;;-------------------------------------------------------------------------------
;; sys/uitext: texto opaco 3x5 del nuevo interfaz.
;;
;; Cada caracter es una celda de 2 bytes (4 pixels Mode 0); cada fila del
;; glyph es un byte con las columnas 0..3 en los bits 3..0. Las letras dejan
;; la columna 0 vacia. Se pinta opaco (tinta y fondo), sin mascara, asi que el
;; negro (pen 0) sirve como tinta. Con doble altura cada fila se repite.
;;-------------------------------------------------------------------------------
.module sys_uitext

.include "cpctelera.h.s"
.include "common.h.s"
.include "sys/uitext.h.s"

.area _DATA

;; Byte de video por par de pixels: indice = (izquierdo << 1) | derecho,
;; 1 = tinta, 0 = fondo.
_ut_combo:  .db 0, 0, 0, 0
_ut_double: .db 0
_ut_byte0:  .db 0

.area _CODE

;;-----------------------------------------------------------------
;; sys_uitext_set_colors
;;   Entrada: L = pen de tinta, H = pen de fondo
;;   Salida:  -
;;   Destruye: AF, BC, DE, HL
;;
sys_uitext_set_colors::
   ld (_ut_pens), hl
   ld a, h
   ld l, a
   call cpct_px2byteM0_asm           ;; L = izquierdo, H = derecho -> L
   ld a, l
   ld (_ut_combo + 0), a             ;; fondo / fondo
   ld hl, (_ut_pens)
   ld a, l
   ld l, h
   ld h, a                           ;; L = fondo, H = tinta
   call cpct_px2byteM0_asm
   ld a, l
   ld (_ut_combo + 1), a             ;; fondo / tinta
   ld hl, (_ut_pens)                 ;; L = tinta, H = fondo
   call cpct_px2byteM0_asm
   ld a, l
   ld (_ut_combo + 2), a             ;; tinta / fondo
   ld hl, (_ut_pens)
   ld a, l
   ld h, a
   call cpct_px2byteM0_asm
   ld a, l
   ld (_ut_combo + 3), a             ;; tinta / tinta
   ret
_ut_pens: .dw 0

;;-----------------------------------------------------------------
;; sys_uitext_draw
;;   Pinta una cadena terminada en 0 con los colores de
;;   sys_uitext_set_colors. Caracteres validos: ' '..'Z'.
;;   Entrada: HL = cadena, DE = memoria de video (byte de la celda),
;;            A  = UITEXT_SINGLE | UITEXT_DOUBLE
;;   Salida:  -
;;   Destruye: AF, BC, DE, HL
;;
sys_uitext_draw::
   ld (_ut_double), a
_ut_char:
   ld a, (hl)
   or a
   ret z
   push hl                           ;; cadena
   push de                           ;; celda
   sub #32                           ;; glyph = _font3x5 + (c - 32) * 5
   ld l, a
   ld h, #0
   ld b, h
   ld c, l
   add hl, hl
   add hl, hl
   add hl, bc
   ld bc, #_font3x5
   add hl, bc
   ld b, #5
_ut_row:
   ld a, (hl)
   inc hl
   push hl
   push bc
   ld c, a
   rrca                              ;; byte 0: columnas 0 y 1 (bits 3, 2)
   rrca
   and #3
   ld hl, #_ut_combo
   add_hl_a
   ld a, (hl)
   ld (_ut_byte0), a
   ld a, c                           ;; byte 1: columnas 2 y 3 (bits 1, 0)
   and #3
   ld hl, #_ut_combo
   add_hl_a
   ld c, (hl)
   ld a, (_ut_byte0)
   ld b, a
   call _ut_put
   ld a, (_ut_double)
   or a
   call nz, _ut_put
   pop bc
   pop hl
   djnz _ut_row
   pop de
   inc de
   inc de
   pop hl
   inc hl
   jr _ut_char

;; Escribe B, C en DE, DE+1 y baja DE una linea de pantalla.
;; Destruye: AF, DE
_ut_put:
   ld a, b
   ld (de), a
   inc de
   ld a, c
   ld (de), a
   dec de
   ld a, d
   add a, #0x08
   ld d, a
   and #0x38
   ret nz
   ld a, e
   add a, #0x50
   ld e, a
   ld a, d
   adc a, #0xC0
   ld d, a
   ret
