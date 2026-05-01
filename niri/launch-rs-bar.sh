#!/bin/sh

# Detect platform and launch rs-bar with the appropriate config profile.
# Asahi Linux on Apple Silicon -> macbook, otherwise -> intel.

if [ -d /sys/class/power_supply/macsmc-battery ] || grep -qi 'apple' /proc/cpuinfo 2>/dev/null; then
    exec rs-bar --config macbook --relm
else
    exec rs-bar --config intel --relm
fi
