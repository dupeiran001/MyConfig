#!/bin/bash

set -uo pipefail

UID_SAFE="${SUDO_UID:-$UID}"
CACHE_RAW="/tmp/turbostat-waybar.${UID_SAFE}.raw"
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

  text="P: ${p_core_avg} GHz | E: ${e_core_avg} GHz"
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

  text="P: ${p_core_avg} GHz | E: ${e_core_avg} GHz"
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
text="Avg: ${avg_all} GHz"
tooltip="Average core frequency"
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
