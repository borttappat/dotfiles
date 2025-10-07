#!/run/current-system/sw/bin/bash

eval $(xdotool getmouselocation --shell)

CURRENT_DISPLAY=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
split($3, pos, /[x+]/)
split(pos[1], w, /\//)
split(pos[2], h, /\//)
if (x >= pos[3] && x < pos[3] + w[1] && y >= pos[4] && y < pos[4] + h[1]) {
gsub(/\/[0-9]+/, "", $3)
print $3
}
}' | grep -oP '[0-9]{3,5}x[0-9]{3,5}' | head -n1)

echo "Current display: $CURRENT_DISPLAY"

CONFIG_FILE="$HOME/.config/display-config.json"
HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if [ "$MACHINE_OVERRIDE" != "null" ]; then
FORCED_RES=$(echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
if [ "$FORCED_RES" != "null" ]; then
CURRENT_DISPLAY="$FORCED_RES"
fi

ALACRITTY_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size // null")
ALACRITTY_SCALE_FACTOR=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_scale_factor // null")
else
ALACRITTY_FONT_SIZE="null"
ALACRITTY_SCALE_FACTOR="null"
fi

RES_DEFAULTS=$(jq -r ".resolution_defaults[\"$CURRENT_DISPLAY\"] // null" "$CONFIG_FILE")

if [ "$RES_DEFAULTS" = "null" ]; then
echo "No defaults found for resolution: $CURRENT_DISPLAY, using 1920x1080 defaults"
RES_DEFAULTS=$(jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
fi

[ "$ALACRITTY_FONT_SIZE" = "null" ] && ALACRITTY_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.alacritty_font_size')

if [ "$ALACRITTY_SCALE_FACTOR" != "null" ] && [ -n "$ALACRITTY_SCALE_FACTOR" ]; then
ALACRITTY_SCALE_FACTOR_LINE="WINIT_X11_SCALE_FACTOR = \"$ALACRITTY_SCALE_FACTOR\""
echo "Using font size: $ALACRITTY_FONT_SIZE with scale factor: $ALACRITTY_SCALE_FACTOR for display $CURRENT_DISPLAY"
else
ALACRITTY_SCALE_FACTOR_LINE=""
echo "Using font size: $ALACRITTY_FONT_SIZE for display $CURRENT_DISPLAY"
fi

sed -e "s/\${ALACRITTY_FONT_SIZE}/$ALACRITTY_FONT_SIZE/g" \
    -e "s/\${ALACRITTY_SCALE_FACTOR_LINE}/$ALACRITTY_SCALE_FACTOR_LINE/g" \
    ~/.config/alacritty/alacritty.toml.template > ~/.config/alacritty/alacritty.toml

exec alacritty "$@"
