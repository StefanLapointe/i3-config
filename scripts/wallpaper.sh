#!/bin/bash

# Get screen resolution (requires xrandr)
# Using the maximum is correct for multi-monitor setups as it prevents
# images from ever being stretched.
MAX_SCREEN_W=$(xrandr --current | grep '*' | awk '{print $1}' | cut -d'x' -f1 | sort -n | tail -1)
MAX_SCREEN_H=$(xrandr --current | grep '*' | awk '{print $1}' | cut -d'x' -f2 | sort -n | tail -1)

# Choose a random wallpaper
IMAGE=$(find ~/Pictures/wallpapers -type f -print0 | shuf -z -n 1)

# Run Pywal
wal -i "$IMAGE" --backend colorz

# Update Emacs instances
for socket in /run/user/$(id -u)/emacs/*; do
    emacsclient --socket-name $(basename $socket) --eval '(ewal-load-colors)' 2>/dev/null
    emacsclient --socket-name $(basename $socket) --eval '(mapc (lambda (theme) (load-theme theme t)) custom-enabled-themes)' 2>/dev/null
done

# Get image dimensions (requires imagemagick)
IMG_W=$(identify -format "%w" "$IMAGE")
IMG_H=$(identify -format "%h" "$IMAGE")

# If image is larger than screen in both dimensions, scale it down to fill
if [ "$IMG_W" -gt "$MAX_SCREEN_W" ] && [ "$IMG_H" -gt "$MAX_SCREEN_H" ]; then
    feh --bg-fill "$IMAGE"
    exit 0
fi

# Use a suitable background colour to fill in the extra space
COLOUR=$(magick "$IMAGE" -kmeans 2 -unique-colors -define ftxt:format='\H\n' ftxt:- | head -n 1)

# If image is larger than screen in one dimension, scale it down to fit
if [ "$IMG_W" -gt "$MAX_SCREEN_W" ] || [ "$IMG_H" -gt "$MAX_SCREEN_H" ]; then
    feh --image-bg "$COLOUR" --bg-max "$IMAGE"
else
    feh --image-bg "$COLOUR" --bg-center "$IMAGE"
fi
