# Arkos Tracker 3 audio

The game uses the AKG player from Arkos Tracker 3 while retaining the existing
CPCtelera version and the public `sys_sound_*` API.

## Song layout

- Subsong 0: menus
- Subsong 1: gameplay

The exported RASM sources live in `src/audio/BoopAkg*.asm`. Export the `.aks`
again from AT3 when the song changes, preserving those names and the split
subsong files.

## Generate the SDCC source

Install RASM and Disark, then run:

```sh
AT3_HOME=/path/to/ArkosTracker3 \
RASM=/path/to/rasm \
DISARK=/path/to/disark \
assets/sound/generate_at3_audio.sh
```

This assembles the AT3 player and data with RASM and converts the result into
the relocatable `src/audio/BoopAudioAT3.s` understood by CPCtelera's SDASZ80.

The `BoopFX.asm` collection provides three effects. Its linear output IDs are
mapped in `src/common.h.s`: small cat is 1, fat cat is 2, and merging three cats
is 3. Cursor and eject currently use ID 0, which deliberately produces no sound.
Add a third subsong and update `sys_sound_play_sfx` when a victory jingle is
available.
