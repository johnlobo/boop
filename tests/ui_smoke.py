#!/usr/bin/env python3
"""Compara pantallas reales del juego con sus maquetas (assets/ui/mockups).

Arranca boop.dsk en AmSpiriT-Lite (API REST), pulsa teclas y exige que la
captura, reducida a 160x200 y a colores firmware, sea identica a la maqueta.

Uso (desde la raiz del repo, despues de make):
  flock /tmp/amspirit.lock python3 tests/ui_smoke.py \
      --emulator /config/workspace/tools/amspirit-lite/run.sh [--save DIR]
"""
import argparse
import io
import json
import os
import signal
import socket
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
API = ""                         # lo fija main() segun --port
VK_UP, VK_DOWN = 153, 155        # CORE_rVK de los cursores (matriz fila 0)
VK_ESC = 151                     # matriz fila 8, bit 2

# (nombre, teclas desde la pantalla anterior, maqueta)
CASES = [
    ("title", [" "], "title.png"),
    ("title_wrap", [VK_DOWN, VK_DOWN, VK_DOWN], "title.png"),
    ("ai_select", ["\n"], "ai_select.png"),
    ("ai_select_wrap", [VK_DOWN, VK_DOWN, VK_DOWN, VK_DOWN], "ai_select.png"),
    ("ai_back", [VK_ESC], "title.png"),
    ("help", [VK_UP, "\n"], "help.png"),
    ("help_back", ["\n"], "title.png"),
    ("match", ["\n", "\n"], "match.png"),
    ("match_move", [VK_DOWN, VK_UP], "match.png"),
    ("match_esc", [VK_ESC, "n"], "match.png"),
]


def get(path):
    with urllib.request.urlopen(API + path, timeout=3) as r:
        return r.read()


def post(path, data):
    req = urllib.request.Request(API + path, data=json.dumps(data).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=3) as r:
        return r.read()


def wait_typing():
    while json.loads(get("/api/ping")).get("emu", {}).get("autotyping"):
        time.sleep(0.2)


def press(key):
    if isinstance(key, int):
        post("/api/keypress", {"vk": key})
    else:
        post("/api/keytype", {"text": key})
    wait_typing()
    time.sleep(2.5)


def near(c):
    return tuple(0 if v < 64 else 128 if v < 192 else 255 for v in c)


def to_cpc(png):
    """Recorta el borde y reduce la captura a 160x200 pixels Mode 0."""
    sh = Image.open(io.BytesIO(png)).convert("RGB")
    w, h = sh.size
    xs = [x for x in range(w) if near(sh.getpixel((x, h // 2))) != (0, 0, 0)]
    ys = [y for y in range(h) if near(sh.getpixel((w // 2, y))) != (0, 0, 0)]
    sx, sy = (xs[-1] - xs[0] + 1) / 160, (ys[-1] - ys[0] + 1) / 200
    out = Image.new("RGB", (160, 200))
    for y in range(200):
        for x in range(160):
            out.putpixel((x, y), near(sh.getpixel((int(xs[0] + (x + .5) * sx),
                                                   int(ys[0] + (y + .5) * sy)))))
    return out


def main():
    global API
    ap = argparse.ArgumentParser()
    ap.add_argument("--emulator", required=True)
    ap.add_argument("--dsk", default=str(ROOT / "boop.dsk"))
    ap.add_argument("--save", type=Path, help="guarda aqui las capturas")
    ap.add_argument("--port", type=int, default=6138)
    args = ap.parse_args()
    API = f"http://127.0.0.1:{args.port}"
    with socket.socket() as probe:         # otro emulador ahi = probar su juego
        if probe.connect_ex(("127.0.0.1", args.port)) == 0:
            sys.exit(f"puerto {args.port} ocupado por otro emulador: usa --port")

    proc = subprocess.Popen([args.emulator, "--web-server",
                             "--web-port", str(args.port), args.dsk],
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                            start_new_session=True)
    failed = 0
    try:
        for _ in range(60):
            try:
                get("/api/ping")
                break
            except OSError:
                time.sleep(0.5)
        time.sleep(9)                      # ROM y BASIC listos
        post("/api/keytype", {"text": 'run"boop\n'})
        wait_typing()
        time.sleep(14)                     # carga de disco y "PRESS ANY KEY"
        for name, keys, mock in CASES:
            for k in keys:
                press(k)
            shot = to_cpc(get("/api/screenshot?crop=1"))
            if args.save:
                args.save.mkdir(parents=True, exist_ok=True)
                shot.save(args.save / f"{name}.png")
            ref = Image.open(ROOT / "assets" / "ui" / "mockups" / mock).convert("RGB")
            bad = sum(1 for y in range(200) for x in range(160)
                      if shot.getpixel((x, y)) != ref.getpixel((x, y)))
            print(f"{'ok' if bad == 0 else 'FALLO'} {name}: {bad} pixels distintos de {mock}")
            failed += bad != 0
    finally:
        os.killpg(proc.pid, signal.SIGTERM)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
