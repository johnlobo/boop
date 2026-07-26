#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/../.." && pwd)"
at3_root="${AT3_HOME:-$HOME/Applications/ArkosTracker3}"
rasm_bin="${RASM:-$(command -v rasm || true)}"
disark_bin="${DISARK:-$(command -v disark || command -v Disark || true)}"

if [[ ! -x "$rasm_bin" ]]; then
  echo "RASM not found. Set RASM=/absolute/path/to/rasm." >&2
  exit 1
fi
if [[ ! -x "$disark_bin" ]]; then
  echo "Disark not found. Set DISARK=/absolute/path/to/disark." >&2
  exit 1
fi
if [[ ! -f "$at3_root/players/playerAkg/sources/z80/PlayerAkg.asm" ]]; then
  echo "Arkos Tracker 3 players not found. Set AT3_HOME=/path/to/ArkosTracker3." >&2
  exit 1
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/boop-at3.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

wrapper="$work_dir/BoopAudioRasm.asm"
cat > "$wrapper" <<EOF
org #0000

include "$project_root/src/audio/BoopAkg_playerconfig.asm"
include "$project_root/src/audio/BoopFX_playerconfig.asm"
PLY_AKG_MANAGE_SOUND_EFFECTS = 1

include "$at3_root/players/playerAkg/sources/z80/PlayerAkg.asm"
include "$project_root/src/audio/BoopAkg.asm"
include "$project_root/src/audio/BoopAkg_s0.asm"
include "$project_root/src/audio/BoopAkg_s1.asm"
include "$project_root/src/audio/BoopFX.asm"
EOF

"$rasm_bin" "$wrapper" -o "$work_dir/BoopAudio" -s -sl -sq
"$disark_bin" \
  "$work_dir/BoopAudio.bin" \
  "$project_root/src/audio/BoopAudioAT3.s" \
  --symbolFile "$work_dir/BoopAudio.sym" \
  --sourceProfile sdcc \
  --loadAddress 0

# AT3/Disark may emit CRLF and mnemonic padding; keep the generated source
# stable in Git on all hosts.
perl -pi -e 's/[ \t\r]+$//' "$project_root/src/audio/BoopAudioAT3.s"

echo "Generated src/audio/BoopAudioAT3.s"
