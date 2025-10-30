#!/bin/bash

# Path to the power_now file
POWER_NOW_FILE="/sys/class/power_supply/BAT0/power_now"

# Check if the battery power file exists
if [ ! -f "$POWER_NOW_FILE" ]; then
    battery_watts="N/A"
else
    # Read power in microwatts
    power_microwatts=$(cat "$POWER_NOW_FILE")
    # Convert to watts
    battery_watts=$(awk "BEGIN {printf \"%.2f\", $power_microwatts / 1000000}")
fi

# Get CPU package power using turbostat
# The output has a header, then a line of values. We want the PkgWatt value from the second line of data.
pkg_power=$(sudo turbostat --Summary --quiet -i 1 -n 1 | tail -n 1 | awk '{print $(NF-6)}')

# Get battery status
status=$(cat /sys/class/power_supply/BAT0/status)

# Set icon based on status
if [ "$status" = "Charging" ]; then
    icon="" # Charging icon
    tooltip="Battery (Charging): ${battery_watts} W\nCPU Package: ${pkg_power} W"
else
    icon="" # Battery icon
    tooltip="Battery (Discharging): ${battery_watts} W\nCPU Package: ${pkg_power} W"
fi

# Output JSON for Waybar
text="${icon} ${battery_watts} W | CPU ${pkg_power} W"
echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"