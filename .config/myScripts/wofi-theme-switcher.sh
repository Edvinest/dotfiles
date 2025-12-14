#!/usr/bin/env bash
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin"

# -------------------------
# Theme paths (placeholder)
# -------------------------
#THEME_DIR="/home/edvinest/.config/themes"
#WAYBAR_CONFIG="/home/edvinest/.config/waybar/style.css"
#WOFI_CONFIG="/home/edvinest/.config/wofi/style.css"
#SWAYFX_THEME="/home/edvinest/.config/sway/config.d/theme.conf"

# -------------------------
# Wallpaper paths
# -------------------------
WALL_DIR="$HOME/Documents/CurrentWPPool"

# -------------------------
# Wallpaper selection
# -------------------------
wallpapers=()
declare -A wallpaper_map  # map clean name -> full path

for f in "$WALL_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
    [[ -f "$f" ]] || continue
    filename=$(basename "$f")
    name_no_ext="${filename%.*}"            # strip extension
    display_name="${name_no_ext//_/ }"      # replace underscores with spaces
    wallpapers+=("$display_name")
    wallpaper_map["$display_name"]="$f"     # store full path
done

# Exit if no wallpapers found
[[ ${#wallpapers[@]} -eq 0 ]] && notify-send "No wallpapers found" && exit 1

# Show the list in Wofi
chosen_wall=$(printf "%s\n" "${wallpapers[@]}" | wofi --dmenu --prompt "Select Wallpaper:" --cache-file /dev/null)
[[ -z "$chosen_wall" ]] && exit 0

# Get the actual file path from the map
full_path="${wallpaper_map["$chosen_wall"]}"

if [[ -n "$full_path" ]]; then
    # Apply wallpaper + generate colors with wal
    wal -i "$full_path"
    sleep 0.3

    ~/.config/myScripts/update_foot_colors.sh

    notify-send "Wallpaper changed" "Applied $chosen_wall"
else
    notify-send "Error" "Could not find wallpaper file for: $chosen_wall"
fi

# -------------------------
# Reload Waybar/SwayFX
# -------------------------
swaymsg reload
pkill waybar
waybar &
