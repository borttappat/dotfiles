#!/run/current-system/sw/bin/bash

# Get the position of the mouse cursor
eval $(xdotool getmouselocation --shell)

# Check which monitor the mouse is on
if [ $X -ge 1920 ]; then
    # Mouse is on the 4K display (DP-4)
    alacritty --config-file ~/.config/alacritty/alacritty4k.toml
else
    # Mouse is on the internal display (eDP-1)
    alacritty --config-file ~/.config/alacritty/alacritty.toml
fi
