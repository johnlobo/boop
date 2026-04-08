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

VSCode tasks for `make`, `clean`, `cleanall`, and `run` are configured in [.vscode/tasks.json](.vscode/tasks.json).

**Version string**: bump `_game_loaded_string` in `src/man/game.s` after every change. Currently **V.016**. This is mandatory — always increment before finishing any task.

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
- **render** - Video init (mode, palette, border), screen clear, sprite drawing, `drawSpriteMaskedAlignedColorizeM0` for color-replaced masked sprites. Has a logical double-buffer (front/back tracked by `sys_render_front_buffer`/`sys_render_back_buffer`). `sys_render_draw_screen` draws the full static chrome (header, baskets, cat/catty icons, grid); `sys_render_draw_grid` redraws only the grid background — use this when refreshing the board without touching the HUD.
- **system** - Firmware disable, chain of 6 interrupt handlers cycling per frame; handler 2 scans keyboard.
- **input** - Keyboard dispatch table, wait-for-key, `sys_input_getKeyPressed` for polled reads.
- **messages** - Windowed message overlay with background save/restore via 3000-byte `message_buffer`.
- **text** - Font rendering with 5-color swap table, string utilities, BCD number display using digit sprites.
- **util** - 8-bit multiply (`sys_util_h_times_e`), 16-bit divide (`sys_util_hl_div_c`), BCD arithmetic, RNG, frame delay, CRTC fade/shake (`sys_util_fadeIn`/`fadeOut`/`temblor`).

**man/ modules** (each has a `.h.s` header + `.s` implementation):
- **game** (`sys_game_init` / `sys_game_update`) - Top-level state machine: `GAME_STATE_MENU=0` / `GAME_STATE_PLAYING=1` / `GAME_STATE_HELP=2`. Waits on `man_menu_confirmed` to transition from menu to match.
- **menu** (`man_menu_init` / `man_menu_update` / `man_menu_draw`) - Menu navigation; exposes `man_menu_selected` and `man_menu_confirmed`.
- **match** (`man_match_init` / `man_match_update` / `man_match_draw_hud`) - Turn-based 6×6 board game. Manages `man_match_player1`/`player2` structs and `man_match_num_players`.
- **help** (`man_help_init` / `man_help_update`) - Help/rules screen; exposes `man_help_done` (set to 1 when user exits).

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
- First cell: X=19 bytes, Y=36 px
- Cell pitch: 7 bytes wide × 24 px tall
- Dimensions: 6 cols × 6 rows
- Cursor color: `CURSOR_COLOR = 0x3C` (pen 6 — bright yellow — both pixels in Mode 0)
- Blocked cursor: `BLOCKED_CURSOR_COLOR = 0xF0` (pen 3 — red) — flashed when Space is pressed but the target piece type has 0 remaining

**Player struct** (offsets in `match.h.s`):
`score` 4 bytes BCD (0), `cats` 1 (4), `kittens` 1 (5); `sizeof_Player = 6`

**Initial reserve**: `MATCH_INITIAL_CATS = 0`, `MATCH_INITIAL_KITTENS = 8` — each player starts with 0 cats and 8 kittens in reserve.

### Keyboard Controls (during match)

| Key | Action |
|-----|--------|
| Cursor arrows | Move cursor on the 6×6 grid |
| Space | Toggle `_cursor_piece` between `PIECE_KITTEN` (1) and `PIECE_CAT` (0); flashes red and blocks if the target piece type has 0 in reserve |
| Enter/Return | Place the selected piece at the cursor position (`_match_place_piece`) |
| Escape | Open "ABANDON MATCH? (Y/N)" dialog; Y sets `_match_cancelled=1`, N/Esc resumes |

**`_cursor_piece` state**: starts each turn as `PIECE_KITTEN` (or forced to `PIECE_CAT` if the active player has 0 kittens). Board value = `_match_state * 2 + _cursor_piece + 1`.

### Kitten Placement Rules

1. **Empty cell only** — a kitten can only be placed on a cell that is currently `BOARD_EMPTY`.

2. **Boop push** — after placement, every kitten present in any of the (up to 8) surrounding cells is pushed one cell **away** from the newly placed kitten. The push direction for each neighbor is the vector from the new kitten to that neighbor (i.e. the neighbor moves one cell further away in the same direction).

3. **Out-of-bounds ejection** — if the push would move a kitten outside the 6×6 grid, the kitten is removed from the board and the **owner's kitten count is incremented** (it is returned to that player's reserve).

4. **Piece interactions** — kittens boop only neighboring kittens; cats are immune to kittens. When a **cat** is placed it boops all neighboring pieces (both kittens and cats). Ejected kittens return to the owner's kitten reserve; ejected cats return to the owner's cat reserve. Kitten boop: `_match_boop`; cat boop: `_match_boop_cat`. Piece owner: values 1–2 = P1, 3–4 = P2. Piece type: odd value = cat, even value = kitten.

5. **Three-in-a-row conversion** — after any placement and boop, the board is scanned for 3 consecutive same-colour pieces (any mix of cats and kittens of the same player) in any row or column. For each match: kittens in the line are removed from the board and the owner gains +1 cat per kitten; cats in the line stay in place. Triggered for both kitten and cat placement. Implemented in `_match_check_lines` + `_mrl_process_kitten` in `match.s`.

6. **Cat three-in-a-row win** — after each placement, the board is scanned for 3 consecutive cats of the same colour in any row or column. If found, that player wins immediately. `BOARD_P1_CAT=1` → P1 wins; `BOARD_P2_CAT=3` → P2 wins. Implemented in `_match_check_cat_lines` in `match.s`.

7. **No-pieces win** — after boop and line-check resolution (but before toggling the turn), if the placing player has 0 cats AND 0 kittens in reserve, the match ends and the opponent wins. This accounts for pieces that may have been ejected back to the reserve during boop. Inline in `_match_place_piece` at `_mpp_pe_chk` / `_mpp_pe_out`.

Both win conditions call `_match_declare_winner` (A=1 P1, A=2 P2), which shows a "PLAYER X WINS!" window, waits for any key, then sets `_match_cancelled = 1` to return to menu.

### Boop Animation & Turn Announcement

**Boop animation** (`_match_boop_animate` in `match.s`) — replaces the bare `_match_boop`/`_match_boop_cat` calls with a 3-frame visual sequence:
1. **Frame 0**: piece placed, board drawn, 4-frame delay (pre-boop snapshot saved to `_boop_anim_before`)
2. **Frame 1**: boop executed, destination cells cleared into `_boop_transit_buf` (16 bytes, up to 8 entries of offset+value), board redrawn with sources gone and destinations empty, 3-frame delay
3. **Frame 2**: destinations restored in board; caller then redraws

`_boop_transit_cnt` tracks the number of valid entries in `_boop_transit_buf`.

**Turn announcement** (`_match_show_turn_message`) — called as a tail call at end of `man_match_init` (P1 starts) and at end of `_match_place_piece` (after each move, unless `_match_cancelled`). Shows "PLAYER X TURN" in an auto-dismissing window (2 seconds, `A=2` mode): orange background for P1 (pen 5), blue background for P2 (pen 2).

### CPCtelera Calling Conventions

- `cpct_getScreenPtr_asm`: DE=VMEM_START, C=X(bytes), B=Y(px) → HL=addr; clobbers AF,BC,HL
- `cpct_drawSpriteMaskedAlignedTable_asm`: DE=dst, BC=sprite_ptr, IXL=width, IXH=height, HL=transparency_table
- `cpct_drawSolidBox_asm`: DE=dst, B=height, C=width, A=pattern; clobbers DE
- `cpct_isKeyPressed_asm`: HL=key_constant → A≠0 if pressed; clobbers AF
- `cpct_px2byteM0_asm`: H=left_pen, L=right_pen → A=encoded byte
- Macros: `ld__ixl n`, `ld__ixh n` — load IXL/IXH immediate; `cpctm_screenPtr_asm DE, BASE, X, Y` — compile-time fixed screen ptr

### sys_messages_show Calling Convention

```
Input: A=wait_flag (1=block until keypress, auto-restores background on return),
       DE=x/y coord, BC=h/w of window, HL=pointer to message string,
       AF'=window background colour (set via m_msg_w_background before other regs)
Modified: AF, HL, DE, BC
```

**Critical**: `m_msg_w_background BK` (defined in `common.h.s`) clobbers **AF and HL** — it calls `cpct_px2byteM0_asm` and stores the result in `AF'`. Always invoke this macro *first*, then load E, D, B, C, A, HL. If a value must survive the macro call, wrap it with `push af` / `pop af`.

### Struct Definition Macros (common.h.s)

```asm
BeginStruct Foo          ; Foo_offset = 0
Field Foo, bar, 2        ; Foo_bar = 0, advances offset by 2
Field Foo, baz, 1        ; Foo_baz = 2
EndStruct Foo            ; sizeof_Foo = 3
```

### Match Cancellation Flow

`_match_cancelled` (byte in `match.h.s`) is the signal from match back to the game loop:
- Set to `1` by `_match_declare_winner` after the win/loss window is dismissed.
- Polled each frame by `man_match_update`; when set, it returns and `man_game_update` transitions back to `GAME_STATE_MENU`.
