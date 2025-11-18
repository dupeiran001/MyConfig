#!/usr/bin/env bash
# power-draw.sh — Battery, CPU Package (sum across sockets), PSYS (if present)
# Fast: no sleep. Uses cached snapshot in /tmp to compute Δenergy/Δtime.

set -euo pipefail

# ---------- config ----------
BAT_DIR="/sys/class/power_supply/BAT0"
POWERCAP="/sys/class/powercap"
CACHE="/tmp/power-draw.${SUDO_UID:-$UID}.cache"
JSON_ICON_BATT=""
JSON_ICON_CHRG=""

# ---------- re-exec as root if needed (for /sys/class/powercap on some distros) ----------
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E bash "$0"
fi

# ---------- helpers ----------
now_ns() { date +%s%N; }

read_battery_w() {
  local uw=0
  if [[ -d "$BAT_DIR" ]]; then
    if [[ -f "$BAT_DIR/power_now" ]]; then
      uw=$(<"$BAT_DIR/power_now")
    elif [[ -f "$BAT_DIR/current_now" && -f "$BAT_DIR/voltage_now" ]]; then
      # µA * µV = pW; /1e6 => µW
      local iuw vuv
      iuw=$(<"$BAT_DIR/current_now")
      vuv=$(<"$BAT_DIR/voltage_now")
      uw=$(( (iuw * vuv) / 1000000 ))
    fi
  fi
  awk -v uw="$uw" 'BEGIN{printf "%.2f", (uw<0?-uw:uw)/1000000.0}'
}

collect_paths() {
  # Builds two lists: PKG_PATHS (top-level package domains), PSYS_PATHS (psys/platform as top-level or subdomain)
  PKG_PATHS=()
  PSYS_PATHS=()
  for dom in "$POWERCAP"/intel-rapl:*; do
    [[ -d "$dom" ]] || continue
    local dname=""
    [[ -f "$dom/name" ]] && dname=$(<"$dom/name")
    # top-level package domains (e.g., package-0, package-1)
    if [[ "$dname" == package* || "$dname" == "package" ]]; then
      PKG_PATHS+=("$dom")
    fi
    # **NEW**: top-level PSYS (your case: intel-rapl:1 with name "psys" or "platform")
    if [[ "$dname" == psys* || "$dname" == platform* || "$dname" == "platform" ]]; then
      PSYS_PATHS+=("$dom")
    fi
    # PSYS as subdomain (common on some machines)
    for sub in "$dom":*; do
      [[ -d "$sub" ]] || continue
      local sname=""
      [[ -f "$sub/name" ]] && sname=$(<"$sub/name")
      if [[ "$sname" == psys* || "$sname" == platform* || "$sname" == "platform" ]]; then
        PSYS_PATHS+=("$sub")
      fi
    done
  done
}

read_energy_and_max() {
  # args: path -> echo "energy_uj max_energy_uj"
  local p="$1" e m
  if [[ -f "$p/energy_uj" ]]; then
    e=$(<"$p/energy_uj")
  else
    e=0
  fi
  if [[ -f "$p/max_energy_range_uj" ]]; then
    m=$(<"$p/max_energy_range_uj")
  else
    m=4294967296
  fi
  echo "$e $m"
}

# ---------- read previous snapshot (if any) ----------
declare -A PREV_E PREV_M PREV_G
PREV_TS=0
if [[ -f "$CACHE" ]]; then
  # Format:
  # ts_ns
  # <group>\t<path>\t<energy_uj>\t<max_uj>
  IFS= read -r PREV_TS < "$CACHE" || PREV_TS=0
  while IFS=$'\t' read -r g path e m; do
    [[ -n "${path:-}" ]] || continue
    PREV_E["$path"]="$e"
    PREV_M["$path"]="$m"
    PREV_G["$path"]="$g"
  done < <(tail -n +2 "$CACHE" || true)
fi

# ---------- collect current snapshot ----------
collect_paths
TS=$(now_ns)

# Build current maps and compute deltas
declare -A CUR_E CUR_M CUR_G
pkg_uj=0
psys_uj=0

# helper to accumulate one path into a group
accumulate_path() {
  local group="$1" path="$2"
  local e m pe pm d
  read -r e m < <(read_energy_and_max "$path")
  CUR_E["$path"]="$e"
  CUR_M["$path"]="$m"
  CUR_G["$path"]="$group"

  # If there is a previous value and a valid previous timestamp, accumulate delta
  if [[ "$PREV_TS" -gt 0 && -n "${PREV_E[$path]:-}" ]]; then
    pe="${PREV_E[$path]}"; pm="${PREV_M[$path]}"
    # handle wraparound
    if (( e < pe )); then
      e=$(( e + pm ))
    fi
    d=$(( e - pe ))  # µJ
    if [[ "$group" == "pkg" ]]; then
      pkg_uj=$(( pkg_uj + d ))
    else
      psys_uj=$(( psys_uj + d ))
    fi
  fi
}

for p in "${PKG_PATHS[@]}"; do accumulate_path "pkg"  "$p"; done
for p in "${PSYS_PATHS[@]}"; do accumulate_path "psys" "$p"; done

# ---------- compute watts (if we have a previous timestamp) ----------
pkg_w="0.00"
psys_w="0.00"
if [[ "$PREV_TS" -gt 0 ]]; then
  # dt in seconds with 9 decimal places
  dt=$(awk -v a="$TS" -v b="$PREV_TS" 'BEGIN{printf "%.9f", (a-b)/1e9}')
  # µJ / s = µW → /1e6 = W
  pkg_w=$(awk -v de="$pkg_uj" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
  if ((${#PSYS_PATHS[@]})); then
    psys_w=$(awk -v de="$psys_uj" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
  fi
fi

# ---------- write current snapshot atomically for next run ----------
{
  echo "$TS"
  for p in "${!CUR_E[@]}"; do
    printf "%s\t%s\t%s\t%s\n" "${CUR_G[$p]}" "$p" "${CUR_E[$p]}" "${CUR_M[$p]}"
  done | LC_ALL=C sort
} > "${CACHE}.new"
mv -f "${CACHE}.new" "$CACHE"

# ---------- battery + JSON output ----------
battery_w=$(read_battery_w)
status="Unknown"; icon="$JSON_ICON_BATT"
if [[ -f "$BAT_DIR/status" ]]; then
  status=$(<"$BAT_DIR/status")
  [[ "$status" == "Charging" ]] && icon="$JSON_ICON_CHRG" || icon="$JSON_ICON_BATT"
fi

# On first run (no previous cache), pkg_w/psys_w will be 0.00 — that’s expected.
text="${icon} ${battery_w} W | CPU ${pkg_w} W | PSYS ${psys_w} W"
tooltip="Battery (${status}): ${battery_w} W\nCPU Package: ${pkg_w} W\nPSYS: ${psys_w} W"
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"

