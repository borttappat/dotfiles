#!/run/current-system/sw/bin/bash

get_display_resolutions() {
    xrandr | grep " connected" | grep -oP '\d+x\d+'
}

RESOLUTIONS=$(get_display_resolutions)

if echo "$RESOLUTIONS" | grep -q "2880x1800"; then
    CONFIG="~/dotfiles/rofi/config1800p.rasi"
elif echo "$RESOLUTIONS" | grep -q "2560x1440"; then
    CONFIG="~/.dotfiles/rofi/config4k.rasi"
elif echo "$RESOLUTIONS" | grep -q "1920x1080"; then
    CONFIG="~/dotfiles/rofi/config1080p.rasi"
elif echo "$RESOLUTIONS" | grep -q "2288x1436"; then
    CONFIG="~/dotfiles/rofi/config3k.rasi"
else
    CONFIG="~/dotfiles/rofi/config.rasi"
fi

rofi -show "$1" -config "$CONFIG"
