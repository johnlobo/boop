#!/usr/bin/env python3
"""Recorta los assets del nuevo interfaz desde las maquetas (160x200, Mode 0).

Las maquetas de assets/ui/mockups/ son la referencia: cada pixel es un pixel
Mode 0 y todos los colores son colores firmware del CPC. Este script es
determinista: volver a ejecutarlo regenera los mismos PNG en assets/ui/.

Ademas genera src/assets/ui/ai_icons.s: los iconos de IA como sprites con
mascara entrelazada (byte de mascara, byte de dato) para
cpct_drawSpriteMasked_asm. La mascara sale del alfa del PNG; IMG2SP la
sacaria del pen 0 y borraria el contorno negro.

Uso:  python3 assets/ui/extract_ui_assets.py [--check]
"""
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
MOCK = HERE / "mockups"
MASKED_OUT = ROOT / "src" / "assets" / "ui" / "ai_icons.s"
PIECES_OUT = ROOT / "src" / "assets" / "ui" / "pieces.s"
MASKED = ["ai_icon_1", "ai_icon_2", "ai_icon_3", "ai_icon_4"]

FW = {
    (0, 0, 0): 0, (0, 0, 128): 1, (0, 0, 255): 2, (128, 0, 0): 3,
    (128, 0, 128): 4, (128, 0, 255): 5, (255, 0, 0): 6, (255, 0, 128): 7,
    (255, 0, 255): 8, (0, 128, 0): 9, (0, 128, 128): 10, (0, 128, 255): 11,
    (128, 128, 0): 12, (128, 128, 128): 13, (128, 128, 255): 14,
    (255, 128, 0): 15, (255, 128, 128): 16, (255, 128, 255): 17,
    (0, 255, 0): 18, (0, 255, 128): 19, (0, 255, 255): 20, (128, 255, 0): 21,
    (128, 255, 128): 22, (128, 255, 255): 23, (255, 255, 0): 24,
    (255, 255, 128): 25, (255, 255, 255): 26,
}
BG = (0, 0, 128)          # azul de fondo (firmware 1)
YELLOW = (255, 255, 0)    # firmware 24

# nombre: (maqueta, x0, y0, x1, y1 inclusivos, modo)
#   opaque:      copia tal cual (se pinta sin mascara sobre el fondo azul)
#   transparent: el azul de fondo pasa a alfa 0 (sprite con mascara)
#   only_yellow: solo el marco amarillo, el resto alfa 0
#   button:      opaco; borra el texto negro (x 58..110), deja el chevron
#   icon:        quita el fondo azul y el amarillo de la opcion seleccionada
# x0 siempre par y ancho par: 2 pixels Mode 0 por byte.
CROPS = {
    "logo_big":    ("title.png", 34, 20, 123, 55, "opaque"),
    "logo_small":  ("match.png", 56, 14, 103, 33, "opaque"),
    "title_cats":  ("title.png", 44, 69, 115, 99, "opaque"),
    "menu_button": ("title.png", 36, 109, 123, 129, "button"),
    "cell_blue":   ("match.png", 50, 74, 59, 92, "opaque"),
    "cell_teal":   ("match.png", 60, 74, 69, 92, "opaque"),
    "cursor":      ("match.png", 50, 55, 59, 73, "only_yellow"),
    "panel_p1":    ("match.png", 8, 71, 41, 145, "opaque"),
    "panel_p2":    ("match.png", 118, 71, 151, 145, "opaque"),
    "ai_icon_1":   ("ai_select.png", 32, 62, 43, 74, "icon"),
    "ai_icon_2":   ("ai_select.png", 32, 87, 43, 99, "icon"),
    "ai_icon_3":   ("ai_select.png", 32, 112, 43, 124, "icon"),
    "ai_icon_4":   ("ai_select.png", 32, 137, 43, 149, "icon"),
}


def crop(name, spec):
    src, x0, y0, x1, y1, mode = spec
    assert x0 % 2 == 0 and (x1 - x0 + 1) % 2 == 0, f"{name}: no alineado a byte"
    im = Image.open(MOCK / src).convert("RGB").crop((x0, y0, x1 + 1, y1 + 1))
    out = Image.new("RGBA", im.size)
    for y in range(im.height):
        for x in range(im.width):
            c = im.getpixel((x, y))
            assert c in FW, f"{name}: color {c} no es firmware"
            if mode == "button" and c == (0, 0, 0) and 58 <= x0 + x <= 110 \
                    and 112 <= y0 + y <= 121:
                c = YELLOW
            keep = {"button": True, "opaque": True, "transparent": c != BG,
                    "only_yellow": c == YELLOW,
                    "icon": c not in (BG, YELLOW)}[mode]
            out.putpixel((x, y), c + (255,) if keep else (0, 0, 0, 0))
    return out


def palette():
    """PALETTE0 de cfg/image_conversion.mk: pen -> color firmware."""
    for line in (ROOT / "cfg" / "image_conversion.mk").read_text().splitlines():
        if line.startswith("PALETTE0="):
            return [int(v) for v in line.split("=", 1)[1].split()]
    sys.exit("PALETTE0 no encontrada")


def mode0_byte(left, right):
    v = 0
    for bit, (pl, pr) in enumerate([(7, 6), (3, 2), (5, 4), (1, 0)]):
        v |= ((left >> bit) & 1) << pl | ((right >> bit) & 1) << pr
    return v


def masked_source(images):
    pen = {fw: i for i, fw in enumerate(palette())}
    out = [";; GENERADO por assets/ui/extract_ui_assets.py. No editar a mano.",
           ";; Sprites con mascara entrelazada (mascara, dato) para cpct_drawSpriteMasked_asm.",
           ".area _CODE"]
    for name, img in images:
        out.append(f"_s_{name}::")
        for y in range(img.height):
            row = []
            for x in range(0, img.width, 2):
                px = [img.getpixel((x + k, y)) for k in (0, 1)]
                mask = (0xAA if px[0][3] == 0 else 0) | (0x55 if px[1][3] == 0 else 0)
                pens = [pen[FW[p[:3]]] if p[3] else 0 for p in px]
                row += [mask, mode0_byte(*pens)]
            out.append("    .db " + ", ".join(f"0x{v:02X}" for v in row))
    return "\n".join(out) + "\n"


# Gatos de la partida. La forma sale del panel P1 de match.png; el juego de
# colores 0 es P1 y 1..4 son P2 segun el nivel de IA: (cuerpo, sombra) firmware.
PIECE_SRC = {"cat": (14, 96), "kitten": (14, 122)}      # 12x12
PIECE_W, PIECE_H, PIECE_BOARD_W = 12, 12, 10
PIECE_COLORS = [(15, 25), (11, 23), (22, 25), (14, 25), (16, 25)]


def piece(kind, color, x0=0, width=PIECE_W):
    """RGBA; x0 = pixels de desplazamiento a la derecha."""
    im = Image.open(MOCK / "match.png").convert("RGB")
    rgb = {fw: c for c, fw in FW.items()}
    swap = {rgb[15]: rgb[PIECE_COLORS[color][0]], rgb[25]: rgb[PIECE_COLORS[color][1]]}
    ox, oy = PIECE_SRC[kind]
    out = Image.new("RGBA", (width, PIECE_H))
    for y in range(PIECE_H):
        for x in range(PIECE_W):
            c = im.getpixel((ox + x, oy + y))
            if c != BG and x + x0 < width:
                out.putpixel((x + x0, y), swap.get(c, c) + (255,))
    return out


def piece_images():
    """Tablero (10x12; la cola del gato pierde 1 pixel) y panel (12x12; en P2
    va 1 pixel a la derecha porque su panel empieza en x impar)."""
    for n in range(len(PIECE_COLORS)):
        for kind in PIECE_SRC:
            yield f"{kind}_{n}", piece(kind, n, 0, PIECE_BOARD_W)
            yield f"hud_{kind}_{n}", piece(kind, n, 1 if n else 0)


def main():
    check = "--check" in sys.argv
    stale = []
    for name, spec in CROPS.items():
        img = crop(name, spec)
        path = HERE / f"{name}.png"
        if check:
            if not path.exists() or Image.open(path).convert("RGBA").tobytes() != img.tobytes():
                stale.append(name)
        else:
            img.save(path)
            print(f"{name:12s} {img.width:3d}x{img.height:<3d} {img.width // 2 * img.height:5d} bytes")
    src = masked_source([(n, crop(n, CROPS[n])) for n in MASKED])
    if check:
        if not MASKED_OUT.exists() or MASKED_OUT.read_text() != src:
            stale.append(str(MASKED_OUT.relative_to(ROOT)))
    else:
        MASKED_OUT.write_text(src)
    src = masked_source(list(piece_images()))
    if check:
        if not PIECES_OUT.exists() or PIECES_OUT.read_text() != src:
            stale.append(str(PIECES_OUT.relative_to(ROOT)))
    else:
        PIECES_OUT.write_text(src)
    if stale:
        sys.exit("desactualizados: " + ", ".join(stale))


if __name__ == "__main__":
    main()
