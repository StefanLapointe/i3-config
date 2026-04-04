#!/bin/bash

# Get current volume as a percentage (0-100)
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check if muted
if echo "$volume" | grep -q "MUTED"; then
    dunstify -u low -r 2593 -i audio-volume-muted "Volume" "Muted"
else
    # Extract the numeric value and convert to percentage
    vol_percent=$(echo "$volume" | awk '{print int($2 * 100)}')
    dunstify -u low -r 2593 -h int:value:$vol_percent -i audio-volume-high "Volume" "${vol_percent}%"
fi
