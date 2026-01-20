#!/usr/bin/env bash

set -uo pipefail

# Get CPU model (removed "(R)", "(TM)", and clock speed)
model=$(awk -F ': ' '/model name/{print $2}' /proc/cpuinfo | head -n 1 | sed 's/@.*//; s/ *\((R)\|(TM)\)//g; s/^[ \t]*//; s/[ \t]*$//')

UID_SAFE="${SUDO_UID:-$UID}"
CACHE_SUMMARY="/tmp/turbostat-waybar.${UID_SAFE}.summary"
PIDFILE="/tmp/turbostat-waybar.${UID_SAFE}.pid"
DAEMON="$HOME/.config/waybar/scripts/turbostat-daemon.sh"

start_daemon() {
  [[ -x "$DAEMON" ]] || return 0
  nohup "$DAEMON" >/dev/null 2>&1 &
}

running=false
if [[ -f "$PIDFILE" ]]; then
  if pid=$(cat "$PIDFILE" 2>/dev/null) && kill -0 "$pid" 2>/dev/null; then
    running=true
  fi
fi
if ! $running; then
  start_daemon
fi

# Prefer turbostat Busy% if available, else fall back to vmstat
load=""
if [[ -f "$CACHE_SUMMARY" ]]; then
  load=$(awk -F= '/^busy=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo "")
fi
if [[ -z "$load" ]]; then
  load=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')
fi

load_int=$(awk -v v="$load" 'BEGIN{printf "%d", v+0.5}')

# Determine CPU state based on usage
if awk -v v="$load" 'BEGIN{exit (v>=80?0:1)}'; then
  state="Critical"
elif awk -v v="$load" 'BEGIN{exit (v>=60?0:1)}'; then
  state="High"
elif awk -v v="$load" 'BEGIN{exit (v>=25?0:1)}'; then
  state="Moderate"
else
  state="Low"
fi

# Set color based on CPU load
if awk -v v="$load" 'BEGIN{exit (v>=80?0:1)}'; then
  # If CPU usage is >= 80%, set color to #f38ba8
  text_output="<span color='#f38ba8'>󰀩 ${load_int}%</span>"
else
  # Default color
  text_output="󰻠 ${load_int}%"
fi

tooltip="${model}"
tooltip+="\nCPU Usage: ${state}"

# Module and tooltip
echo "{\"text\": \"$text_output\", \"tooltip\": \"$tooltip\"}"
