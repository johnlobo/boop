#!/usr/bin/env python3
"""Recorta los assets del nuevo interfaz desde las maquetas (160x200, Mode 0).

Las maquetas de assets/ui/mockups/ son la referencia: cada pixel es un pixel
Mode 0 y todos los colores son colores firmware del CPC. Este script es
determinista: volver a ejecutarlo regenera los mismos PNG en assets/ui/.

Uso:  python3 assets/ui/extract_ui_assets.py [--check]
"""
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
MOCK = HERE / "mockups"

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
#   icon:        quita el fondo azul y el amarillo de la opcion seleccionada
# x0 siempre par y ancho par: 2 pixels Mode 0 por byte.
CROPS = {
    "logo_big":    ("title.png", 34, 20, 123, 55, "transparent"),
    "logo_small":  ("match.png", 56, 14, 103, 33, "transparent"),
    "title_cats":  ("title.png", 46, 69, 117, 99, "transparent"),
    "cell_blue":   ("match.png", 50, 75, 59, 93, "opaque"),
    "cell_teal":   ("match.png", 60, 75, 69, 93, "opaque"),
    "cursor":      ("match.png", 50, 55, 59, 73, "only_yellow"),
    "panel_p1":    ("match.png", 8, 71, 41, 145, "opaque"),
    "panel_p2":    ("match.png", 118, 71, 151, 145, "opaque"),
    "ai_icon_1":   ("ai_select.png", 28, 60, 39, 71, "icon"),
    "ai_icon_2":   ("ai_select.png", 28, 85, 39, 96, "transparent"),
    "ai_icon_3":   ("ai_select.png", 28, 110, 39, 121, "transparent"),
    "ai_icon_4":   ("ai_select.png", 28, 135, 39, 146, "transparent"),
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
            keep = {"opaque": True, "transparent": c != BG,
                    "only_yellow": c == YELLOW,
                    "icon": c not in (BG, YELLOW)}[mode]
            out.putpixel((x, y), c + (255,) if keep else (0, 0, 0, 0))
    return out


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
    if stale:
        sys.exit("desactualizados: " + ", ".join(stale))


if __name__ == "__main__":
    main()
