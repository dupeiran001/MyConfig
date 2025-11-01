#!/bin/bash

WG_INTERFACE="wg"
WG_ALL_INTERFACE="wg-all"

# Check which WireGuard connection is active
ACTIVE_WG=$(nmcli con show --active | grep wireguard | awk '{print $1}')

if [ -z "$ACTIVE_WG" ]; then
    STATUS="inactive"
    CLASS="gray"
    TOOLTIP="WireGuard is inactive\nLeft-click to connect to $WG_INTERFACE\nRight-click to connect to $WG_ALL_INTERFACE"
    TEXT="󰖪"
elif [ "$ACTIVE_WG" == "$WG_INTERFACE" ]; then
    STATUS="limited"
    CLASS="yellow"
    PEER=$(sudo wg show "$WG_INTERFACE" | grep 'peer:' | awk '{print $2}' | head -n 1)
    TOOLTIP="Connected (Limited) to $PEER\n\nLeft-click to disconnect\nRight-click to switch to $WG_ALL_INTERFACE"
    TEXT="󰖢"
elif [ "$ACTIVE_WG" == "$WG_ALL_INTERFACE" ]; then
    STATUS="all"
    CLASS="green"
    PEER=$(sudo wg show "$WG_ALL_INTERFACE" | grep 'peer:' | awk '{print $2}' | head -n 1)
    TOOLTIP="Connected (All Traffic) to $PEER\n\nLeft-click to disconnect\nRight-click to switch to $WG_INTERFACE"
    TEXT="󰖣"
else
    STATUS="error"
    CLASS="red"
    TOOLTIP="Error: Unknown WireGuard connection active"
    TEXT="󰖦"
fi

# Handle clicks
if [ "$1" == "click" ]; then
    case "$2" in
        "left")
            if [ "$STATUS" == "inactive" ]; then
                nmcli con up id "$WG_INTERFACE"
            else
                nmcli con down id "$ACTIVE_WG"
            fi
            ;; 
        "right")
            if [ "$STATUS" == "inactive" ]; then
                nmcli con up id "$WG_ALL_INTERFACE"
            elif [ "$STATUS" == "limited" ]; then
                (nmcli con down id "$WG_INTERFACE" && nmcli con up id "$WG_ALL_INTERFACE")
            elif [ "$STATUS" == "all" ]; then
                (nmcli con down id "$WG_ALL_INTERFACE" && nmcli con up id "$WG_INTERFACE")
            fi
            ;; 
    esac
    exit 0
fi

# Escape tooltip for JSON
ESCAPED_TOOLTIP=$(echo -e "$TOOLTIP" | sed -e 's/"/\\"/g' | sed -e ':a;N;$!ba;s/\n/\\n/g')

# Output JSON for Waybar
printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$TEXT" "$CLASS" "$ESCAPED_TOOLTIP"
