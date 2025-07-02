#!/run/current-system/sw/bin/bash

eval $(xdotool getmouselocation --shell)

CURRENT_DISPLAY=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
    split($3, pos, /[x+]/)
    split(pos[1], w, /\//)
    split(pos[2], h, /\//)
    if (x >= pos[3] && x < pos[3] + w[1] && y >= pos[4] && y < pos[4] + h[1]) {
        print w[1] "x" h[1]
        exit
    }
}')

MONITOR_NAME=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
    split($3, pos, /[x+]/)
    split(pos[1], w, /\//)
    split(pos[2], h, /\//)
    if (x >= pos[3] && x < pos[3] + w[1] && y >= pos[4] && y < pos[4] + h[1]) {
        print $4
        exit
    }
}')

echo "Display: $CURRENT_DISPLAY on monitor: $MONITOR_NAME"

if echo "$CURRENT_DISPLAY" | grep -q "2880x1800"; then
    CONFIG="~/dotfiles/rofi/config1800p.rasi"
elif echo "$CURRENT_DISPLAY" | grep -q "2560x1440"; then
    CONFIG="~/dotfiles/rofi/config4k.rasi"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1080"; then
    CONFIG="~/dotfiles/rofi/config1080p.rasi"
elif echo "$CURRENT_DISPLAY" | grep -q "2288x1436"; then
    CONFIG="~/dotfiles/rofi/config3k.rasi"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1200"; then
    CONFIG="~/dotfiles/rofi/config1200p.rasi"
else
    CONFIG="~/dotfiles/rofi/config.rasi"
fi

rofi "$@" -config "$CONFIG" -m "$MONITOR_NAME"
