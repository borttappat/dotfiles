#!/run/current-system/sw/bin/bash

# Function to get the primary display resolution
get_primary_resolution() {
    xrandr | grep primary | grep -oP '\d+x\d+' | head -n1
}

# Get the primary display resolution
RESOLUTION=$(get_primary_resolution)

# Get the position of the mouse cursor
eval $(xdotool getmouselocation --shell)

# Determine which configuration to use based on resolution and cursor position
if [ "$RESOLUTION" = "1920x1080" ]; then
    # 1080p display
    alacritty --config-file ~/.config/alacritty/alacritty1080p.toml
elif [ "$RESOLUTION" = "3840x2160" ] || [ $X -ge 1920 ]; then
    # 4K display or mouse is on the 4K display (DP-4)
    alacritty --config-file ~/.config/alacritty/alacritty4k.toml
else
    # Default (likely internal display)
    alacritty --config-file ~/.config/alacritty/alacritty.toml
fi
