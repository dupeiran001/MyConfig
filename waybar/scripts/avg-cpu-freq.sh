#!/bin/bash

# Get all core frequencies in kHz
freqs=( $(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq) )

# Check if we got any frequencies
if [ ${#freqs[@]} -eq 0 ]; then
    echo "{"text": "N/A", "tooltip": "Could not read CPU frequencies"}"
    exit 1
fi

# Calculate the sum
total_freq=0
for freq in "${freqs[@]}"; do
    total_freq=$((total_freq + freq))
done

# Calculate the average in kHz
avg_freq_khz=$((total_freq / ${#freqs[@]}))

# Convert to GHz for display
avg_freq_ghz=$(awk "BEGIN {printf \"%.2f\", $avg_freq_khz / 1000000}")

# Prepare tooltip with individual core frequencies
tooltip="Average: ${avg_freq_ghz} GHz\n"
core_num=0
for freq in "${freqs[@]}"; do
    ghz=$(awk "BEGIN {printf \"%.2f\", $freq / 1000000}")
    tooltip="${tooltip}Core ${core_num}: ${ghz} GHz\n"
    core_num=$((core_num + 1))
done

# Output JSON for Waybar
echo "{\"text\": \" ${avg_freq_ghz} GHz\", \"tooltip\": \"${tooltip}\"}"
