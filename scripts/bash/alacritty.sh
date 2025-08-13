#!/run/current-system/sw/bin/bash

# Get cursor position
eval $(xdotool getmouselocation --shell)

# Get display info for cursor position  
CURRENT_DISPLAY=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
split($3, pos, /[x+]/)
split(pos[1], w, /\//)
split(pos[2], h, /\//)
if (x >= pos[3] && x < pos[3] + w[1] && y >= pos[4] && y < pos[4] + h[1]) {
print w[1] "x" h[1]
}
}')

echo "Debug: Cursor position: X=$X Y=$Y"
echo "Debug: Detected display: $CURRENT_DISPLAY"
echo "Debug: xrandr --listmonitors output:"
xrandr --listmonitors

# Choose config based on current display resolution
if echo "$CURRENT_DISPLAY" | grep -q "2880x1800"; then
echo "Detected 1800p display - using 1800p config"
alacritty --config-file ~/dotfiles/alacritty/alacritty1800p.toml "$@"
elif echo "$CURRENT_DISPLAY" | grep -q "2560x1440"; then
echo "Detected 1440p display - using 1440p config"
alacritty --config-file ~/dotfiles/alacritty/alacritty1440p.toml "$@"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1080"; then
echo "Detected 1080p display - using 1080p config"
alacritty --config-file ~/dotfiles/alacritty/alacritty1080p.toml "$@"
elif echo "$CURRENT_DISPLAY" | grep -q "2288x1436"; then
echo "Detected 3k display - using 3k config"
alacritty --config-file ~/dotfiles/alacritty/alacritty3k.toml "$@"
elif echo "$CURRENT_DISPLAY" | grep -q "1920x1200"; then
echo "Detected 1200p display - using 1200p config"
alacritty --config-file ~/dotfiles/alacritty/alacritty1200p.toml "$@"
else
echo "No matching resolution found, using default config"
echo "Debug: CURRENT_DISPLAY was: '$CURRENT_DISPLAY'"
    alacritty --config-file ~/dotfiles/alacritty/alacritty.toml "$@"
fi
