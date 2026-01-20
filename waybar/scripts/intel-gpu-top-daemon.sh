#!/usr/bin/env bash
# intel-gpu-top-daemon.sh - stream intel_gpu_top JSON into a cache file for Waybar

set -uo pipefail

INTERVAL_MS="${IGT_INTERVAL_MS:-1000}"
UID_SAFE="${SUDO_UID:-$UID}"
CACHE_JSON="/tmp/intel-gpu-top.${UID_SAFE}.json"
PIDFILE="/tmp/intel-gpu-top.${UID_SAFE}.pid"
LOG="/tmp/intel-gpu-top.${UID_SAFE}.log"

if [[ -f "$PIDFILE" ]]; then
  if pid=$(cat "$PIDFILE" 2>/dev/null) && kill -0 "$pid" 2>/dev/null; then
    exit 0
  fi
fi
echo "$$" > "$PIDFILE" 2>/dev/null || true

if ! command -v intel_gpu_top >/dev/null 2>&1; then
  printf '{"error":"intel_gpu_top missing"}\n' > "$CACHE_JSON"
  exit 1
fi

# CSV streams line-by-line; JSON only flushes on exit.
cmd=(intel_gpu_top -c -s "$INTERVAL_MS" -o -)
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  if sudo -n true 2>/dev/null; then
    cmd=(sudo -n "${cmd[@]}")
  fi
fi

"${cmd[@]}" 2>>"$LOG" | while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  if [[ -z "${RC6_IDX:-}" ]]; then
    # Header line; find RC6 % column index (1-based).
    RC6_IDX=0
    idx=0
    IFS=',' read -r -a cols <<< "$line"
    for col in "${cols[@]}"; do
      idx=$((idx + 1))
      if [[ "$col" == "RC6 %" ]]; then
        RC6_IDX=$idx
        break
      fi
    done
    continue
  fi
  IFS=',' read -r -a vals <<< "$line"
  if (( RC6_IDX > 0 && RC6_IDX <= ${#vals[@]} )); then
    rc6="${vals[$((RC6_IDX-1))]}"
    printf '{"rc6":{"value":%s,"unit":"%%"}}\n' "$rc6" > "${CACHE_JSON}.new"
    mv -f "${CACHE_JSON}.new" "$CACHE_JSON" 2>/dev/null || true
  fi
done
