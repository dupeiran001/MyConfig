#!/usr/bin/env bash
# turbostat-daemon.sh - stream turbostat summary into a cache file for Waybar

set -uo pipefail

INTERVAL="${TURBOSTAT_INTERVAL:-2}"
UID_SAFE="${SUDO_UID:-$UID}"
CACHE_JSON="/tmp/turbostat-waybar.${UID_SAFE}.json"
CACHE_RAW="/tmp/turbostat-waybar.${UID_SAFE}.raw"
CACHE_SUMMARY="/tmp/turbostat-waybar.${UID_SAFE}.summary"
PIDFILE="/tmp/turbostat-waybar.${UID_SAFE}.pid"
LOG="/tmp/turbostat-waybar.${UID_SAFE}.log"

if [[ -f "$PIDFILE" ]]; then
  if pid=$(cat "$PIDFILE" 2>/dev/null) && kill -0 "$pid" 2>/dev/null; then
    exit 0
  fi
fi
echo "$$" > "$PIDFILE" 2>/dev/null || true

if ! command -v turbostat >/dev/null 2>&1; then
  printf '{"text":"turbostat missing","tooltip":"Install turbostat"}\n' > "$CACHE_JSON"
  exit 1
fi

ts_cmd=(turbostat --quiet --show CPU,Busy%,Bzy_MHz,PkgWatt,CorWatt,GFXWatt,RAMWatt --interval "$INTERVAL")
if [[ "${EUID:-$(id -u)}" -ne 0 && ! -r /dev/cpu/0/msr ]]; then
  if sudo -n true 2>/dev/null; then
    ts_cmd=(sudo -n "${ts_cmd[@]}")
  else
    printf '{"text":"turbostat needs sudo","tooltip":"Allow sudo or setcap for turbostat"}\n' > "$CACHE_JSON"
    exit 1
  fi
fi

cpu_total=0
for d in /sys/devices/system/cpu/cpu[0-9]*; do
  [[ -d "$d" ]] || continue
  cpu_total=$((cpu_total + 1))
done
(( cpu_total > 0 )) || cpu_total=1

declare -A cpu_busy cpu_bzy cpu_pkg cpu_cor cpu_gfx cpu_ram cpu_seen_list
cpu_seen=0
pkg_first=""
cor_first=""
gfx_first=""
ram_first=""

"${ts_cmd[@]}" 2>>"$LOG" | while read -r cpu busy bzy pkg cor gfx ram _rest; do
  [[ "$cpu" == "CPU" ]] && continue
  [[ "$cpu" =~ ^[0-9]+$ ]] || continue
  cpu_busy["$cpu"]="$busy"
  cpu_bzy["$cpu"]="$bzy"
  cpu_pkg["$cpu"]="$pkg"
  cpu_cor["$cpu"]="$cor"
  cpu_gfx["$cpu"]="$gfx"
  cpu_ram["$cpu"]="$ram"
  if [[ -z "$pkg_first" ]]; then
    pkg_first="$pkg"
    cor_first="$cor"
    gfx_first="$gfx"
    ram_first="$ram"
  fi
  if [[ -z "${cpu_seen_list[$cpu]:-}" ]]; then
    cpu_seen_list["$cpu"]=1
    cpu_seen=$((cpu_seen + 1))
  fi

  if (( cpu_seen >= cpu_total )); then
    ts=$(date +%s 2>/dev/null || echo 0)
    tmp_raw="${CACHE_RAW}.new"
    tmp_json="${CACHE_JSON}.new"
    {
      for k in "${!cpu_bzy[@]}"; do
        printf "%s %s %s\n" "$k" "${cpu_busy[$k]:-0}" "${cpu_bzy[$k]:-0}"
      done
    } | LC_ALL=C sort -n > "$tmp_raw"
    mv -f "$tmp_raw" "$CACHE_RAW" 2>/dev/null || true

    # Summary file with averaged Busy%/Bzy_MHz and first-seen power numbers
    tmp_sum="${CACHE_SUMMARY}.new"
    awk -v pkg="$pkg_first" -v cor="$cor_first" -v gfx="$gfx_first" -v ram="$ram_first" '
      {sum_busy+=$2; sum_bzy+=$3; n++}
      END{
        if(n>0){
          printf "busy=%.2f\nbzy=%.0f\npkg=%s\ncor=%s\ngfx=%s\nram=%s\n", sum_busy/n, sum_bzy/n, pkg, cor, gfx, ram
        }
      }' "$CACHE_RAW" > "$tmp_sum"
    mv -f "$tmp_sum" "$CACHE_SUMMARY" 2>/dev/null || true

    # Basic summary JSON for optional use
    summary_busy=$(awk -F= '/^busy=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    summary_bzy=$(awk -F= '/^bzy=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    summary_pkg=$(awk -F= '/^pkg=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    summary_cor=$(awk -F= '/^cor=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    summary_gfx=$(awk -F= '/^gfx=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    summary_ram=$(awk -F= '/^ram=/{print $2}' "$CACHE_SUMMARY" 2>/dev/null || echo 0)
    printf '{"text":"CPU %s%% %s MHz | %s W","tooltip":"Busy: %s%%\\nBzy_MHz: %s\\nPkgWatt: %s W\\nCorWatt: %s W\\nGFXWatt: %s W\\nRAMWatt: %s W\\nUpdated: %s"}\n' \
      "$summary_busy" "$summary_bzy" "$summary_pkg" \
      "$summary_busy" "$summary_bzy" "$summary_pkg" "$summary_cor" "$summary_gfx" "$summary_ram" "$ts" > "$tmp_json"
    mv -f "$tmp_json" "$CACHE_JSON" 2>/dev/null || true

    cpu_busy=()
    cpu_bzy=()
    cpu_pkg=()
    cpu_cor=()
    cpu_gfx=()
    cpu_ram=()
    cpu_seen_list=()
    cpu_seen=0
    pkg_first=""
    cor_first=""
    gfx_first=""
    ram_first=""
  fi
done
