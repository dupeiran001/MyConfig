#!/bin/bash

set -uo pipefail

# === Platform detection cache ===
# All expensive detection (core topology, GPU, daemons) runs once at init.
# Subsequent calls only read sysfs frequencies and format output.

UID_SAFE="${SUDO_UID:-$UID}"
INIT_CACHE="/tmp/avg-cpu-freq-init.${UID_SAFE}.cache"
CACHE_RAW="/tmp/turbostat-waybar.${UID_SAFE}.raw"
PIDFILE="/tmp/turbostat-waybar.${UID_SAFE}.pid"
DAEMON="$HOME/.config/waybar/scripts/turbostat-daemon.sh"
IGPU_JSON="/tmp/intel-gpu-top.${UID_SAFE}.json"
IGPU_PIDFILE="/tmp/intel-gpu-top.${UID_SAFE}.pid"
IGPU_DAEMON="$HOME/.config/waybar/scripts/intel-gpu-top-daemon.sh"
IGPU_RC6_CACHE="/tmp/igpu-rc6.${UID_SAFE}.cache"
FREQ_SOURCE_MODE="${AVG_CPU_FREQ_SOURCE:-auto}"

if [[ "$FREQ_SOURCE_MODE" != "auto" && "$FREQ_SOURCE_MODE" != "cpufreq" && "$FREQ_SOURCE_MODE" != "bzy" ]]; then
  FREQ_SOURCE_MODE="auto"
fi

# ---------------------------------------------------------------
# Init: detect platform capabilities, write cache, start daemons
# ---------------------------------------------------------------
do_init() {
  local have_core_type=false
  [[ -f /sys/devices/system/cpu/cpu0/topology/core_type ]] && have_core_type=true

  local use_bzy=false
  if [[ "$FREQ_SOURCE_MODE" == "bzy" ]]; then
    use_bzy=true
  elif [[ "$FREQ_SOURCE_MODE" == "auto" && "$have_core_type" == "true" ]]; then
    use_bzy=true
  fi

  local freq_label="cpufreq"
  $use_bzy && freq_label="turbostat(Bzy_MHz)"

  # Detect mode and classify CPUs
  local mode="" p_cpus="" e_cpus="" p_max=0 e_max=0

  if $have_core_type; then
    mode="core_type"
    for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
      local num="${cpu_dir##*/cpu}" ct=""
      read ct < "$cpu_dir/topology/core_type" 2>/dev/null || ct=""
      if [[ "$ct" == "1" ]]; then
        p_cpus="${p_cpus:+$p_cpus }$num"
      elif [[ "$ct" == "0" ]]; then
        e_cpus="${e_cpus:+$e_cpus }$num"
      fi
    done
  else
    # Check for hybrid via max_freq split (≥1.2x ratio)
    local all_max
    all_max=($(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq 2>/dev/null | sort -un))
    if [[ ${#all_max[@]} -eq 2 ]] && (( all_max[0] > 0 && all_max[1] * 100 / all_max[0] >= 120 )); then
      mode="max_freq_split"
      p_max=${all_max[1]}
      e_max=${all_max[0]}
      for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
        local num="${cpu_dir##*/cpu}" mf=0
        read mf < "$cpu_dir/cpufreq/cpuinfo_max_freq" 2>/dev/null || mf=0
        if [[ "$mf" -eq "$p_max" ]]; then
          p_cpus="${p_cpus:+$p_cpus }$num"
        elif [[ "$mf" -eq "$e_max" ]]; then
          e_cpus="${e_cpus:+$e_cpus }$num"
        fi
      done
    else
      mode="uniform"
      for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
        local num="${cpu_dir##*/cpu}"
        p_cpus="${p_cpus:+$p_cpus }$num"
      done
    fi
  fi

  # Detect GPU
  local gpu_type="none" gpu_file=""
  # AMD GPU
  local dev
  for dev in /sys/class/drm/card*/device; do
    [[ -d "$dev" && -f "$dev/vendor" && -f "$dev/class" ]] || continue
    local vendor class
    vendor=$(<"$dev/vendor")
    class=$(<"$dev/class")
    if [[ "$vendor" == "0x1002" && "$class" == 0x03* && -r "$dev/gpu_busy_percent" ]]; then
      gpu_type="amd"
      gpu_file="$dev/gpu_busy_percent"
      break
    fi
  done
  # Intel GPU (sysfs)
  if [[ "$gpu_type" == "none" ]]; then
    for dev in /sys/class/drm/card*/device; do
      [[ -d "$dev" && -f "$dev/vendor" && -f "$dev/class" ]] || continue
      local vendor class
      vendor=$(<"$dev/vendor")
      class=$(<"$dev/class")
      [[ "$vendor" == "0x8086" && "$class" == 0x03* ]] || continue
      for f in gpu_busy_percent gt_busy_percent; do
        if [[ -r "$dev/$f" ]]; then
          gpu_type="igpu_sysfs"
          gpu_file="$dev/$f"
          break 2
        fi
      done
      # RC6 fallback
      local card="${dev%/device}"
      if [[ -r "$card/gt/gt0/rc6_residency_ms" ]]; then
        gpu_type="igpu_rc6"
        gpu_file="$card/gt/gt0/rc6_residency_ms"
        break
      fi
    done
  fi
  # intel_gpu_top JSON fallback
  if [[ "$gpu_type" == "none" && -f "$IGPU_JSON" ]]; then
    gpu_type="igpu_top"
    gpu_file="$IGPU_JSON"
  fi

  # Start daemons if applicable
  if [[ -x "$DAEMON" ]]; then
    local running=false
    if [[ -f "$PIDFILE" ]]; then
      local pid
      pid=$(<"$PIDFILE") 2>/dev/null && kill -0 "$pid" 2>/dev/null && running=true
    fi
    $running || nohup "$DAEMON" >/dev/null 2>&1 &
  fi
  if [[ "$gpu_type" == "igpu_top" || "$gpu_type" == "none" ]] && [[ -x "$IGPU_DAEMON" ]]; then
    local running=false
    if [[ -f "$IGPU_PIDFILE" ]]; then
      local pid
      pid=$(<"$IGPU_PIDFILE") 2>/dev/null && kill -0 "$pid" 2>/dev/null && running=true
    fi
    $running || nohup "$IGPU_DAEMON" >/dev/null 2>&1 &
  fi

  # Write cache
  cat > "$INIT_CACHE" <<CACHE
MODE=$mode
USE_BZY=$use_bzy
FREQ_LABEL=$freq_label
P_CPUS="$p_cpus"
E_CPUS="$e_cpus"
P_MAX=$p_max
E_MAX=$e_max
GPU_TYPE=$gpu_type
GPU_FILE=$gpu_file
CACHE
}

# ---------------------------------------------------------------
# Hot path helpers (pure bash, zero subprocesses)
# ---------------------------------------------------------------
khz_to_ghz() {
  local khz="$1"
  local i=$(( khz / 1000000 ))
  local f=$(( (khz % 1000000) / 10000 ))
  printf "%d.%02d" "$i" "$f"
}

# ---------------------------------------------------------------
# Init if needed
# ---------------------------------------------------------------
if [[ ! -f "$INIT_CACHE" ]]; then
  do_init
fi
source "$INIT_CACHE"

# ---------------------------------------------------------------
# Hot path: read frequencies, compute averages, output JSON
# ---------------------------------------------------------------

# Read turbostat Bzy_MHz cache if using bzy mode
declare -A bzy_by_cpu
if [[ "$USE_BZY" == "true" && -f "$CACHE_RAW" ]]; then
  while read -r cpu busy bzy; do
    [[ "$cpu" =~ ^[0-9]+$ ]] || continue
    bzy_by_cpu["$cpu"]="$bzy"
  done < "$CACHE_RAW"
fi

# Read frequency for one CPU (no subprocesses)
read_freq() {
  local num="$1"
  local dir="/sys/devices/system/cpu/cpu${num}/cpufreq"
  local cur=0 max=0
  read cur < "$dir/scaling_cur_freq" 2>/dev/null || cur=0
  if [[ "$USE_BZY" == "true" && -n "${bzy_by_cpu[$num]:-}" ]]; then
    local bzy_raw="${bzy_by_cpu[$num]}"
    local bzy_khz="${bzy_raw%%.*}"
    [[ -z "$bzy_khz" || "$bzy_khz" -lt 0 ]] 2>/dev/null && bzy_khz=0
    bzy_khz=$(( bzy_khz * 1000 ))
    read max < "$dir/cpuinfo_max_freq" 2>/dev/null || max=0
    if [[ "$max" -gt 0 && "$bzy_khz" -gt $(( max * 115 / 100 )) ]]; then
      REPLY=$cur
    else
      REPLY=$bzy_khz
    fi
  else
    REPLY=$cur
  fi
}

# GPU suffix
igpu_suffix=""
case "$GPU_TYPE" in
  amd|igpu_sysfs)
    val=""
    read val < "$GPU_FILE" 2>/dev/null || val=""
    if [[ -n "$val" ]]; then
      label="iGPU"
      [[ "$GPU_TYPE" == "amd" ]] && label="Gfx"
      igpu_suffix=" | $label ${val}%"
    fi
    ;;
  igpu_rc6)
    # Delta-based RC6 usage
    now=$(date +%s%N 2>/dev/null || printf "0")
    rc6=""
    read rc6 < "$GPU_FILE" 2>/dev/null || rc6=""
    if [[ -n "$rc6" ]]; then
      prev_ts=0 prev_rc6=0
      if [[ -f "$IGPU_RC6_CACHE" ]]; then
        IFS=$'\t' read -r prev_ts prev_rc6 < "$IGPU_RC6_CACHE" || true
      fi
      printf "%s\t%s\n" "$now" "$rc6" > "${IGPU_RC6_CACHE}.new" 2>/dev/null
      mv -f "${IGPU_RC6_CACHE}.new" "$IGPU_RC6_CACHE" 2>/dev/null || true
      if [[ "$prev_ts" -gt 0 ]]; then
        dt_ns=$(( now - prev_ts ))
        drc6=$(( rc6 - prev_rc6 ))
        if [[ "$dt_ns" -gt 0 ]]; then
          busy=$(( 100 - drc6 * 1000000000 / dt_ns * 100 / 1000 ))
          (( busy < 0 )) && busy=0
          (( busy > 100 )) && busy=100
          igpu_suffix=" | RC6 ${busy}%"
        fi
      fi
    fi
    ;;
  igpu_top)
    # Read from intel_gpu_top JSON - requires jq or python3 (expensive, but rare)
    if [[ -f "$GPU_FILE" ]] && command -v jq >/dev/null 2>&1; then
      val=$(jq -r '[.. | objects | to_entries[] | select(.key|test("busy|util|render|rcs";"i")) | .value | if type=="number" then . elif type=="object" then (.value // .percent // empty) else empty end] | first // empty' "$GPU_FILE" 2>/dev/null)
      if [[ -n "$val" ]]; then
        igpu_suffix=" | iGPU ${val%.*}%"
      fi
    fi
    ;;
esac

# Compute averages and build output
if [[ "$MODE" == "core_type" || "$MODE" == "max_freq_split" ]]; then
  p_total=0 p_count=0
  e_total=0 e_count=0
  p_tooltip="" e_tooltip=""

  for num in $P_CPUS; do
    read_freq "$num"
    p_total=$(( p_total + REPLY ))
    p_count=$(( p_count + 1 ))
    p_tooltip="${p_tooltip}Core ${num}: $(khz_to_ghz "$REPLY") GHz\n"
  done

  for num in $E_CPUS; do
    read_freq "$num"
    e_total=$(( e_total + REPLY ))
    e_count=$(( e_count + 1 ))
    e_tooltip="${e_tooltip}Core ${num}: $(khz_to_ghz "$REPLY") GHz\n"
  done

  p_avg="N/A" e_avg="N/A"
  (( p_count > 0 )) && p_avg=$(khz_to_ghz "$(( p_total / p_count ))")
  (( e_count > 0 )) && e_avg=$(khz_to_ghz "$(( e_total / e_count ))")

  if [[ "$MODE" == "max_freq_split" ]]; then
    tooltip="P-Cores (Max: $(khz_to_ghz "$P_MAX") GHz):\n${p_tooltip}\nE-Cores (Max: $(khz_to_ghz "$E_MAX") GHz):\n${e_tooltip}\nFreq source: ${FREQ_LABEL}"
  else
    tooltip="P-Cores:\n${p_tooltip}\nE-Cores:\n${e_tooltip}\nFreq source: ${FREQ_LABEL}"
  fi

  text="P: ${p_avg} GHz | E: ${e_avg} GHz${igpu_suffix}"
  printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
else
  # Uniform: all cores averaged
  total=0 count=0
  for num in $P_CPUS; do
    read_freq "$num"
    total=$(( total + REPLY ))
    count=$(( count + 1 ))
  done
  avg="N/A"
  (( count > 0 )) && avg=$(khz_to_ghz "$(( total / count ))")

  text="Avg: ${avg} GHz${igpu_suffix}"
  tooltip="Average core frequency\nFreq source: ${FREQ_LABEL}"
  printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
fi
