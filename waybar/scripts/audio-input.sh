#!/bin/bash

# Get list of source descriptions, pipe to rofi
CHOSEN_DESC=$(pactl list sources | grep -ie "Description:" | awk -F ': ' '{print $2}' | sort | rofi -dmenu -i -p "Select Input:")

# If user pressed Esc, CHOSEN_DESC will be empty. Exit.
if [ -z "$CHOSEN_DESC" ]; then
    exit 0
fi

# Find the device *name* (e.g., alsa_input...) from the chosen *description*
DEVICE_NAME=$(pactl list sources | grep -B2 "Description: $CHOSEN_DESC" | grep "Name:" | awk '{print $2}')

# Set the chosen source as the default
pactl set-default-source "$DEVICE_NAME"

# Move all existing audio recording streams to the new source
pactl list short source-inputs | awk '{print $1}' | while read -r input_id; do
    pactl move-source-input "$input_id" "$DEVICE_NAME"
done

# Send notification
notify-send -r 91192 -i "audio-input-microphone" "Audio Input Set" "Set to: $CHOSEN_DESC"

