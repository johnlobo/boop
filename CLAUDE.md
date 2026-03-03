# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Amstrad CPC game called **boop**, written in Z80 assembly using the **CPCtelera** game engine. It targets Mode 0 (160x200, 16 colors) and loads at memory address `0x4000`.

## Build Commands

```bash
make            # Build the project (produces .cdt, .dsk, .sna files)
make clean      # Clean compiled objects
make cleanall   # Clean everything including generated assets
```

Requires the `CPCT_PATH` environment variable pointing to the CPCtelera installation. The build toolchain uses SDCC (Small Device C Compiler) with its Z80 assembler.

To run in an emulator: `cpct_winape -as -f` (Windows/Linux) or `cpct_rvm -as -f` (macOS).

## Architecture

### Source Layout

```
src/
  main.s          - Entry point (_main::), transparency table at 0x100, calls sys_game_init/update
  common.h.s      - Global .globl declarations, sprite refs, CPCtelera imports, constants, shared macros
  sys/            - Low-level system modules
  man/            - High-level game-logic modules
  assets/         - Generated sprite/bg C arrays (do not edit by hand)
```

**sys/ modules** (each has a `.h.s` header + `.s` implementation):
- **render** - Video init (mode, palette, border), screen clear, sprite drawing, `drawSpriteMaskedAlignedColorizeM0` for color-replaced masked sprites. Has a logical double-buffer (front/back tracked by `sys_render_front_buffer`/`sys_render_back_buffer`).
- **system** - Firmware disable, chain of 6 interrupt handlers cycling per frame; handler 2 scans keyboard.
- **input** - Keyboard dispatch table, wait-for-key, `sys_input_getKeyPressed` for polled reads.
- **messages** - Windowed message overlay with background save/restore via 3000-byte `message_buffer`.
- **text** - Font rendering with 5-color swap table, string utilities, BCD number display using digit sprites.
- **util** - 8-bit multiply (`sys_util_h_times_e`), 16-bit divide (`sys_util_hl_div_c`), BCD arithmetic, RNG, frame delay, CRTC fade/shake (`sys_util_fadeIn`/`fadeOut`/`temblor`).

**man/ modules** (each has a `.h.s` header + `.s` implementation):
- **game** (`sys_game_init` / `sys_game_update`) - Top-level state machine: `GAME_STATE_MENU=0` / `GAME_STATE_PLAYING=1`. Waits on `man_menu_confirmed` to transition from menu to match.
- **menu** (`man_menu_init` / `man_menu_update` / `man_menu_draw`) - Menu navigation; exposes `man_menu_selected` and `man_menu_confirmed`.
- **match** (`man_match_init` / `man_match_update` / `man_match_draw_hud`) - Turn-based 6×6 board game. Manages `man_match_player1`/`player2` structs and `man_match_num_players`.

### Code Conventions

- Assembly files use `.s` extension; headers use `.h.s`.
- Module headers declare `.globl` symbols and macros; implementations `.include` their own header.
- Each module declares `.area _DATA` and `.area _CODE` sections (required by SDCC linker).
- Self-modifying code is used in input key scanning, sprite colorize, and draw_box — these routines cannot run from ROM.
- Comments mix English and Spanish.

### Key Macros (render.h.s)

```
ld_de_backbuffer          — load DE with back-buffer start address
ld_de_frontbuffer         — load DE with front-buffer start address
m_screenPtr_backbuffer X, Y  — compute screen ptr into DE for back buffer at (X bytes, Y px)
m_screenPtr_frontbuffer X, Y — same for front buffer
m_draw_blank_small_number BG — draw a blank 4×5 solid box with colour BG at current DE
```

CPC screen address formula used by the macros: `base + 80*(Y/8) + 2048*(Y&7) + X`

### Asset Pipeline

PNG sprites in `assets/` are auto-converted to C arrays via CPCtelera's `IMG2SP` macros defined in `cfg/image_conversion.mk`. Generated files land in `src/assets/sprites/` (sprites) and `src/assets/bg/` (backgrounds). The firmware palette is `PALETTE0` in that file.

A 256-byte transparency table at absolute address `0x100` (in `main.s`) is used by all masked sprite drawing routines.

### Interrupt System

Six interrupt handlers (`int_handler1`–`int_handler6`) rotate each interrupt, giving predictable per-frame timing. Handler 2 calls `cpct_scanKeyboard_if_asm` so the keyboard buffer is always current.

### Match Board & Player Data

**Board** (`_match_board`) — 36-byte row-major array; cell values:
`BOARD_EMPTY=0`, `BOARD_P1_CAT=1`, `BOARD_P1_KITTEN=2`, `BOARD_P2_CAT=3`, `BOARD_P2_KITTEN=4`

**Grid geometry** (defined in `match.h.s`):
- First cell: X=22 bytes, Y=35 px
- Cell pitch: 7 bytes wide × 24 px tall
- Dimensions: 6 cols × 6 rows
- Cursor color: `CURSOR_COLOR = 0x03` (pen 1 — yellow — both pixels in Mode 0)

**Player struct** (offsets in `match.h.s`):
`score` 4 bytes BCD (0), `cats` 1 (4), `kittens` 1 (5); `sizeof_Player = 6`

### CPCtelera Calling Conventions

- `cpct_getScreenPtr_asm`: DE=VMEM_START, C=X(bytes), B=Y(px) → HL=addr; clobbers AF,BC,HL
- `cpct_drawSpriteMaskedAlignedTable_asm`: DE=dst, BC=sprite_ptr, IXL=width, IXH=height, HL=transparency_table
- `cpct_drawSolidBox_asm`: DE=dst, B=height, C=width, A=pattern; clobbers DE
- `cpct_isKeyPressed_asm`: HL=key_constant → A≠0 if pressed; clobbers AF
- `cpct_px2byteM0_asm`: H=left_pen, L=right_pen → A=encoded byte
- Macros: `ld__ixl n`, `ld__ixh n` — load IXL/IXH immediate; `cpctm_screenPtr_asm DE, BASE, X, Y` — compile-time fixed screen ptr
