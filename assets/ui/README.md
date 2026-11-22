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
| `logo_big` | 90x36 | 1620 | titulo |
| `logo_small` | 48x20 | 480 | cabecera de partida, IA y ayuda |
| `title_cats` | 72x31 | 1116 | los tres gatos del titulo |
| `cell_blue`, `cell_teal` | 10x19 | 95 cada uno | casillas del tablero |
| `cursor` | 10x19 | 95 | marco amarillo del selector |
| `ai_icon_1..4` | 12x12 | 72 cada uno | iconos de nivel de IA |
| `panel_p1`, `panel_p2` | 34x75 | 1275 cada uno | solo referencia: se pintan con cajas |

## Uso del framework (GlasnostFWK)

- `ui/text.s`: `fwk_text_draw_big` pinta la fuente a doble altura, con lo que
  una sola fuente da las dos alturas de las maquetas.
- `ui/window.s`: `fwk_window_draw` pinta marco y relleno desde un descriptor de
  7 bytes. Sirve para paneles, botones y caja de ayuda, sin sprites.
- `resources/zx7b.s` (o `cpct_zx7b_decrunch_s` de CPCtelera): comprimir
  `logo_big` y `title_cats`, que solo se ven en el titulo.

Boop no enlaza GlasnostFWK hoy: hay que copiar esos modulos a `src/` o
incluirlos en el build, respetando su contrato de registros
(`docs/reference/architecture-and-api.md` de GlasnostFWK).
