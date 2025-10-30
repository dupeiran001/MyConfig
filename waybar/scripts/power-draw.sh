#!/bin/bash

# Path to the power_now file
POWER_NOW_FILE="/sys/class/power_supply/BAT0/power_now"

# Check if the file exists
if [ ! -f "$POWER_NOW_FILE" ]; then
    echo "{\"text\": \"N/A\", \"tooltip\": \"Power data not available\"}"
    exit 1
fi

# Read power in microwatts
power_microwatts=$(cat "$POWER_NOW_FILE")

# Convert to watts
power_watts=$(awk "BEGIN {printf \"%.2f\", $power_microwatts / 1000000}")

# Get battery status
status=$(cat /sys/class/power_supply/BAT0/status)

# Set icon based on status
if [ "$status" = "Charging" ]; then
    icon="" # Charging icon
    tooltip="Power Draw (Charging): ${power_watts} W"
else
    icon="" # Battery icon
    tooltip="Power Draw (Discharging): ${power_watts} W"
fi

# Output JSON for Waybar
echo "{\"text\": \"${icon} ${power_watts} W\", \"tooltip\": \"${tooltip}\"}"
