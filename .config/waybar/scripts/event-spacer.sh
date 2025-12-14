#!/bin/bash
# Listens for window focus changes and updates spacer via Waybar IPC

# Get initial screen width (rarely changes)
SCREEN_WIDTH=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width')

# Static estimates (adjust based on your config)
LEFT_WIDTH=400   # workspaces + mode + scratchpad
RIGHT_WIDTH=800  # right modules (icons + text)

# Main loop: Update on window events
swaymsg -t subscribe '["window"]' | while read -r _; do
  # Get current window title length
  WIN_TITLE=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true).name? // ""')
  WIN_WIDTH=${#WIN_TITLE}

  # Calculate spacer width
  SPACER_WIDTH=$(( (SCREEN_WIDTH - LEFT_WIDTH - RIGHT_WIDTH - WIN_WIDTH) / 2 ))

  # Send update to Waybar via IPC
  echo '{"text": "'$(printf "%${SPACER_WIDTH}s" | tr ' ' ' ')'", "tooltip": ""}'  # U+2007
done
