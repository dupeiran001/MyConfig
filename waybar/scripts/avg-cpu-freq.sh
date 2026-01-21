#!/bin/bash

set -uo pipefail

UID_SAFE="${SUDO_UID:-$UID}"
CACHE_RAW="/tmp/turbostat-waybar.${UID_SAFE}.raw"
PIDFILE="/tmp/turbostat-waybar.${UID_SAFE}.pid"
DAEMON="$HOME/.config/waybar/scripts/turbostat-daemon.sh"
IGPU_JSON="/tmp/intel-gpu-top.${UID_SAFE}.json"
IGPU_PIDFILE="/tmp/intel-gpu-top.${UID_SAFE}.pid"
IGPU_DAEMON="$HOME/.config/waybar/scripts/intel-gpu-top-daemon.sh"
IGPU_RC6_CACHE="/tmp/igpu-rc6.${UID_SAFE}.cache"
IGPU_JSON_CACHE="/tmp/intel-gpu-top.${UID_SAFE}.cache"

start_daemon() {
  [[ -x "$DAEMON" ]] || return 0
  nohup "$DAEMON" >/dev/null 2>&1 &
}

start_igpu_daemon() {
  [[ -x "$IGPU_DAEMON" ]] || return 0
  nohup "$IGPU_DAEMON" >/dev/null 2>&1 &
}

find_igpu_usage_file() {
  local dev vendor class
  for dev in /sys/class/drm/card*/device; do
    [[ -d "$dev" && -f "$dev/vendor" && -f "$dev/class" ]] || continue
    vendor=$(<"$dev/vendor")
    class=$(<"$dev/class")
    [[ "$vendor" == "0x8086" && "$class" == 0x03* ]] || continue
    for f in gpu_busy_percent gt_busy_percent; do
      if [[ -r "$dev/$f" ]]; then
        echo "$dev/$f"
        return 0
      fi
    done
  done
  return 1
}

read_igpu_usage() {
  local f="$1" val
  if [[ -n "$f" ]] && val=$(<"$f"); then
    awk -v v="$val" 'BEGIN{if(v=="") print ""; else printf "%d", v+0}'
    return 0
  fi
  return 1
}

find_igpu_rc6_file() {
  local card vendor
  for card in /sys/class/drm/card*; do
    [[ -d "$card" ]] || continue
    [[ "$card" == *"-"* ]] && continue
    if [[ -f "$card/device/vendor" ]]; then
      vendor=$(<"$card/device/vendor")
      [[ "$vendor" == "0x8086" ]] || continue
      if [[ -r "$card/gt/gt0/rc6_residency_ms" ]]; then
        echo "$card/gt/gt0/rc6_residency_ms"
        return 0
      fi
    fi
  done
  return 1
}

read_igpu_usage_rc6() {
  # Usage ~= 100 - (delta_rc6 / delta_time * 100)
  local rc6_file="$1" now rc6 prev_ts prev_rc6 dt_ms drc6 busy
  now=$(date +%s%N 2>/dev/null || printf "0")
  if ! rc6=$(<"$rc6_file"); then
    echo ""
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
    busy=$(awk -v drc6="$drc6" -v dt="$dt_ms" 'BEGIN{if(dt>0){v=100-(drc6/dt*100); if(v<0)v=0; if(v>100)v=100; printf "%d", v+0}else print ""}')
    echo "$busy"
    return 0
  fi
  echo ""
  return 0
}

get_igpu_usage_from_intel_gpu_top() {
  local json="$IGPU_JSON" rc6 render busy cache_label cache_val
  [[ -f "$json" ]] || return 1

  json_find_num() {
    local pattern="$1"
    if command -v jq >/dev/null 2>&1; then
      jq -r '
        def numval:
          if type=="number" then .
          elif type=="object" then (.value // .percent // .percentage // empty)
          else empty end;
        [.. | objects | to_entries[] | select(.key|ascii_downcase|test($pat)) | .value | numval]
        | first // empty
      ' --arg pat "$pattern" "$json" 2>/dev/null || echo ""
      return 0
    fi
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$json" "$pattern" <<'PY' 2>/dev/null || true
import json
import re
import sys

path = sys.argv[1]
pat = re.compile(sys.argv[2], re.IGNORECASE)

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

def numval(val):
    if isinstance(val, (int, float)):
        return val
    if isinstance(val, dict):
        for k in ("value", "percent", "percentage"):
            v = val.get(k)
            if isinstance(v, (int, float)):
                return v
    return None

def walk(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if pat.search(str(k)):
                nv = numval(v)
                if nv is not None:
                    return nv
            nv = walk(v)
            if nv is not None:
                return nv
    elif isinstance(obj, list):
        for v in obj:
            nv = walk(v)
            if nv is not None:
                return nv
    return None

nv = walk(data)
if nv is not None:
    print(nv)
PY
      return 0
    fi
    echo ""
    return 0
  }

  if [[ -f "$IGPU_JSON_CACHE" ]]; then
    IFS=$'\t' read -r cache_label cache_val < "$IGPU_JSON_CACHE" || true
    IGPU_LABEL="$cache_label"
    echo "$cache_val"
    return 0
  fi

  busy=$(json_find_num "busy|util")
  if [[ -n "$busy" ]]; then
    IGPU_LABEL="iGPU"
    busy=$(awk -v v="$busy" 'BEGIN{if(v<0)v=0; if(v>100)v=100; printf "%d", v+0}')
    printf "%s\t%s\n" "$IGPU_LABEL" "$busy" > "${IGPU_JSON_CACHE}.new" || true
    mv -f "${IGPU_JSON_CACHE}.new" "$IGPU_JSON_CACHE" 2>/dev/null || true
    echo "$busy"
    return 0
  fi

  render=$(json_find_num "render|rcs")
  if [[ -n "$render" ]]; then
    IGPU_LABEL="Render"
    render=$(awk -v v="$render" 'BEGIN{if(v<0)v=0; if(v>100)v=100; printf "%d", v+0}')
    printf "%s\t%s\n" "$IGPU_LABEL" "$render" > "${IGPU_JSON_CACHE}.new" || true
    mv -f "${IGPU_JSON_CACHE}.new" "$IGPU_JSON_CACHE" 2>/dev/null || true
    echo "$render"
    return 0
  fi

  rc6=$(json_find_num "rc6")
  [[ -n "$rc6" ]] || return 1
  IGPU_LABEL="RC6"
  rc6=$(awk -v r="$rc6" 'BEGIN{u=100-r; if(u<0)u=0; if(u>100)u=100; printf "%d", u+0}')
  printf "%s\t%s\n" "$IGPU_LABEL" "$rc6" > "${IGPU_JSON_CACHE}.new" || true
  mv -f "${IGPU_JSON_CACHE}.new" "$IGPU_JSON_CACHE" 2>/dev/null || true
  echo "$rc6"
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

igpu_running=false
if [[ -f "$IGPU_PIDFILE" ]]; then
  if pid=$(cat "$IGPU_PIDFILE" 2>/dev/null) && kill -0 "$pid" 2>/dev/null; then
    igpu_running=true
  fi
fi
if ! $igpu_running; then
  start_igpu_daemon
fi

have_core_type=false
if [[ -f /sys/devices/system/cpu/cpu0/topology/core_type ]]; then
  have_core_type=true
fi

declare -A bzy_by_cpu
if [[ -f "$CACHE_RAW" ]]; then
  while read -r cpu busy bzy; do
    [[ "$cpu" =~ ^[0-9]+$ ]] || continue
    bzy_by_cpu["$cpu"]="$bzy"
  done < "$CACHE_RAW"
fi

calc_avg_khz() {
  local total=0 count=0
  for v in "$@"; do
    total=$((total + v))
    count=$((count + 1))
  done
  if (( count == 0 )); then
    echo "N/A"
    return
  fi
  local avg=$((total / count))
  awk "BEGIN {printf \"%.2f\", $avg / 1000000}"
}

IGPU_LABEL=""
igpu_usage=""
if igpu_usage=$(get_igpu_usage_from_intel_gpu_top); then
  :
elif igpu_file=$(find_igpu_usage_file); then
  igpu_usage=$(read_igpu_usage "$igpu_file" || true)
  IGPU_LABEL="iGPU"
elif rc6_file=$(find_igpu_rc6_file); then
  igpu_usage=$(read_igpu_usage_rc6 "$rc6_file" || true)
  IGPU_LABEL="RC6"
fi
igpu_suffix=""
if [[ -n "$igpu_usage" ]]; then
  igpu_suffix=" | ${IGPU_LABEL:-iGPU} ${igpu_usage}%"
fi

if $have_core_type; then
  p_core_freqs=()
  e_core_freqs=()
  p_core_indices=()
  e_core_indices=()

  for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    cpu_num=$(basename "$cpu_dir" | sed 's/cpu//')
    core_type=$(cat "$cpu_dir/topology/core_type" 2>/dev/null || echo "")
    if [[ -n "${bzy_by_cpu[$cpu_num]:-}" ]]; then
      current_mhz="${bzy_by_cpu[$cpu_num]}"
      current_khz=$((current_mhz * 1000))
    else
      current_khz=$(cat "$cpu_dir/cpufreq/scaling_cur_freq" 2>/dev/null || echo 0)
    fi

    if [[ "$core_type" == "1" ]]; then
      p_core_freqs+=("$current_khz")
      p_core_indices+=("$cpu_num")
    elif [[ "$core_type" == "0" ]]; then
      e_core_freqs+=("$current_khz")
      e_core_indices+=("$cpu_num")
    fi
  done

  p_core_avg=$(calc_avg_khz "${p_core_freqs[@]}")
  e_core_avg=$(calc_avg_khz "${e_core_freqs[@]}")

  tooltip="P-Cores:\n"
  for i in "${!p_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${p_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${p_core_indices[$i]}: ${ghz} GHz\n"
  done
  tooltip="${tooltip}\nE-Cores:\n"
  for i in "${!e_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${e_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${e_core_indices[$i]}: ${ghz} GHz\n"
  done

  text="P: ${p_core_avg} GHz | E: ${e_core_avg} GHz${igpu_suffix}"
  printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
  exit 0
fi

# Fallback: use cpuinfo_max_freq split when core_type is unavailable
all_max_freqs=($(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq 2>/dev/null | sort -un))

if [ ${#all_max_freqs[@]} -ge 2 ]; then
  P_CORE_MAX_FREQ=${all_max_freqs[1]}
  E_CORE_MAX_FREQ=${all_max_freqs[0]}

  p_core_freqs=()
  e_core_freqs=()
  p_core_indices=()
  e_core_indices=()

  for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    cpu_num=$(basename "$cpu_dir" | sed 's/cpu//')
    max_freq=$(cat "$cpu_dir/cpufreq/cpuinfo_max_freq" 2>/dev/null || echo 0)
    if [[ -n "${bzy_by_cpu[$cpu_num]:-}" ]]; then
      current_mhz="${bzy_by_cpu[$cpu_num]}"
      current_khz=$((current_mhz * 1000))
    else
      current_khz=$(cat "$cpu_dir/cpufreq/scaling_cur_freq" 2>/dev/null || echo 0)
    fi

    if [ "$max_freq" -eq "$P_CORE_MAX_FREQ" ]; then
      p_core_freqs+=("$current_khz")
      p_core_indices+=("$cpu_num")
    elif [ "$max_freq" -eq "$E_CORE_MAX_FREQ" ]; then
      e_core_freqs+=("$current_khz")
      e_core_indices+=("$cpu_num")
    fi
  done

  p_core_avg=$(calc_avg_khz "${p_core_freqs[@]}")
  e_core_avg=$(calc_avg_khz "${e_core_freqs[@]}")

  tooltip="P-Cores (Max: $(awk "BEGIN {printf \"%.2f\", $P_CORE_MAX_FREQ / 1000000}") GHz):\n"
  for i in "${!p_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${p_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${p_core_indices[$i]}: ${ghz} GHz\n"
  done
  tooltip="${tooltip}\nE-Cores (Max: $(awk "BEGIN {printf \"%.2f\", $E_CORE_MAX_FREQ / 1000000}") GHz):\n"
  for i in "${!e_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${e_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${e_core_indices[$i]}: ${ghz} GHz\n"
  done

  text="P: ${p_core_avg} GHz | E: ${e_core_avg} GHz${igpu_suffix}"
  printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
  exit 0
fi

# Last fallback: show overall average only
all_freqs=()
for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
  current_khz=$(cat "$cpu_dir/cpufreq/scaling_cur_freq" 2>/dev/null || echo 0)
  all_freqs+=("$current_khz")
done
avg_all=$(calc_avg_khz "${all_freqs[@]}")
text="Avg: ${avg_all} GHz${igpu_suffix}"
tooltip="Average core frequency"
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
