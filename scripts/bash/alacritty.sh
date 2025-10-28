#!/run/current-system/sw/bin/bash

CONFIG_FILE="$HOME/.config/display-config.json"
TEMPLATE_FILE="$HOME/.config/alacritty/alacritty.toml.template"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Get cursor position
eval $(xdotool getmouselocation --shell)

# Get display resolution for cursor position (not primary display)
CURRENT_RESOLUTION=$(xrandr --listmonitors | awk -v x="$X" -v y="$Y" '
$1 ~ /^[0-9]+:/ {
    split($3, pos, /[x+]/)
    split(pos[1], w, /\//)
    split(pos[2], h, /\//)
    if (x >= pos[3] && x < pos[3] + w[1] && y >= pos[4] && y < pos[4] + h[1]) {
        print w[1] "x" h[1]
    }
}')

echo "Cursor display: $CURRENT_RESOLUTION"

HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

# Check machine overrides first (same logic as load-display-config.sh)
MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")
if [ "$MACHINE_OVERRIDE" != "null" ]; then
    FORCED_RES=$(echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
    if [ "$FORCED_RES" != "null" ]; then
        CURRENT_RESOLUTION="$FORCED_RES"
    fi
    
    ALACRITTY_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size // null")
    ALACRITTY_SCALE_FACTOR=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_scale_factor // null")
else
    ALACRITTY_FONT_SIZE="null"
    ALACRITTY_SCALE_FACTOR="null"
fi

# Fall back to resolution defaults if needed
RES_DEFAULTS=$(jq -r ".resolution_defaults[\"$CURRENT_RESOLUTION\"] // null" "$CONFIG_FILE")
if [ "$RES_DEFAULTS" = "null" ]; then
    echo "No defaults found for resolution: $CURRENT_RESOLUTION, using 1920x1080 defaults"
    RES_DEFAULTS=$(jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
fi

[ "$ALACRITTY_FONT_SIZE" = "null" ] && ALACRITTY_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.alacritty_font_size')
[ "$ALACRITTY_SCALE_FACTOR" = "null" ] && ALACRITTY_SCALE_FACTOR="1.0"

# Build the scale factor line - if it's 1.0, leave it blank, otherwise include it
if [ "$ALACRITTY_SCALE_FACTOR" != "1.0" ]; then
    ALACRITTY_SCALE_FACTOR_LINE="WINIT_X11_SCALE_FACTOR = \"$ALACRITTY_SCALE_FACTOR\""
else
    ALACRITTY_SCALE_FACTOR_LINE=""
fi

echo "Using font size: $ALACRITTY_FONT_SIZE"
echo "Using scale factor: $ALACRITTY_SCALE_FACTOR"

# Generate temporary config from template using sed
TEMP_CONFIG="/tmp/alacritty-$$.toml"

sed -e "s/\${ALACRITTY_FONT_SIZE}/$ALACRITTY_FONT_SIZE/g" \
    -e "s/\${ALACRITTY_SCALE_FACTOR_LINE}/$ALACRITTY_SCALE_FACTOR_LINE/g" \
    "$TEMPLATE_FILE" > "$TEMP_CONFIG"

# Launch alacritty with generated config
alacritty --config-file "$TEMP_CONFIG" "$@" &

# Clean up temp config after a delay
#sleep 1 && rm -f "$TEMP_CONFIG" &
