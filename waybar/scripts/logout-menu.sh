#!/usr/bin/env bash

config="$HOME/.config/rofi/logout-menu.rasi"

actions=$(echo -e "   Lock\n   Shutdown\n   Reboot\n $(printf '\u200A')  Suspend\n   Hibernate\n   Logout")

# Display logout menu
selected_option=$(echo -e "$actions" | rofi -dmenu -i -theme "/home/dpr/.config/rofi/nord.rasi")

# Perform actions based on the selected option
case "$selected_option" in
*Lock)
  swaylock
  ;;
*Shutdown)
  systemctl poweroff
  ;;
*Reboot)
  systemctl reboot
  ;;
*Suspend)
  swaylock -f && sleep 1 && systemctl suspend
  ;;
*Hibernate)
  swaylock -f && sleep 1 && systemctl hibernate
  ;;
*Logout)
  niri msg action quit
  ;;
esac
