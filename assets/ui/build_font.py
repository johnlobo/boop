#!/usr/bin/env python3
"""Extrae la fuente 3x5 de las maquetas y genera src/assets/ui/font3x5.s.

Cada glyph ocupa una celda de 4 pixels Mode 0 (2 bytes): columna 0 vacia y
tres columnas de tinta. Los textos de 10 lineas son la misma fuente a doble
altura. Para cada texto conocido de las maquetas el script recorta sus glyphs
y exige que todas las apariciones de una letra coincidan pixel a pixel. Las
letras que no salen en ninguna maqueta se definen a mano en HAND.

Formato de salida: 5 bytes por caracter (una fila por byte, bits 3..0 =
columnas 0..3 de la celda), de ' ' (32) a 'Z' (90). Las letras dejan la
columna 0 vacia; un glyph de HAND con 4 columnas puede usarla (estrella '+',
centrada en pixel impar). Caracter sin glyph = celda en blanco.

Uso:  python3 assets/ui/build_font.py [--check]
"""
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "src" / "assets" / "ui" / "font3x5.s"
FIRST, LAST = 32, 90

WHITE, BLACK = (255, 255, 255), (0, 0, 0)
YELLOW, PYELLOW, PCYAN = (255, 255, 0), (255, 255, 128), (128, 255, 255)

# (maqueta, y, altura 5|10, color de tinta, x desde la que buscar, texto)
LINES = [
    ("title.png", 112, 10, BLACK, 50, "ONE PLAYER"),
    ("title.png", 136, 10, WHITE, 40, "TWO PLAYERS"),
    ("title.png", 154, 10, WHITE, 40, "HELP"),
    ("title.png", 183, 10, PCYAN, 20, "ARROWS MOVE ENTER SELECT"),
    ("ai_select.png", 40, 10, PCYAN, 40, "CHOOSE OPPONENT"),
    ("ai_select.png", 63, 10, BLACK, 50, "GATITO TIMIDO"),
    ("ai_select.png", 88, 10, WHITE, 45, "GATO JUGUETON"),
    ("ai_select.png", 113, 10, WHITE, 45, "GATA ASTUTA"),
    ("ai_select.png", 138, 10, WHITE, 45, "MAESTRO FELINO"),
    ("ai_select.png", 170, 10, PCYAN, 20, "ARROWS MOVE ENTER SELECT"),
    ("ai_select.png", 180, 10, PCYAN, 60, "ESC BACK"),
    ("help.png", 50, 10, YELLOW, 15, "GOAL"),
    ("help.png", 64, 5, WHITE, 15, "PLACE CATS AND KITTENS"),
    ("help.png", 75, 5, WHITE, 15, "ON A 6X6 BOARD."),
    ("help.png", 86, 5, WHITE, 15, "FILL A ROW, COLUMN OR"),
    ("help.png", 97, 5, WHITE, 15, "DIAGONAL TO WIN."),
    ("help.png", 118, 10, YELLOW, 15, "CONTROLS"),
    ("help.png", 131, 5, PCYAN, 15, "ARROWS"),
    ("help.png", 131, 5, WHITE, 60, "MOVE CURSOR"),
    ("help.png", 141, 5, PCYAN, 15, "SPACE"),
    ("help.png", 141, 5, WHITE, 60, "TOGGLE PIECE"),
    ("help.png", 151, 5, PCYAN, 15, "ENTER"),
    ("help.png", 151, 5, WHITE, 60, "PLACE PIECE"),
    ("help.png", 176, 10, PYELLOW, 20, "PRESS ENTER TO CONTINUE"),
    ("match.png", 37, 10, PYELLOW, 50, "P1 TURN"),
    ("match.png", 184, 5, PCYAN, 20, "SPACE CHANGE CAT TYPE"),
]

# Glyphs que no aparecen en las maquetas, dibujados en el mismo estilo.
# '+' y '*' son las estrellas del titulo: '+' centrada en la columna 1 de la
# celda (4 columnas), '*' en la columna 2.
HAND = {
    "0": ["XXX", "X.X", "X.X", "X.X", "XXX"],
    "2": ["XX.", "..X", ".X.", "X..", "XXX"],
    "3": ["XX.", "..X", ".X.", "..X", "XX."],
    "4": ["X.X", "X.X", "XXX", "..X", "..X"],
    "5": ["XXX", "X..", "XX.", "..X", "XX."],
    "7": ["XXX", "..X", ".X.", ".X.", ".X."],
    "8": [".X.", "X.X", ".X.", "X.X", ".X."],
    "9": [".X.", "X.X", ".XX", "..X", "XX."],
    "Q": [".X.", "X.X", "X.X", "XX.", ".XX"],
    "Z": ["XXX", "..X", ".X.", "X..", "XXX"],
    "!": [".X.", ".X.", ".X.", "...", ".X."],
    "?": ["XX.", "..X", ".X.", "...", ".X."],
    "-": ["...", "...", "XXX", "...", "..."],
    ":": ["...", ".X.", "...", ".X.", "..."],
    ">": ["X..", ".X.", "..X", ".X.", "X.."],
    "+": [".X..", ".X..", "XXX.", ".X..", ".X.."],
    "*": [".X.", ".X.", "XXX", ".X.", ".X."],
}


def ink_cols(im, y, h, color, x_from):
    return [x for x in range(x_from, 160)
            if any(im.getpixel((x, yy)) == color for yy in range(y, y + h))]


def extract():
    glyphs, where = {}, {}
    for src, y, h, color, x_from, text in LINES:
        im = Image.open(HERE / "mockups" / src).convert("RGB")
        x = x_from
        for word in text.split(" "):
            cols = [c for c in ink_cols(im, y, h, color, x)]
            assert cols, f"{src} y={y}: falta '{word}'"
            x0 = cols[0] - 1                       # celda: columna 0 vacia
            for i, ch in enumerate(word):
                cx = x0 + 4 * i
                rows = []
                for r in range(5):
                    yy = y + r * (h // 5)
                    assert im.getpixel((cx, yy)) != color, \
                        f"{src} y={y} '{word}': columna vacia con tinta"
                    if h == 10:
                        for k in range(4):
                            assert (im.getpixel((cx + k, yy)) == color) == \
                                   (im.getpixel((cx + k, yy + 1)) == color), \
                                f"{src} y={yy} '{word}': no es doble altura"
                    rows.append("".join("X" if im.getpixel((cx + 1 + k, yy)) == color
                                        else "." for k in range(3)))
                if ch in glyphs and glyphs[ch] != rows:
                    sys.exit(f"'{ch}' distinto en {src} y={y} y en {where[ch]}:\n"
                             f"{glyphs[ch]}\n{rows}")
                glyphs.setdefault(ch, rows)
                where.setdefault(ch, f"{src} y={y}")
            x = x0 + 4 * len(word) + 1
    for ch, rows in HAND.items():
        assert ch not in glyphs, f"'{ch}' ya sale en las maquetas: quitalo de HAND"
        glyphs[ch] = rows
    return glyphs


def render():
    glyphs = extract()
    out = [";; GENERADO por assets/ui/build_font.py. No editar a mano.",
           ";; Fuente 3x5: 5 bytes por caracter, ' '..'Z'. bits 3..0 = columnas 0..3.",
           ".area _CODE", "_font3x5::"]
    for code in range(FIRST, LAST + 1):
        ch = chr(code)
        rows = glyphs.get(ch, ["..."] * 5)
        rows = [r if len(r) == 4 else "." + r for r in rows]
        vals = [int(r.replace("X", "1").replace(".", "0"), 2) for r in rows]
        out.append("    .db " + ", ".join(f"0x{v:02X}" for v in vals) + f"   ;; '{ch}'")
    return "\n".join(out) + "\n", glyphs


def main():
    text, glyphs = render()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            sys.exit(f"{OUT} desactualizado: ejecuta assets/ui/build_font.py")
        return
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text)
    found = sorted(set(glyphs) - set(HAND))
    print(f"{len(found)} glyphs de las maquetas, {len(HAND)} a mano -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
