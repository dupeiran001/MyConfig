#!/usr/bin/env bash

# Simple Caps Lock indicator for Waybar custom module.
# Outputs just the icon when Caps Lock is ON, and nothing when OFF.

set -euo pipefail

led_path=""

# Prefer standard input-LED naming
if ls /sys/class/leds/*::capslock/brightness >/dev/null 2>&1; then
  led_path=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -n1)
elif ls /sys/class/leds/*capslock*/brightness >/dev/null 2>&1; then
  led_path=$(ls /sys/class/leds/*capslock*/brightness 2>/dev/null | head -n1)
fi

if [[ -z "${led_path}" ]]; then
  # No detectable capslock LED; show nothing
  exit 0
fi

value=$(cat "${led_path}" 2>/dev/null || echo "0")

if [[ "${value}" == "1" ]]; then
  # Caps Lock ON
  printf '󰪛\n'
else
  # Caps Lock OFF
  printf '\n'
fi
