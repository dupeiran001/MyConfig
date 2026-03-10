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
TSTAT_SUMMARY="/tmp/turbostat-waybar.${SUDO_UID:-$UID}.summary"
JSON_ICON_BATT=""
JSON_ICON_CHRG=""
JSON_ICON_GPU="󰾲"
GPU_VENDOR_NAMES=("0x10de:NVIDIA" "0x1002:AMD" "0x8086:Intel")

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
  GPU_ENERGY_FILE=""
  GPU_IS_DGPU="false"
  GPU_VENDOR_LABEL=""
  GPU_BUS_ID=""
  GPU_READ_CMD=()

  gpu_hwmons_for_device() {
    local dev="$1" hw devpath
    for hw in "$dev"/hwmon/hwmon*; do
      [[ -d "$hw" ]] || continue
      echo "$hw"
    done
    # Some drivers expose sensors only via /sys/class/hwmon symlinks.
    for hw in /sys/class/hwmon/hwmon*; do
      [[ -d "$hw" ]] || continue
      devpath=$(readlink -f "$hw/device" 2>/dev/null || true)
      [[ "$devpath" == "$dev" ]] || continue
      echo "$hw"
    done
  }

  gpu_power_file_for_device() {
    local dev="$1" hw f
    while IFS= read -r hw; do
      for f in "$hw"/power*_average "$hw"/power*_input; do
        if [[ -r "$f" ]]; then
          echo "$f"
          return 0
        fi
      done
    done < <(gpu_hwmons_for_device "$dev")
    return 1
  }

  gpu_energy_file_for_device() {
    local dev="$1" hw f base label label_lc best_any=""
    while IFS= read -r hw; do
      for f in "$hw"/energy*_input; do
        if [[ -r "$f" ]]; then
          base="${f%_input}"
          label=""
          [[ -r "${base}_label" ]] && label=$(<"${base}_label")
          label_lc="${label,,}"
          # Prefer board/package rails when labels are provided.
          case "$label_lc" in
            card|pkg|package|gpu|gfx|total)
              echo "$f"
              return 0
              ;;
          esac
          [[ -z "$best_any" ]] && best_any="$f"
        fi
      done
    done < <(gpu_hwmons_for_device "$dev")
    if [[ -n "$best_any" ]]; then
      echo "$best_any"
      return 0
    fi
    return 1
  }

  local best_rank=999
  local best_boot=-1
  local best_label="" best_bus="" best_file="" best_energy="" best_is_dgpu="false"
  local -a best_cmd=()
  local dev

  for dev in /sys/bus/pci/devices/*; do
    [[ -f "$dev/vendor" && -f "$dev/class" ]] || continue
    local vendor class boot bus rank label power_file energy_file is_dgpu
    local -a cmd=()
    vendor=$(<"$dev/vendor")
    class=$(<"$dev/class")
    [[ "$class" == 0x03* ]] || continue
    bus="${dev##*/}"
    boot="0"
    [[ -r "$dev/boot_vga" ]] && boot=$(<"$dev/boot_vga")

    case "$vendor" in
      0x1002)
        label="AMD"
        rank=1
        is_dgpu=true
        ;;
      0x10de)
        label="NVIDIA"
        rank=1
        is_dgpu=true
        ;;
      0x8086)
        # Treat integrated Intel GPU as fallback; prefer ARC dGPU.
        if [[ "$bus" == 0000:00:02.* ]]; then
          label="Intel iGPU"
          rank=4
          is_dgpu=false
        else
          label="ARC"
          rank=2
          is_dgpu=true
        fi
        ;;
      *)
        continue
        ;;
    esac

    power_file=$(gpu_power_file_for_device "$dev" || true)
    energy_file=""
    if [[ -n "$power_file" ]]; then
      :
    else
      energy_file=$(gpu_energy_file_for_device "$dev" || true)
    fi

    if [[ -n "$power_file" ]]; then
      :
    elif [[ -n "$energy_file" ]]; then
      # Slightly lower confidence than direct power input.
      (( rank += 1 ))
    elif [[ "$vendor" == "0x10de" ]] && command -v nvidia-smi >/dev/null 2>&1; then
      # Prefer hwmon; NVML is fallback.
      cmd=(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits -i 0)
      (( rank += 1 ))
    else
      continue
    fi

    if (( rank < best_rank )) || { (( rank == best_rank )) && (( boot > best_boot )); }; then
      best_rank=$rank
      best_boot=$boot
      best_label="$label"
      best_bus="$bus"
      best_file="$power_file"
      best_energy="$energy_file"
      best_is_dgpu="$is_dgpu"
      best_cmd=("${cmd[@]}")
    fi
  done

  if [[ -n "$best_label" && ( -n "$best_file" || -n "$best_energy" || -n "${best_cmd[*]:-}" ) ]]; then
    GPU_VENDOR_LABEL="$best_label"
    GPU_BUS_ID="$best_bus"
    GPU_POWER_FILE="$best_file"
    GPU_ENERGY_FILE="$best_energy"
    GPU_IS_DGPU="$best_is_dgpu"
    GPU_READ_CMD=("${best_cmd[@]}")
    log_debug "gpu_selected label=${GPU_VENDOR_LABEL} bus=${GPU_BUS_ID} dgpu=${GPU_IS_DGPU} file=${GPU_POWER_FILE:-none} energy=${GPU_ENERGY_FILE:-none} cmd=${GPU_READ_CMD[*]:-none} rank=${best_rank}"
    return 0
  fi

  # Last-resort NVIDIA fallback.
  if command -v nvidia-smi >/dev/null 2>&1 && [[ -d /proc/driver/nvidia/gpus ]] && compgen -G "/proc/driver/nvidia/gpus/*" >/dev/null; then
    GPU_READ_CMD=(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits -i 0)
    GPU_VENDOR_LABEL="NVIDIA"
    GPU_IS_DGPU="true"
    log_debug "gpu_fallback_nvml cmd=${GPU_READ_CMD[*]}"
    return 0
  fi

  log_debug "gpu_not_found"
}

read_gpu_w() {
  GPU_W="0.00"
  if [[ -n "${GPU_POWER_FILE:-}" ]]; then
    local uw
    if uw=$(<"$GPU_POWER_FILE"); then
      GPU_W=$(awk -v uw="$uw" 'BEGIN{printf "%.2f", uw/1000000.0}')
      return 0
    fi
    log_debug "gpu_read_failed path=${GPU_POWER_FILE}"
  elif [[ -n "${GPU_ENERGY_FILE:-}" ]]; then
    local e pe de
    if e=$(<"$GPU_ENERGY_FILE"); then
      # Persist this sensor in the shared cache so next run can compute delta watts.
      CUR_E["$GPU_ENERGY_FILE"]="$e"
      CUR_M["$GPU_ENERGY_FILE"]="18446744073709551615"
      CUR_G["$GPU_ENERGY_FILE"]="gpu"
      if [[ "$PREV_TS" -gt 0 && -n "${PREV_E[$GPU_ENERGY_FILE]:-}" && "$dt" != "n/a" ]]; then
        pe="${PREV_E[$GPU_ENERGY_FILE]}"
        de=$(( e - pe ))
        (( de < 0 )) && de=0
        GPU_W=$(awk -v de="$de" -v dt="$dt" 'BEGIN{if(dt>0) printf "%.2f", (de/1e6)/dt; else print "0.00"}')
      else
        GPU_W="0.00"
      fi
      return 0
    fi
    log_debug "gpu_read_failed energy_path=${GPU_ENERGY_FILE}"
  elif [[ -n "${GPU_READ_CMD[*]:-}" ]]; then
    local val
    if val=$("${GPU_READ_CMD[@]}" 2>/dev/null | head -n1); then
      # nvidia-smi returns watts already
      val=${val%% *}
      GPU_W=$(awk -v w="$val" 'BEGIN{if(w!="") printf "%.2f", w; else print "0.00"}')
      return 0
    fi
    log_debug "gpu_read_failed cmd=${GPU_READ_CMD[*]}"
  fi
  GPU_W="0.00"
  return 1
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
if [[ -n "${GPU_POWER_FILE:-}" || -n "${GPU_ENERGY_FILE:-}" || -n "${GPU_READ_CMD[*]:-}" ]]; then
  gpu_present=true
  read_gpu_w
  gpu_w="${GPU_W:-0.00}"
fi

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
elif [[ "${GPU_IS_DGPU:-false}" == "true" ]] && $gpu_present; then
  text_prefix="${JSON_ICON_GPU} ${GPU_VENDOR_LABEL:-GPU} ${gpu_w} W"
  tooltip_prefix="${GPU_VENDOR_LABEL:-GPU}: ${gpu_w} W"
elif $igpu_power_present; then
  text_prefix="iGPU ${igpu_w} W"
  tooltip_prefix="iGPU Power: ${igpu_w} W"
elif $gpu_present; then
  text_prefix="Gfx ${gpu_w} W"
  tooltip_prefix="${GPU_VENDOR_LABEL:-Gfx}: ${gpu_w} W"
else
  t_gfx=""
  if [[ -f "$TSTAT_SUMMARY" ]]; then
    t_gfx=$(awk -F= '/^gfx=/{print $2}' "$TSTAT_SUMMARY" 2>/dev/null || echo "")
  fi
  if [[ -n "$t_gfx" ]]; then
    text_prefix="Gfx ${t_gfx} W"
    tooltip_prefix="Turbostat Gfx: ${t_gfx} W"
  else
    text_prefix="Battery n/a"
    tooltip_prefix="Battery: not present"
  fi
fi

pkg_display="$pkg_w"
if [[ -f "$TSTAT_SUMMARY" ]]; then
  t_pkg=$(awk -F= '/^pkg=/{print $2}' "$TSTAT_SUMMARY" 2>/dev/null || echo "")
  if [[ -n "$t_pkg" ]]; then
    pkg_display="$t_pkg"
  fi
fi
[[ "$pkg_display" == "0.00" && $pkg_present == false ]] && pkg_display="N/A"
psys_display="$psys_effective_w"
[[ $psys_present == false ]] && psys_display="N/A"

# On first run (no previous cache), pkg_w/psys_w will be 0.00 — that’s expected.
text="${text_prefix} | CPU ${pkg_display} W | ${psys_label} ${psys_display} W"
tooltip="${tooltip_prefix}\nCPU Package: ${pkg_display} W\n${psys_label}: ${psys_display} W"
log_debug "metrics dt=${dt} pkg_uj=${pkg_uj} psys_uj=${psys_uj} pkg_w=${pkg_w} pkg_present=${pkg_present} psys_w=${psys_w} psys_present=${psys_present} psys_effective_w=${psys_effective_w} battery_w=${battery_w} battery_status=${status} gpu_present=${gpu_present} gpu_w=${gpu_w} gpu_path=${GPU_POWER_FILE:-none} gpu_energy_path=${GPU_ENERGY_FILE:-none}"
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
