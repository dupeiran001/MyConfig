#!/usr/bin/env bash
# run-on-ecores.sh - run a command pinned to E-cores when available

set -euo pipefail

if (( $# == 0 )); then
  printf 'Usage: %s <command> [args...]\n' "${0##*/}" >&2
  exit 2
fi

ecore_list=""
all_max_freqs=($(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq 2>/dev/null | sort -un))
if (( ${#all_max_freqs[@]} >= 2 )); then
  e_core_max_freq="${all_max_freqs[0]}"
  for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    cpu_num="${cpu_dir##*/cpu}"
    online=1
    if [[ -f "$cpu_dir/online" ]]; then
      online=$(cat "$cpu_dir/online" 2>/dev/null || echo 1)
    fi
    [[ "$online" == "1" ]] || continue
    max_freq=$(cat "$cpu_dir/cpufreq/cpuinfo_max_freq" 2>/dev/null || echo 0)
    if [[ "$max_freq" == "$e_core_max_freq" ]]; then
      if [[ -z "$ecore_list" ]]; then
        ecore_list="$cpu_num"
      else
        ecore_list="${ecore_list},${cpu_num}"
      fi
    fi
  done
fi

if [[ -n "$ecore_list" ]] && command -v taskset >/dev/null 2>&1; then
  exec taskset -c "$ecore_list" "$@"
fi

exec "$@"
