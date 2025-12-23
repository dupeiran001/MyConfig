#!/usr/bin/env bash

# Event-driven Caps Lock watcher for Waybar.
# Triggers a Waybar custom module refresh via RTMIN+10.

set -euo pipefail

led_path=""

if ls /sys/class/leds/*::capslock/brightness >/dev/null 2>&1; then
  led_path=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -n1)
elif ls /sys/class/leds/*capslock*/brightness >/dev/null 2>&1; then
  led_path=$(ls /sys/class/leds/*capslock*/brightness 2>/dev/null | head -n1)
fi

if [[ -z "${led_path}" ]]; then
  exit 0
fi

# Ensure initial state is shown
pkill -RTMIN+10 waybar 2>/dev/null || true

if command -v inotifywait >/dev/null 2>&1; then
  # Event-driven using inotify
  inotifywait -m -q -e modify "${led_path}" | while read -r _; do
    pkill -RTMIN+10 waybar 2>/dev/null || true
  done
else
  # Fallback: light polling only on value change
  last=""
  while true; do
    value=$(cat "${led_path}" 2>/dev/null || echo "")
    if [[ "${value}" != "${last}" ]]; then
      last="${value}"
      pkill -RTMIN+10 waybar 2>/dev/null || true
    fi
    sleep 0.2
  done
fi

