#!/run/current-system/sw/bin/bash

# Function to get all connected display resolutions
get_display_resolutions() {
    xrandr | grep " connected" | grep -oP '\d+x\d+'
}

# Get all connected display resolutions
RESOLUTIONS=$(get_display_resolutions)

# Check if 1800p display is connected (2880x1800)
if echo "$RESOLUTIONS" | grep -q "2880x1800"; then
    # 1800p display
    echo "Detected 1800p display - using 1800p config"
    alacritty --config-file ~/dotfiles/alacritty/alacritty1800p.toml
elif echo "$RESOLUTIONS" | grep -q "3840x2160"; then
    # 4K display
    echo "Detected 4K display - using 4K config"
    alacritty --config-file ~/dotfiles/alacritty/alacritty4k.toml
elif echo "$RESOLUTIONS" | grep -q "1920x1080"; then
    # 1080p display
    echo "Detected 1080p display - using 1080p config"
    alacritty --config-file ~/dotfiles/alacritty/alacritty1080p.toml
elif echo "$RESOLUTIONS" | grep -q "3024x1890"; then
    # 3k display
    echo "Detected 3k display - using 3k config"
    alacritty --config-file ~/dotfiles/alacritty/alacritty3k.toml
else
    # Default fallback
    echo "Using default config"
    alacritty --config-file ~/dotfiles/alacritty/alacritty.toml
fi
