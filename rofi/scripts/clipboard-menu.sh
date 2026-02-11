#!/usr/bin/env bash

set -euo pipefail

theme="$HOME/.config/rofi/nord.rasi"

if ! command -v clipman >/dev/null 2>&1; then
  exit 0
fi

if ! command -v wl-copy >/dev/null 2>&1; then
  exit 0
fi

# Use clipman history picker with rofi; do nothing when cancelled.
if ! selected="$(clipman pick --tool=CUSTOM --tool-args="rofi -dmenu -i -p Clipboard -theme $theme" 2>/dev/null)"; then
  exit 0
fi

if [[ -z "$selected" ]]; then
  exit 0
fi

printf '%s' "$selected" | wl-copy
