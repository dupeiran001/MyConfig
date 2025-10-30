#!/usr/bin/env bash

# Rofi configuration
config="$HOME/.config/rofi/nord.rasi"

# Options
options=" 󰤨  Wi-Fi\n 󰂰  Bluetooth\n   Logout"

# Display menu using Rofi
selected_option=$(echo -e "$options" | rofi -dmenu -i -theme "$config" -theme-str "window { height: 100px; }")

# Perform actions based on the selected option
case "$selected_option" in
*Wi-Fi)
  ~/.config/waybar/scripts/wifi-menu.sh
  ;;
*Bluetooth)
  ~/.config/waybar/scripts/bluetooth-menu.sh
  ;;
*Logout)
  ~/.config/waybar/scripts/logout-menu.sh
  ;;
esac
