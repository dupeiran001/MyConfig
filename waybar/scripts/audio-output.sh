#!/bin/bash

# Get list of sink descriptions, pipe to rofi
CHOSEN_DESC=$(pactl list sinks | grep -ie "Description:" | awk -F ': ' '{print $2}' | sort | rofi -dmenu -p "Select Output:")

# If user pressed Esc, CHOSEN_DESC will be empty. Exit.
if [ -z "$CHOSEN_DESC" ]; then
    exit 0
fi

# Find the device *name* (e.g., alsa_output...) from the chosen *description*
# We use grep -B2 to get the 2 lines *before* the description, which will include the Name.
DEVICE_NAME=$(pactl list sinks | grep -B2 "Description: $CHOSEN_DESC" | grep "Name:" | awk '{print $2}')

# Set the chosen sink as the default
pactl set-default-sink "$DEVICE_NAME"

# Move all existing audio streams to the new sink
pactl list short sink-inputs | awk '{print $1}' | while read -r input_id; do
    pactl move-sink-input "$input_id" "$DEVICE_NAME"
done

# Send notification
notify-send -r 91191 -i "audio-speakers" "Audio Output Set" "Set to: $CHOSEN_DESC"

