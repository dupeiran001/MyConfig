#!/usr/bin/env bash
# power-draw.sh — Battery, CPU Package (sum across sockets), PSYS (if present)
# Fast: no sleep. Uses cached snapshot in /tmp to compute Δenergy/Δtime.

set -uo pipefail

# ---------- config ----------
BAT_DIR="/sys/class/power_supply/BAT0"
POWERCAP="/sys/class/powercap"
CACHE="/tmp/power-draw.${SUDO_UID:-$UID}.cache"
LOG="/tmp/power-draw-debug.${SUDO_UID:-$UID}.log"
LOG_ENABLED="${POWER_DRAW_LOG:-false}"
JSON_ICON_BATT=""
JSON_ICON_CHRG=""
JSON_ICON_GPU="󰾲"
GPU_VENDOR_NAMES=("0x10de:NVIDIA" "0x1002:AMD" "0x8086:Intel")
IGPU_USAGE_FILE=""
IGPU_POWER_PRESENT=false
IGPU_RC6_FILE=""
IGPU_RC6_CACHE="/tmp/igpu-rc6.${SUDO_UID:-$UID}.cache"

# ---------- debug logging ----------
log_debug() {
  [[ "${LOG_ENABLED}" == "false" ]] && return 0
  local ts
  ts=$(date -Iseconds 2>/dev/null || date)
  { printf "%s %s\n" "$ts" "$*"; } >>"$LOG" 2>/dev/null || true
}
trap 'log_debug "exit=$? last_cmd=${BASH_COMMAND:-}"' EXIT

# If earlier root runs left unwritable cache/log, fall back to user-owned paths
if [[ -e "$CACHE" && ! -w "$CACHE" ]]; then
  CACHE="/tmp/power-draw.${UID:-$(id -u)}.user.cache"
fi
if [[ -e "$LOG" && ! -w "$LOG" ]]; then
  LOG="/tmp/power-draw-debug.${UID:-$(id -u)}.user.log"
fi
if [[ -e "$IGPU_RC6_CACHE" && ! -w "$IGPU_RC6_CACHE" ]]; then
  IGPU_RC6_CACHE="/tmp/igpu-rc6.${UID:-$(id -u)}.user.cache"
fi

# ---------- re-exec as root if needed (for /sys/class/powercap on some distros) ----------
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  need_sudo=false
  found_rapl=0
  readable_rapl=0
  for dom in "$POWERCAP"/intel-rapl:* "$POWERCAP"/intel-rapl-mmio:*; do
    [[ -d "$dom" ]] || continue
    found_rapl=1
    if [[ -r "$dom/energy_uj" ]]; then
      readable_rapl=1
      break
    fi
  done
  if (( found_rapl && ! readable_rapl )); then
    need_sudo=true
  fi

  tty_str=$( (tty 2>/dev/null || echo none) | tr -d '\n')
  log_debug "euid=${EUID:-$(id -u)} uid=${UID:-$(id -u)} sudo_uid=${SUDO_UID:-} tty=${tty_str} need_sudo=${need_sudo}"

  if $need_sudo; then
    if sudo -n -E bash "$0" 2>/dev/null; then
      log_debug "sudo path succeeded"
      exit 0
    else
      rc=$?
      log_debug "sudo path failed rc=${rc}; continuing without sudo"
    fi
  fi
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

find_gpu_power_file() {
  GPU_POWER_FILE=""
  GPU_VENDOR_LABEL=""
  GPU_BUS_ID=""
  GPU_READ_CMD=""
  # Pass 1: check PCI devices directly
  for dev in /sys/bus/pci/devices/*; do
    [[ -f "$dev/vendor" && -f "$dev/class" ]] || continue
    local vendor class
    vendor=$(<"$dev/vendor")
    class=$(<"$dev/class")
    # GPU/3D classes start with 0x03
    [[ "$class" == 0x03* ]] || continue
    local vname=""
    for entry in "${GPU_VENDOR_NAMES[@]}"; do
      if [[ "$entry" == "${vendor}:"* ]]; then
        vname=${entry#*:}
        break
      fi
    done
    [[ -n "$vname" ]] || continue
    GPU_VENDOR_LABEL="$vname"
    GPU_BUS_ID="${dev##*/}"
    for hwmon in "$dev"/hwmon/hwmon*; do
      [[ -d "$hwmon" ]] || continue
      for f in power1_average power1_input; do
        if [[ -r "$hwmon/$f" ]]; then
          GPU_POWER_FILE="$hwmon/$f"
          log_debug "gpu_detected vendor=${vendor} label=${GPU_VENDOR_LABEL} class=${class} path=${GPU_POWER_FILE}"
          return 0
        fi
      done
    done
    # NVIDIA often lacks hwmon; fall back to nvidia-smi if present
    if [[ "$vendor" == "0x10de" ]] && command -v nvidia-smi >/dev/null 2>&1; then
      GPU_READ_CMD=(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits -i 0)
      log_debug "gpu_detected vendor=${vendor} label=${GPU_VENDOR_LABEL} class=${class} using=nvidia-smi bus=${GPU_BUS_ID}"
      return 0
    fi
  done
  # Pass 2: some drivers expose hwmon without the direct pci->hwmon path; check all hwmon entries
  for hw in /sys/class/hwmon/hwmon*; do
    [[ -d "$hw" ]] || continue
    local devpath
    devpath=$(readlink -f "$hw/device" 2>/dev/null || true)
    [[ -n "$devpath" && -f "$devpath/vendor" && -f "$devpath/class" ]] || continue
    local vendor class vname=""
    vendor=$(<"$devpath/vendor")
    class=$(<"$devpath/class")
    [[ "$class" == 0x03* ]] || continue
    for entry in "${GPU_VENDOR_NAMES[@]}"; do
      if [[ "$entry" == "${vendor}:"* ]]; then
        vname=${entry#*:}
        break
      fi
    done
    [[ -n "$vname" ]] || continue
    for f in "$hw"/power1_average "$hw"/power1_input; do
      if [[ -r "$f" ]]; then
        GPU_POWER_FILE="$f"
        GPU_VENDOR_LABEL="$vname"
        GPU_BUS_ID="${devpath##*/}"
        log_debug "gpu_detected_hwmon vendor=${vendor} label=${GPU_VENDOR_LABEL} class=${class} path=${GPU_POWER_FILE}"
        return 0
      fi
    done
  done
  # Fall back to NVIDIA userspace query (NVML) if available and a GPU is present
  if command -v nvidia-smi >/dev/null 2>&1; then
    if nvidia-smi --list-gpus >/dev/null 2>&1; then
      GPU_READ_CMD=(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits -i 0)
      GPU_VENDOR_LABEL="NVIDIA"
      log_debug "gpu_fallback_nvml cmd=${GPU_READ_CMD[*]}"
      return 0
    fi
  fi
  log_debug "gpu_not_found"
}

read_gpu_w() {
  if [[ -n "${GPU_POWER_FILE:-}" ]]; then
    local uw
    if uw=$(<"$GPU_POWER_FILE"); then
      awk -v uw="$uw" 'BEGIN{printf "%.2f", uw/1000000.0}'
      return 0
    fi
    log_debug "gpu_read_failed path=${GPU_POWER_FILE}"
  elif [[ -n "${GPU_READ_CMD[*]:-}" ]]; then
    local val
    if val=$("${GPU_READ_CMD[@]}" 2>/dev/null | head -n1); then
      # nvidia-smi returns watts already
      val=${val%% *}
      awk -v w="$val" 'BEGIN{if(w!="") printf "%.2f", w; else print "0.00"}'
      return 0
    fi
    log_debug "gpu_read_failed cmd=${GPU_READ_CMD[*]}"
  fi
  echo "0.00"
  return 1
}

find_igpu_usage_file() {
  IGPU_USAGE_FILE=""
  # Intel iGPU usage is often exposed via gpu_busy_percent or gt_busy_percent.
  for dev in /sys/class/drm/card*/device; do
    [[ -d "$dev" && -f "$dev/vendor" && -f "$dev/class" ]] || continue
    local vendor class
    vendor=$(<"$dev/vendor")
    class=$(<"$dev/class")
    [[ "$vendor" == "0x8086" && "$class" == 0x03* ]] || continue
    for f in gpu_busy_percent gt_busy_percent; do
      if [[ -r "$dev/$f" ]]; then
        IGPU_USAGE_FILE="$dev/$f"
        log_debug "igpu_usage_detected vendor=${vendor} class=${class} path=${IGPU_USAGE_FILE}"
        return 0
      fi
    done
  done
  log_debug "igpu_usage_not_found"
}

read_igpu_usage() {
  local val
  if val=$(<"$IGPU_USAGE_FILE"); then
    awk -v v="$val" 'BEGIN{if(v=="") print "0"; else printf "%d", v+0}'
    return 0
  fi
  log_debug "igpu_usage_read_failed path=${IGPU_USAGE_FILE}"
  echo "0"
  return 1
}

find_igpu_rc6_file() {
  IGPU_RC6_FILE=""
  for card in /sys/class/drm/card*; do
    [[ -d "$card" ]] || continue
    [[ "$card" == *"-"* ]] && continue
    if [[ -f "$card/device/vendor" ]]; then
      local vendor
      vendor=$(<"$card/device/vendor")
      [[ "$vendor" == "0x8086" ]] || continue
      if [[ -r "$card/gt/gt0/rc6_residency_ms" ]]; then
        IGPU_RC6_FILE="$card/gt/gt0/rc6_residency_ms"
        log_debug "igpu_rc6_detected vendor=${vendor} path=${IGPU_RC6_FILE}"
        return 0
      fi
    fi
  done
  log_debug "igpu_rc6_not_found"
}

read_igpu_usage_rc6() {
  # Usage ~= 100 - (delta_rc6 / delta_time * 100)
  local now rc6 prev_ts prev_rc6 dt_ms drc6 busy
  now=$(now_ns)
  if ! rc6=$(<"$IGPU_RC6_FILE"); then
    log_debug "igpu_rc6_read_failed path=${IGPU_RC6_FILE}"
    echo "0"
    return 1
  fi
  prev_ts=0
  prev_rc6=0
  if [[ -f "$IGPU_RC6_CACHE" ]]; then
    IFS=$'\t' read -r prev_ts prev_rc6 < "$IGPU_RC6_CACHE" || true
  fi
  printf "%s\t%s\n" "$now" "$rc6" > "${IGPU_RC6_CACHE}.new" || true
  mv -f "${IGPU_RC6_CACHE}.new" "$IGPU_RC6_CACHE" 2>/dev/null || true
  if [[ "$prev_ts" -gt 0 ]]; then
    dt_ms=$(awk -v a="$now" -v b="$prev_ts" 'BEGIN{printf "%.3f", (a-b)/1e6}')
    drc6=$(( rc6 - prev_rc6 ))
    busy=$(awk -v drc6="$drc6" -v dt="$dt_ms" 'BEGIN{if(dt>0){v=100-(drc6/dt*100); if(v<0)v=0; if(v>100)v=100; printf "%d", v+0}else print "0"}')
    echo "$busy"
    return 0
  fi
  echo "0"
  return 0
}

collect_paths() {
  # Builds two lists: PKG_PATHS (top-level package domains), PSYS_PATHS (psys/platform as top-level or subdomain)
  PKG_PATHS=()
  PSYS_PATHS=()
  IGPU_PATHS=()
  for dom in "$POWERCAP"/intel-rapl:* "$POWERCAP"/intel-rapl-mmio:*; do
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
      # iGPU power domain (name often "gpu" or "gfx")
      if [[ "$sname" == gpu* || "$sname" == gfx* ]]; then
        IGPU_PATHS+=("$sub")
      fi
    done
  done
}

read_energy_and_max() {
  # args: path -> echo "energy_uj max_energy_uj"
  local p="$1" e=0 m=4294967296
  local energy_status="absent" max_status="absent" rc=0

  if [[ -f "$p/energy_uj" ]]; then
    energy_status="present"
    if [[ -r "$p/energy_uj" ]]; then
      if e=$(<"$p/energy_uj"); then
        energy_status="ok"
      else
        energy_status="read_error"
        rc=1
      fi
    else
      energy_status="perm_denied"
      rc=1
    fi
  fi

  if [[ -f "$p/max_energy_range_uj" ]]; then
    max_status="present"
    if [[ -r "$p/max_energy_range_uj" ]]; then
      if m=$(<"$p/max_energy_range_uj"); then
        max_status="ok"
      else
        max_status="read_error"
        rc=1
      fi
    else
      max_status="perm_denied"
      rc=1
    fi
  fi

  log_debug "read_energy path=${p} energy=${e} energy_status=${energy_status} max=${m} max_status=${max_status} rc=${rc}"
  echo "$e $m"
  return 0
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
cache_state="absent"
[[ -f "$CACHE" ]] && cache_state="present"
  log_debug "run ts=$TS prev_ts=${PREV_TS:-0} cache=${cache_state} pkg_paths=${#PKG_PATHS[@]} psys_paths=${#PSYS_PATHS[@]} uid=${UID:-$(id -u)} euid=${EUID:-$(id -u)} sudo_uid=${SUDO_UID:-}"

# Build current maps and compute deltas
declare -A CUR_E CUR_M CUR_G
pkg_uj=0
psys_uj=0
igpu_uj=0
pkg_present=false
psys_present=false
igpu_power_present=false

# helper to accumulate one path into a group
accumulate_path() {
  local group="$1" path="$2"
  local e m pe pm d
  if [[ ! -r "$path/energy_uj" ]]; then
    log_debug "skip_unreadable path=${path}/energy_uj"
    return 0
  fi
  [[ "$group" == "pkg" ]] && pkg_present=true
  [[ "$group" == "psys" ]] && psys_present=true
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
    elif [[ "$group" == "psys" ]]; then
      psys_uj=$(( psys_uj + d ))
    else
      igpu_uj=$(( igpu_uj + d ))
    fi
  fi
}

for p in "${PKG_PATHS[@]}"; do accumulate_path "pkg"  "$p"; done
for p in "${PSYS_PATHS[@]}"; do accumulate_path "psys" "$p"; done
for p in "${IGPU_PATHS[@]}"; do accumulate_path "igpu" "$p"; done

# ---------- compute watts (if we have a previous timestamp) ----------
pkg_w="0.00"
psys_w="0.00"
igpu_w="0.00"
dt="n/a"
if [[ "$PREV_TS" -gt 0 ]]; then
  # dt in seconds with 9 decimal places
  dt=$(awk -v a="$TS" -v b="$PREV_TS" 'BEGIN{printf "%.9f", (a-b)/1e9}')
  # µJ / s = µW → /1e6 = W
  pkg_w=$(awk -v de="$pkg_uj" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
  if ((${#PSYS_PATHS[@]})); then
    psys_w=$(awk -v de="$psys_uj" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
  fi
  if ((${#IGPU_PATHS[@]})); then
    igpu_w=$(awk -v de="$igpu_uj" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
  fi
fi

# ---------- dGPU power (if present) ----------
find_gpu_power_file
gpu_present=false
gpu_w="0.00"
if [[ -n "${GPU_POWER_FILE:-}" || -n "${GPU_READ_CMD[*]:-}" ]]; then
  gpu_present=true
  gpu_w=$(read_gpu_w)
fi

# ---------- iGPU usage (Intel) if no dGPU power ----------
igpu_present=false
igpu_usage="0"
if ! $gpu_present; then
  find_igpu_usage_file
  if [[ -n "$IGPU_USAGE_FILE" ]]; then
    igpu_present=true
    igpu_usage=$(read_igpu_usage)
  else
    find_igpu_rc6_file
    if [[ -n "$IGPU_RC6_FILE" ]]; then
      igpu_present=true
      igpu_usage=$(read_igpu_usage_rc6)
    fi
  fi
fi
IGPU_POWER_PRESENT=false
if ((${#IGPU_PATHS[@]})); then
  igpu_power_present=true
fi

# ---------- write current snapshot atomically for next run ----------
{
  echo "$TS"
  for p in "${!CUR_E[@]}"; do
    printf "%s\t%s\t%s\t%s\n" "${CUR_G[$p]}" "$p" "${CUR_E[$p]}" "${CUR_M[$p]}"
  done | LC_ALL=C sort
} > "${CACHE}.new" || log_debug "cache_write_failed"
mv -f "${CACHE}.new" "$CACHE" 2>/dev/null || log_debug "cache_move_failed"

# ---------- battery + JSON output ----------
has_battery=false
[[ -d "$BAT_DIR" ]] && has_battery=true

battery_w="0.00"
status="Unknown"; icon="$JSON_ICON_BATT"
if $has_battery; then
  battery_w=$(read_battery_w)
  if [[ -f "$BAT_DIR/status" ]]; then
    status=$(<"$BAT_DIR/status")
    [[ "$status" == "Charging" ]] && icon="$JSON_ICON_CHRG" || icon="$JSON_ICON_BATT"
  fi
fi

psys_effective_w="$psys_w"
psys_label="PSYS"
if $has_battery && $gpu_present && $psys_present; then
  if awk -v v="$psys_w" 'BEGIN{exit (v==0?0:1)}'; then
    psys_effective_w="$gpu_w"
    psys_label="GPU"
  fi
fi

# Decide what to show in the first segment
text_prefix=""
tooltip_prefix=""
if $has_battery; then
  text_prefix="${icon} ${battery_w} W"
  tooltip_prefix="Battery (${status}): ${battery_w} W"
elif $gpu_present; then
  text_prefix="${JSON_ICON_GPU} ${GPU_VENDOR_LABEL:-GPU} ${gpu_w} W"
  tooltip_prefix="${GPU_VENDOR_LABEL:-GPU}: ${gpu_w} W"
elif $igpu_power_present; then
  text_prefix="iGPU ${igpu_w} W"
  tooltip_prefix="iGPU Power: ${igpu_w} W"
elif $igpu_present; then
  text_prefix="iGPU ${igpu_usage}%"
  tooltip_prefix="iGPU Usage: ${igpu_usage}%"
else
  text_prefix="Battery n/a"
  tooltip_prefix="Battery: not present"
fi

pkg_display="$pkg_w"
[[ "$pkg_display" == "0.00" && $pkg_present == false ]] && pkg_display="N/A"
psys_display="$psys_effective_w"
[[ $psys_present == false ]] && psys_display="N/A"

# On first run (no previous cache), pkg_w/psys_w will be 0.00 — that’s expected.
text="${text_prefix} | CPU ${pkg_display} W | ${psys_label} ${psys_display} W"
tooltip="${tooltip_prefix}\nCPU Package: ${pkg_display} W\n${psys_label}: ${psys_display} W"
log_debug "metrics dt=${dt} pkg_uj=${pkg_uj} psys_uj=${psys_uj} pkg_w=${pkg_w} pkg_present=${pkg_present} psys_w=${psys_w} psys_present=${psys_present} psys_effective_w=${psys_effective_w} battery_w=${battery_w} battery_status=${status} gpu_present=${gpu_present} gpu_w=${gpu_w} gpu_path=${GPU_POWER_FILE:-none}"
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
