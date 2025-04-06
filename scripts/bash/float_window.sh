#!/usr/bin/env bash

# File to store the current window count and position
state_file="/tmp/i3_float_state"

# Initial position (upper left corner with some margin)
init_x=50
init_y=50

# Offset for each new window
x_offset=75
y_offset=75

# Maximum number of windows before resetting position
max_windows=5

# Function to get the primary display resolution
get_primary_resolution() {
    xrandr | grep primary | grep -oP '\d+x\d+' | head -n1
}

# Get the primary display resolution
RESOLUTION=$(get_primary_resolution)

# Read the current state if the file exists
if [ -f "$state_file" ]; then
    read window_count current_x current_y < "$state_file"
else
    window_count=0
    current_x=$init_x
    current_y=$init_y
fi

# Check if there are any floating windows on the current workspace
floating_windows=$(i3-msg -t get_tree | jq '.. | select(.type?) | select(.type=="workspace" and .focused==true) | ..  | select(.type?=="floating_con") | .nodes | length')

if [ "$floating_windows" -eq 0 ]; then
    # Reset position if no floating windows
    window_count=0
    current_x=$init_x
    current_y=$init_y
else
    # Increment window count and adjust position
    window_count=$((window_count + 1))
    if [ $window_count -gt $max_windows ]; then
        window_count=1
        current_x=$init_x
        current_y=$init_y
    else
        current_x=$((current_x + x_offset))
        current_y=$((current_y + y_offset))
    fi
fi

# Save the new state
echo "$window_count $current_x $current_y" > "$state_file"

# Determine which configuration to use based on resolution and cursor position
if [ "$RESOLUTION" = "1920x1080" ]; then
    # 1080p display
    config_file="$HOME/dotfiles/alacritty/alacritty1080p.toml"
elif [ "$RESOLUTION" = "2288x1436" ]; then
    # 3k display
    config_file="$HOME/dotfiles/alacritty/alacritty3k.toml"
elif [ "$RESOLUTION" = "3840x2160" ] || [ $current_x -ge 1920 ]; then
    # 4K display or position is on the 4K display
    config_file="$HOME/dotfiles/alacritty/alacritty4k.toml"
else
    # Default (likely internal display)
    config_file="$HOME/dotfiles/alacritty/alacritty.toml"
fi

# Launch Alacritty at the new position with the appropriate configuration
alacritty --class floating -o window.position.x=$current_x -o window.position.y=$current_y --config-file "$config_file"
