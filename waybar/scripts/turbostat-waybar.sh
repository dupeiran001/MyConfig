#!/usr/bin/env bash
# turbostat-waybar.sh - ensure daemon running and emit last cached JSON

set -uo pipefail

UID_SAFE="${SUDO_UID:-$UID}"
CACHE="/tmp/turbostat-waybar.${UID_SAFE}.json"
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

if [[ -f "$CACHE" ]]; then
  cat "$CACHE"
  exit 0
fi

printf '{"text":"CPU …","tooltip":"Waiting for turbostat"}\n'
