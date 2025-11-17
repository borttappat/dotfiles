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

CONFIG_FILE="$HOME/.config/display-config.json"
HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if [ "$MACHINE_OVERRIDE" != "null" ]; then
FORCED_RES=$(echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
if [ "$FORCED_RES" != "null" ]; then
CURRENT_DISPLAY="$FORCED_RES"
fi

ROFI_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".rofi_font_size // null")
else
ROFI_FONT_SIZE="null"
fi

RES_DEFAULTS=$(jq -r ".resolution_defaults[\"$CURRENT_DISPLAY\"] // null" "$CONFIG_FILE")

if [ "$RES_DEFAULTS" = "null" ]; then
echo "No defaults found for resolution: $CURRENT_DISPLAY, using 1920x1080 defaults"
RES_DEFAULTS=$(jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
fi

[ "$ROFI_FONT_SIZE" = "null" ] && ROFI_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.rofi_font_size')

ROFI_FONT=$(jq -r '.fonts[0]' "$CONFIG_FILE")

echo "Using rofi font: $ROFI_FONT size: $ROFI_FONT_SIZE for display $CURRENT_DISPLAY"

sed -e "s/\${ROFI_FONT}/$ROFI_FONT/g" \
    -e "s/\${ROFI_FONT_SIZE}/$ROFI_FONT_SIZE/g" \
    ~/.config/rofi/config.rasi.template > ~/.config/rofi/config.rasi

rofi "$@" -config ~/.config/rofi/config.rasi -m "$MONITOR_NAME"
