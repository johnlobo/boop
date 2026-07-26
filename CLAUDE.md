# CLAUDE.md

Guidance for Claude Code in this repo.

## Project

Amstrad CPC game **boop**, Z80 assembly, **CPCtelera** engine. Mode 0 (160x200, 16 colors), loads at `0x4000`.

## Build

```bash
make            # build (.cdt, .dsk, .sna)
make clean      # clean compiled objects
make cleanall   # clean everything incl. generated assets
```

Requires `CPCT_PATH` env var (CPCtelera install). Toolchain: SDCC + its Z80 assembler.

Run in emulator: `cpct_winape -as -f` (Win/Linux) or `cpct_rvm -as -f` (macOS).

VSCode tasks for `make`/`clean`/`cleanall`/`run`: [.vscode/tasks.json](.vscode/tasks.json).

**Version string**: bump `_game_loaded_string` in `src/man/game.s` after every change (currently **V.048**). Mandatory — always increment before finishing a task.

**Dead code**: `./find_unused.sh [src_dir]` finds `label::` defs with no callers/refs elsewhere.

## Architecture

### Source Layout

```
src/
  main.s          - Entry (_main::), transparency table @0x100, calls sys_game_init/update
  common.h.s      - Global .globl decls, sprite refs, CPCtelera imports, constants, shared macros
  sys/            - Low-level system modules
  man/            - High-level game-logic modules
  audio/          - Arkos Tracker 3 AKG exports and generated SDCC player/data
  assets/         - Generated sprite/bg C arrays (do not edit by hand)
```

**sys/ modules** (each: `.h.s` header + `.s` impl):
- **render** - Video init (mode/palette/border), screen clear, sprite drawing, `drawSpriteMaskedAlignedColorizeM0` (color-replaced masked sprites). Logical double-buffer via `sys_render_front_buffer`/`sys_render_back_buffer`. `sys_render_draw_screen` draws full static chrome (header, baskets, cat/catty icons, grid); `sys_render_draw_grid` redraws only grid bg — use to refresh board without touching HUD.
- **system** - Firmware disable, chain of 6 interrupt handlers cycling per frame; handler 2 scans keyboard.
- **input** - Keyboard dispatch table, wait-for-key, `sys_input_getKeyPressed` for polled reads.
- **messages** - Windowed message overlay, bg save/restore via 3000-byte `message_buffer`.
- **text** - Font rendering (5-color swap table), string utils, BCD number display via digit sprites.
- **util** - 8-bit multiply (`sys_util_h_times_e`), 16-bit divide (`sys_util_hl_div_c`), BCD arithmetic, RNG, frame delay, CRTC fade/shake (`sys_util_fadeIn`/`fadeOut`/`temblor`).
- **sound** - Arkos Tracker 3 AKG wrapper. `sys_sound_init` (once, boot), `sys_sound_start_music`/`sys_sound_start_menu_music`/`sys_sound_start_win_music`/`sys_sound_start_lose_music` switch subsongs and enable playback via `_snd_music_active`; `sys_sound_stop` and `sys_sound_play_sfx` control playback/effects. Subsongs are menu=0, gameplay=1, victory=2, defeat=3. In one-player mode P2 is the AI and triggers defeat; all other winners trigger victory. `BoopFX` maps kitten/cat/line to SFX 1/2/3; cursor/eject use 0 (disabled). `PLY_AKG_PLAY` is pumped once/frame from `int_handler5` in `system.s`, gated on `_snd_music_active`.

**man/ modules** (each: `.h.s` header + `.s` impl):
- **game** (`sys_game_init`/`sys_game_update`) - State machine: `GAME_STATE_MENU=0`, `PLAYING=1`, `HELP=2`, `AI_SELECT=3`. Menu confirmed=1 (ONE PLAYER) → AI_SELECT (`man_menu_level_init`); confirmed=2 (TWO PLAYERS) → PLAYING; confirmed=3 → HELP. ESC on AI-select → menu. Also owns music-track switching on every state transition.
- **menu** (`man_menu_init`/`update`/`draw`) - 3-option menu (ONE/TWO PLAYERS/HELP); `man_menu_confirmed`=1/2/3. Walking gatito animation (4-frame, direction-aware hflip via `cpct_hflipSpriteM0_asm`, random walk/stop lengths).
- **menu_level** (`man_menu_level_init`/`update`) - AI difficulty picker (4 options, colored catty sprites). `man_menu_level_done`=1 confirmed/2 cancelled (ESC); on confirm writes chosen index (0–3) to `man_ai_level` (in `ai.h.s`).
- **match** (`man_match_init`/`update`/`draw_hud`) - Turn-based 6×6 board game. Manages `man_match_player1`/`player2` structs, `man_match_num_players`.
- **help** (`man_help_init`/`update`) - Help/rules screen; `man_help_done`=1 on exit.
- **ai** - see AI Module below.

### Code Conventions

- `.s` = assembly; `.h.s` = headers.
- Headers declare `.globl` symbols/macros; impls `.include` their own header.
- Each module: `.area _DATA` + `.area _CODE` (SDCC linker requires this).
- Self-modifying code: input key scanning, sprite colorize, draw_box — can't run from ROM.
- Comments mix English/Spanish.

### Key Macros (render.h.s)

```
ld_de_backbuffer          — load DE with back-buffer start address
ld_de_frontbuffer         — load DE with front-buffer start address
m_screenPtr_backbuffer X, Y  — compute screen ptr into DE for back buffer at (X bytes, Y px)
m_screenPtr_frontbuffer X, Y — same for front buffer
m_draw_blank_small_number BG — draw a blank 4×5 solid box with colour BG at current DE
```

CPC screen address formula: `base + 80*(Y/8) + 2048*(Y&7) + X`

### Asset Pipeline

PNG sprites in `assets/` auto-convert to C arrays via CPCtelera's `IMG2SP` macros (`cfg/image_conversion.mk`). Output: `src/assets/sprites/` (sprites), `src/assets/bg/` (backgrounds). Firmware palette: `PALETTE0` in that file.

256-byte transparency table at `0x100` (in `main.s`), used by all masked sprite drawing routines.

### Music Pipeline (`assets/sound/`) — manual, not part of `make`

The editable AT3 songs (`.aks`) and reusable instruments (`.aki`) live in `assets/sound/`. Music and effects are exported as `src/audio/BoopAkg*.asm` and `src/audio/BoopFX*.asm`. Run `assets/sound/generate_at3_audio.sh` with `AT3_HOME`, `RASM`, and `DISARK` set to regenerate the relocatable `src/audio/BoopAudioAT3.s`; see `assets/sound/AT3_AUDIO.md`.

### Interrupt System

6 handlers (`int_handler1`–`6`) rotate each interrupt for predictable per-frame timing. Handler 2 calls `cpct_scanKeyboard_if_asm` to keep keyboard buffer current.

### Match Board & Player Data

**Board** (`_match_board`) — 36-byte row-major array; cell values: `BOARD_EMPTY=0`, `BOARD_P1_CAT=1`, `BOARD_P1_KITTEN=2`, `BOARD_P2_CAT=3`, `BOARD_P2_KITTEN=4`

**Grid geometry** (`match.h.s`): first cell X=19 bytes, Y=36 px; pitch 7 bytes × 24 px; 6 cols × 6 rows. Cursor color `CURSOR_COLOR=0x3C` (pen 6, bright yellow). Blocked cursor `BLOCKED_CURSOR_COLOR=0xF0` (pen 3, red) — flashed when Space pressed but target piece type has 0 remaining.

**Player struct** (`match.h.s`): `score` 4B BCD (offset 0), `cats` 1B (4), `kittens` 1B (5); `sizeof_Player=6`.

**Initial reserve**: `MATCH_INITIAL_CATS=0`, `MATCH_INITIAL_KITTENS=8` per player.

### Keyboard Controls (during match)

| Key | Action |
|-----|--------|
| Cursor arrows | Move cursor on 6×6 grid |
| Space | Toggle `_cursor_piece` between `PIECE_KITTEN`(1)/`PIECE_CAT`(0); flashes red + blocks if target type has 0 in reserve |
| Enter/Return | Place selected piece at cursor (`_match_place_piece`) |
| Escape | "ABANDON MATCH? (Y/N)" dialog; Y → `_match_cancelled=1`, N/Esc resumes |

`_cursor_piece`: starts each turn as `PIECE_KITTEN` (or forced `PIECE_CAT` if active player has 0 kittens). Board value = `_match_state * 2 + _cursor_piece + 1`.

### Kitten Placement Rules

1. **Empty cell only** — kitten placeable only on `BOARD_EMPTY` cell.
2. **Boop push** — after placement, every kitten in the (up to 8) surrounding cells pushed one cell away from the new kitten, along the vector from new kitten → neighbor.
3. **Out-of-bounds ejection** — push off-grid → kitten removed from board, owner's kitten count incremented (returns to reserve).
4. **Piece interactions** — kittens boop only neighboring kittens; cats immune to kittens. A placed **cat** boops all neighboring pieces (kittens + cats). Ejected kittens → owner's kitten reserve; ejected cats → owner's cat reserve. Kitten boop: `_match_boop`; cat boop: `_match_boop_cat`. Owner: 1–2=P1, 3–4=P2. Type: odd=cat, even=kitten.
5. **Three-in-a-row conversion** — after placement+boop, scan for 3 consecutive same-player pieces (any cat/kitten mix) in a row/col. Kittens in the line removed, owner +1 cat per kitten; cats stay. Triggers on both kitten and cat placement. Impl: `_match_check_lines` + `_mrl_process_kitten` in `match.s`.
6. **Cat three-in-a-row win** — after each placement, scan for 3 consecutive same-color cats in a row/col → that player wins immediately (`BOARD_P1_CAT=1`→P1, `BOARD_P2_CAT=3`→P2). Impl: `_match_check_cat_lines` in `match.s`.
7. **No-pieces win** — after boop+line-check (before turn toggle), if placing player has 0 cats AND 0 kittens in reserve, match ends, opponent wins (accounts for pieces ejected back to reserve during boop). Inline in `_match_place_piece` at `_mpp_pe_chk`/`_mpp_pe_out`.

Both win conditions call `_match_declare_winner` (A=1 P1, A=2 P2): shows "PLAYER X WINS!" window, waits for keypress, sets `_match_cancelled=1` → menu.

### Boop Animation & Turn Announcement

**Boop animation** (`_match_boop_animate` in `match.s`) — replaces bare `_match_boop`/`_match_boop_cat` with 3-frame sequence:
1. Frame 0: piece placed, board drawn, 4-frame delay (pre-boop snapshot → `_boop_anim_before`)
2. Frame 1: boop executed, dest cells cleared into `_boop_transit_buf` (16B, up to 8 offset+value entries), board redrawn with sources gone/dests empty, 3-frame delay
3. Frame 2: destinations restored in board; caller redraws

`_boop_transit_cnt` = valid entry count in `_boop_transit_buf`.

**Turn announcement** (`_match_show_turn_message`) — tail call at end of `man_match_init` (P1 starts) and end of `_match_place_piece` (after each move, unless `_match_cancelled`). Shows "PLAYER X TURN", auto-dismiss 2s window (A=2 mode): orange bg P1 (pen 5), blue bg P2 (pen 2).

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

**Critical**: `m_msg_w_background BK` (in `common.h.s`) clobbers **AF and HL** (calls `cpct_px2byteM0_asm`, stores result in AF'). Always invoke first, then load E,D,B,C,A,HL. To preserve a value across the call, wrap with `push af`/`pop af`.

### Struct Definition Macros (common.h.s)

```asm
BeginStruct Foo          ; Foo_offset = 0
Field Foo, bar, 2        ; Foo_bar = 0, advances offset by 2
Field Foo, baz, 1        ; Foo_baz = 2
EndStruct Foo            ; sizeof_Foo = 3
```

### Match Cancellation Flow

`_match_cancelled` (byte, `match.h.s`) signals match → game loop:
- Set to `1` by `_match_declare_winner` after win/loss window dismissed.
- Polled each frame by `man_match_update`; when set, returns and `man_game_update` transitions to `GAME_STATE_MENU`.

### AI Module (`man/ai.s`)

Single-player opponent, always **Player 2** (blue cats). Active when `man_match_num_players==1` and it's P2's turn.

**Difficulty levels** (`man_ai_level` 0–3):

| Level | Name | Behaviour |
|-------|------|-----------|
| 0 | GATITO TIMIDO | Random, kitten-first, 50-frame think delay |
| 1 | GATO JUGUETON | Slight positional awareness |
| 2 | GATA ASTUTA | Balanced defense + offense, danger check active |
| 3 | MAESTRO FELINO | Full heuristic, 10-frame think delay, danger check active |

**Per-turn eval loop** (spread across frames, `AI_EVAL_CELLS_PER_FRAME=4`):
1. Phase 0 — scan every empty cell, score kitten/cat placements via `_ai_score_one_candidate`. 4 cells/frame; short-circuits on winning-move sentinel (score 255).
2. Phase 1 — post-eval delay (profile `delay_frames`, "think time").
3. Phase 2 — execute `_match_place_piece` with best move, then `man_ai_init` to reset.

**Scoring heuristic** (weights from active profile in `_ai_profiles`):
- **Defense** (`W_defense`): reduction in P1 adjacent cat-pairs after simulation.
- **Alignment** (`W_align`): increase in P2 adjacent piece-pairs.
- **Center** (`W_center`): 0–3 bonus from `_ai_center_table` (concentric squares).
- **Kitten lines** (`W_kitten`): count of P2 three-in-a-row windows created.
- **Random noise** (`rand_mask`): AND-masked random byte for variety.
- Equal-scoring candidates: 50% RNG tiebreak.
- **Danger check** (levels 2-3 only): after scoring, `_ai_has_p1_cat_win` scans the simulated board; if the move leaves P1 with an immediate 3-cats-in-a-row win, the candidate's score is forced to 0 regardless of heuristic value. Levels 0-1 skip this check on purpose (stay tactically blind).

**AI profile struct** (6B at `_ai_profiles + level*6`): `delay_frames, W_defense, W_align, W_center, W_kitten, rand_mask`.

**Simulation** — `_ai_score_one_candidate` saves board + both player structs (36+6+6B), calls `_ai_place_no_animate` (tail-calls `_match_boop`/`_match_boop_cat`), evaluates, restores. No animation/line-check during simulation.

**Integration points:**
- `man_ai_init` — called from `man_match_init` and after each AI move; resets phase, eval position, random fallback move.
- `man_ai_update` — called every frame from `man_match_update` when `num_players==1` and `_match_state==MATCH_STATE_P2`.
- AI level picker screen: `man/menu_level.s` (see man/ modules above), not part of `ai.s` — only writes `man_ai_level` on confirm.
- Move placement/eject SFX (`SFX_CURSOR/KITTEN/CAT`) triggered from `ai.s` via `sys_sound_play_sfx` alongside `_match_place_piece`, same as human moves in `match.s`.
