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
  if [[ -z "${HAVE_HEADER:-}" ]]; then
    # Header line; find column indices (1-based).
    HAVE_HEADER=1
    RC6_IDX=0
    RENDER_IDX=0
    BUSY_IDX=0
    RCS_IDX=0
    BCS_IDX=0
    VCS_IDX=0
    VECS_IDX=0
    idx=0
    IFS=',' read -r -a cols <<< "$line"
    for col in "${cols[@]}"; do
      idx=$((idx + 1))
      col="${col#"${col%%[![:space:]]*}"}"
      col="${col%"${col##*[![:space:]]}"}"
      lcol="${col,,}"
      case "$lcol" in
        "rc6 %") RC6_IDX=$idx ;;
        "rcs %"|"rcs%") RCS_IDX=$idx ;;
        "bcs %"|"bcs%") BCS_IDX=$idx ;;
        "vcs %"|"vcs%") VCS_IDX=$idx ;;
        "vecs %"|"vecs%") VECS_IDX=$idx ;;
      esac
      if [[ $RENDER_IDX -eq 0 && "$lcol" == *"render"* && "$lcol" == *"%"* ]]; then
        RENDER_IDX=$idx
      fi
      if [[ $BUSY_IDX -eq 0 && ( "$lcol" == *"busy"* || "$lcol" == *"util"* ) && "$lcol" == *"%"* ]]; then
        BUSY_IDX=$idx
      fi
    done
    continue
  fi

  IFS=',' read -r -a vals <<< "$line"
  rc6=""
  render=""
  busy=""
  rcs=""
  bcs=""
  vcs=""
  vecs=""
  if (( RC6_IDX > 0 && RC6_IDX <= ${#vals[@]} )); then
    rc6="${vals[$((RC6_IDX-1))]}"
  fi
  if (( RENDER_IDX > 0 && RENDER_IDX <= ${#vals[@]} )); then
    render="${vals[$((RENDER_IDX-1))]}"
  fi
  if (( BUSY_IDX > 0 && BUSY_IDX <= ${#vals[@]} )); then
    busy="${vals[$((BUSY_IDX-1))]}"
  fi
  if (( RCS_IDX > 0 && RCS_IDX <= ${#vals[@]} )); then
    rcs="${vals[$((RCS_IDX-1))]}"
  fi
  if (( BCS_IDX > 0 && BCS_IDX <= ${#vals[@]} )); then
    bcs="${vals[$((BCS_IDX-1))]}"
  fi
  if (( VCS_IDX > 0 && VCS_IDX <= ${#vals[@]} )); then
    vcs="${vals[$((VCS_IDX-1))]}"
  fi
  if (( VECS_IDX > 0 && VECS_IDX <= ${#vals[@]} )); then
    vecs="${vals[$((VECS_IDX-1))]}"
  fi

  if [[ -z "$render" && -n "$rcs" ]]; then
    render="$rcs"
  fi
  if [[ -z "$busy" && -n "$rcs" ]]; then
    busy="$rcs"
  fi

  if [[ -n "$rc6" || -n "$render" || -n "$busy" || -n "$rcs" || -n "$bcs" || -n "$vcs" || -n "$vecs" ]]; then
    json="{"
    sep=""
    if [[ -n "$render" ]]; then
      json="${json}${sep}\"render\":{\"value\":${render},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$busy" ]]; then
      json="${json}${sep}\"busy\":{\"value\":${busy},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$rc6" ]]; then
      json="${json}${sep}\"rc6\":{\"value\":${rc6},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$rcs" ]]; then
      json="${json}${sep}\"rcs\":{\"value\":${rcs},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$bcs" ]]; then
      json="${json}${sep}\"bcs\":{\"value\":${bcs},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$vcs" ]]; then
      json="${json}${sep}\"vcs\":{\"value\":${vcs},\"unit\":\"%\"}"
      sep=","
    fi
    if [[ -n "$vecs" ]]; then
      json="${json}${sep}\"vecs\":{\"value\":${vecs},\"unit\":\"%\"}"
    fi
    json="${json}}"
    printf '%s\n' "$json" > "${CACHE_JSON}.new"
    mv -f "${CACHE_JSON}.new" "$CACHE_JSON" 2>/dev/null || true
  fi
done
