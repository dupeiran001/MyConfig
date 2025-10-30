#!/bin/bash
# tlp-status.sh - Get TLP status for Waybar

if [ -f /etc/tlp/active_profile ]; then
    PROFILE=$(cat /etc/tlp/active_profile)
else
    PROFILE="balanced" # Default if not set
fi

case "$PROFILE" in
    "performance")
        ICON="󰚥" # zap icon
        TOOLTIP="Performance"
        CLASS="performance"
        ;;
    "balanced")
        ICON="" # scales icon
        TOOLTIP="Balanced"
        CLASS="balanced"
        ;;
    "powersaver")
        ICON="󰾆" # leaf icon
        TOOLTIP="Power Saving"
        CLASS="powersaver"
        ;;
    *)
        ICON="?" # question mark icon
        TOOLTIP="Unknown"
        CLASS="unknown"
        ;;
esac

echo "{\"text\": \"$ICON\", \"tooltip\": \"Power Profile: $TOOLTIP\", \"class\": \"$CLASS\"}"