# Nuevo interfaz: maquetas y assets

`mockups/` guarda las cuatro maquetas de referencia (160x200, Mode 0, colores
firmware): `title.png`, `ai_select.png`, `help.png`, `match.png`.
`extract_ui_assets.py` recorta de ellas los PNG de esta carpeta; `--check`
falla si algun PNG no coincide con su maqueta.

## Viabilidad

| Punto | Estado |
|---|---|
| Resolucion y modo | Las maquetas son Mode 0 160x200 exacto: sin cambio de modo. |
| Memoria | Binario actual `0x0200..0x743C` (29,5 KB), una sola pantalla en `0xC000`, pila bajo `0xC000`. Libre: unos 19 KB. Los assets recortados suman unos 5 KB sin los paneles. Cabe. |
| Paleta | Las maquetas usan 14 colores: 0 1 2 10 11 14 15 16 20 22 23 24 25 26. `PALETTE0` actual tiene 3 6 9 12 13 que las maquetas no usan y le faltan 22 23 25. Hay que cambiar la paleta y repintar `cat.png`, `catty.png`, `basket.png`, `grid.png`, `header.png` y `font_chars_0.png`, que usan 3 5 9 12 13 17. Quedan 2 huecos libres. |
| Tablero | Celda de 9x16 px con paso 10x19, tablero 6x6 de 60x114 en `(50,56)`. El tablero actual es 88x148 con sprites de 10x17: hay que redibujar gato y gatito a 9x16 como mucho y cambiar las coordenadas de celda en `match.s`. |
| Texto | Las maquetas usan dos alturas: 5 lineas (ayuda de abajo) y 10 lineas (menus, titulos). Es la misma fuente a doble altura. |
| Marcos y botones | Paneles P1/P2, botones de menu, barra de turno y caja de ayuda son rectangulos de color con sombra negra: se pintan con cajas solidas, no con sprites. |

## Assets

| PNG | Tamano | Bytes Mode 0 | Uso |
|---|---|---|---|
| `logo_big` | 90x36 | 1620 | titulo (opaco) |
| `logo_small` | 48x20 | 480 | cabecera de partida, IA y ayuda |
| `title_cats` | 72x31 | 1116 | los tres gatos del titulo (opaco) |
| `menu_button` | 88x21 | 924 | boton amarillo de la opcion elegida, sin texto |
| `cell_blue`, `cell_teal` | 10x19 | 95 cada uno | casillas del tablero |
| `cursor` | 10x19 | 95 | marco amarillo del selector |
| `ai_icon_1..4` | 12x13 | 156 cada uno con mascara | iconos de nivel de IA (`src/assets/ui/ai_icons.s`) |
| `panel_p1`, `panel_p2` | 34x75 | 1275 cada uno | solo referencia: se pintan con cajas |

## Uso del framework (GlasnostFWK)

- Texto: no se usa `ui/text.s`. Su fuente es de 4x9 (918 bytes) y no es la de
  las maquetas; `src/sys/uitext.s` con la fuente 3x5 extraida ocupa 295 bytes
  de datos y pinta las dos alturas con el mismo codigo.
- `ui/window.s` (`fwk_window_draw`): candidato para paneles P1/P2 y caja de
  ayuda en las pantallas que faltan.
- `resources/zx7b.s` (o `cpct_zx7b_decrunch_s` de CPCtelera): no hace falta
  todavia. El binario ocupa 33 KB (`0x0100..0x81FF`) y la pila esta bajo
  `0xC000`.

Boop no enlaza GlasnostFWK: para usar un modulo hay que copiarlo a `src/`
respetando su contrato de registros (`docs/reference/architecture-and-api.md`
de GlasnostFWK).

## Estado

- Paleta aplicada: `PALETTE0=0 13 2 3 25 15 24 23 16 22 10 14 11 20 1 26`.
- Fuente 3x5: `build_font.py` la extrae de todos los textos de las maquetas
  (28 glyphs, cada letra igual en todas sus apariciones) y anade 17 a mano
  (digitos que faltan, Q, Z, signos y las dos estrellas). 295 bytes, frente a
  846 de la fuente anterior.
- Pantalla de titulo: hecha, identica pixel a pixel a `mockups/title.png`
  (`tests/ui_smoke.py`). El gatito que paseaba por el menu ya no esta: la
  maqueta no lo tiene. Su PNG sigue en `assets/sprites/`.
- Seleccion de IA: hecha, identica a `mockups/ai_select.png`. Botones con
  cajas solidas (no sprites); iconos con mascara generada desde el alfa
  (`src/assets/ui/ai_icons.s`), porque IMG2SP enmascara el pen 0 y borraba
  el contorno negro.
- Pendiente: ayuda y partida. Hasta rediseñar la partida, sus
  casillas oliva salen naranjas y las cestas cambian de color.
