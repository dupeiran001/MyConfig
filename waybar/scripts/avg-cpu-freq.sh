#!/bin/bash

# Get all max frequencies and find the unique high and low values
all_max_freqs=($(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/cpuinfo_max_freq | sort -un))

# The higher frequency corresponds to P-cores, the lower to E-cores.
# This assumes a hybrid architecture with exactly two different max frequencies.
if [ ${#all_max_freqs[@]} -lt 2 ]; then
    echo "{"text": "N/A", "tooltip": "Could not determine P-core/E-core split"}"
    exit 1
fi
P_CORE_MAX_FREQ=${all_max_freqs[1]}
E_CORE_MAX_FREQ=${all_max_freqs[0]}

p_core_freqs=()
e_core_freqs=()
p_core_indices=()
e_core_indices=()

# Read current frequencies for all cores and group them
for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    cpu_num=$(basename "$cpu_dir" | sed 's/cpu//')
    max_freq=$(cat "$cpu_dir/cpufreq/cpuinfo_max_freq")
    current_freq=$(cat "$cpu_dir/cpufreq/scaling_cur_freq")

    if [ "$max_freq" -eq "$P_CORE_MAX_FREQ" ]; then
        p_core_freqs+=("$current_freq")
        p_core_indices+=("$cpu_num")
    elif [ "$max_freq" -eq "$E_CORE_MAX_FREQ" ]; then
        e_core_freqs+=("$current_freq")
        e_core_indices+=("$cpu_num")
    fi
done

# Function to calculate average frequency
calculate_avg() {
    local freqs=($@)
    if [ ${#freqs[@]} -eq 0 ]; then
        echo "N/A"
        return
    fi
    local total_freq=0
    for freq in "${freqs[@]}"; do
        total_freq=$((total_freq + freq))
    done
    local avg_freq_khz=$((total_freq / ${#freqs[@]}))
    awk "BEGIN {printf \"%.2f\", $avg_freq_khz / 1000000}"
}

# Calculate averages
p_core_avg=$(calculate_avg "${p_core_freqs[@]}")
e_core_avg=$(calculate_avg "${e_core_freqs[@]}")

# Prepare tooltip
p_core_max_ghz=$(awk "BEGIN {printf \"%.2f\", $P_CORE_MAX_FREQ / 1000000}")
e_core_max_ghz=$(awk "BEGIN {printf \"%.2f\", $E_CORE_MAX_FREQ / 1000000}")
tooltip="P-Cores (Max: ${p_core_max_ghz} GHz):\n"
for i in "${!p_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${p_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${p_core_indices[$i]}: ${ghz} GHz\n"
done

tooltip="${tooltip}\nE-Cores (Max: ${e_core_max_ghz} GHz):\n"
for i in "${!e_core_indices[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", ${e_core_freqs[$i]} / 1000000}")
    tooltip="${tooltip}Core ${e_core_indices[$i]}: ${ghz} GHz\n"
done

# Output JSON for Waybar
text="P: ${p_core_avg} GHz | E: ${e_core_avg} GHz"
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
