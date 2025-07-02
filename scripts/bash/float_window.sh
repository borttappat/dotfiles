#!/usr/bin/env bash

state_file="/tmp/i3_float_state"

init_x=50
init_y=50
x_offset=75
y_offset=75
max_windows=5

eval $(xdotool getmouselocation --shell)

CURRENT_DISPLAY=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
    split($3, pos, /[x+]/)
    split(pos[1], w, /\//)
    split(pos[2], h, /\//)
    width = w[1]
    height = h[1]
    offset_x = pos[3]
    offset_y = pos[4]
    
    if (x >= offset_x && x < offset_x + width && y >= offset_y && y < offset_y + height) {
        print width "x" height "+" offset_x "+" offset_y
    }
}')

echo "Cursor at: $X,$Y on display: $CURRENT_DISPLAY"

DISPLAY_INFO=$(echo "$CURRENT_DISPLAY" | sed 's/x/ /' | sed 's/+/ /g')
read DISPLAY_WIDTH DISPLAY_HEIGHT DISPLAY_OFFSET_X DISPLAY_OFFSET_Y <<< "$DISPLAY_INFO"

if [ -f "$state_file" ]; then
    read window_count current_x current_y < "$state_file"
else
    window_count=0
    current_x=$init_x
    current_y=$init_y
fi

floating_windows=$(i3-msg -t get_tree | jq '.. | select(.type?) | select(.type=="workspace" and .focused==true) | ..  | select(.type?=="floating_con") | .nodes | length')

if [ "$floating_windows" -eq 0 ]; then
    window_count=0
    current_x=$((DISPLAY_OFFSET_X + init_x))
    current_y=$((DISPLAY_OFFSET_Y + init_y))
else
    window_count=$((window_count + 1))
    if [ $window_count -gt $max_windows ]; then
        window_count=1
        current_x=$((DISPLAY_OFFSET_X + init_x))
        current_y=$((DISPLAY_OFFSET_Y + init_y))
    else
        current_x=$((current_x + x_offset))
        current_y=$((current_y + y_offset))
    fi
fi

echo "$window_count $current_x $current_y" > "$state_file"

if echo "$CURRENT_DISPLAY" | grep -q "2880x1800"; then
    config_file="$HOME/dotfiles/alacritty/alacritty1800p.toml"
elif echo "$CURRENT_DISPLAY" | grep -q "2560x1440"; then
    config_file="$HOME/dotfiles/alacritty/alacritty1440p.toml"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1080"; then
    config_file="$HOME/dotfiles/alacritty/alacritty1080p.toml"
elif echo "$CURRENT_DISPLAY" | grep -q "2288x1436"; then
    config_file="$HOME/dotfiles/alacritty/alacritty3k.toml"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1200"; then
    config_file="$HOME/dotfiles/alacritty/alacritty1200p.toml"
else
    config_file="$HOME/dotfiles/alacritty/alacritty.toml"
fi

echo "Using config: $config_file at position: $current_x,$current_y"

alacritty --class floating -o window.position.x=$current_x -o window.position.y=$current_y --config-file "$config_file"
