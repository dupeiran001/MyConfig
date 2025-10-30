#!/bin/bash
# tlp-menu.sh - Rofi menu for TLP profile selection

OPTIONS="Max Performance\nPerformance\nBalanced\nPower Saving"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Select TLP Profile")

case "$CHOICE" in
    "Max Performance")
        PROFILE="max_performance"
        ;;
    "Performance")
        PROFILE="performance"
        ;;
    "Balanced")
        PROFILE="balanced"
        ;;
    "Power Saving")
        PROFILE="powersaver"
        ;;
    *)
        exit 1
        ;;
esac

# Set the new profile
sudo ln -sf "/etc/tlp/profiles/${PROFILE}.conf" /etc/tlp.conf
echo "$PROFILE" | sudo tee /etc/tlp/active_profile > /dev/null

# Restart TLP to apply the new settings
sudo tlp start
