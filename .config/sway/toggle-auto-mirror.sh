#!/bin/bash

SOURCE="eDP-1"

# Find any connected output that is not the internal laptop display
TARGET=$(swaymsg -t get_outputs | jq -r '.[].name' | grep -v "$SOURCE" | head -n 1)

# If no external display found, exit cleanly
if [ -z "$TARGET" ]; then
    notify-send "wl-mirror: no external display detected"
    exit 0
fi

# If wl-mirror is running, stop mirroring
if pgrep -x wl-mirror >/dev/null; then
    pkill wl-mirror
    notify-send "Mirroring disabled"
else
    # Start mirroring SOURCE -> TARGET
    wl-mirror "$SOURCE" "$TARGET" &
    notify-send "Mirroring $SOURCE → $TARGET"
fi
