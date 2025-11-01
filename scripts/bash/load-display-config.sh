#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/display-config.json"
HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

if [ ! -f "$CONFIG_FILE" ]; then
echo "Config file not found: $CONFIG_FILE"
exit 1
fi

CURRENT_RESOLUTION=$(xrandr --listmonitors | awk '/\+\*/ {gsub(/\/[0-9]+/, "", $3); print $3}' | grep -oP '[0-9]{3,5}x[0-9]{3,5}' | head -n1)

MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if [ "$MACHINE_OVERRIDE" != "null" ]; then
FORCED_RES=$(echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
if [ "$FORCED_RES" != "null" ]; then
CURRENT_RESOLUTION="$FORCED_RES"
fi

export POLYBAR_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_font_size // null")
export ALACRITTY_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size // null")
export I3_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_font_size // null")
export GAPS_INNER=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // null")
export ROFI_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".rofi_font_size // null")
else
export POLYBAR_FONT_SIZE="null"
export ALACRITTY_FONT_SIZE="null"
export I3_FONT_SIZE="null"
export GAPS_INNER="null"
export ROFI_FONT_SIZE="null"
fi

RES_DEFAULTS=$(jq -r ".resolution_defaults[\"$CURRENT_RESOLUTION\"] // null" "$CONFIG_FILE")

if [ "$RES_DEFAULTS" = "null" ]; then
echo "No defaults found for resolution: $CURRENT_RESOLUTION, using 1920x1080 defaults"
RES_DEFAULTS=$(jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
fi

[ "$POLYBAR_FONT_SIZE" = "null" ] && export POLYBAR_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.polybar_font_size')
[ "$ALACRITTY_FONT_SIZE" = "null" ] && export ALACRITTY_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.alacritty_font_size')
[ "$I3_FONT_SIZE" = "null" ] && export I3_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.i3_font_size')
[ "$GAPS_INNER" = "null" ] && export GAPS_INNER=$(echo "$RES_DEFAULTS" | jq -r '.gaps_inner')
[ "$ROFI_FONT_SIZE" = "null" ] && export ROFI_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.rofi_font_size')

export DISPLAY_RESOLUTION="$CURRENT_RESOLUTION"
export DISPLAY_FONTS=$(jq -r '.fonts | join(",")' "$CONFIG_FILE")
export POLYBAR_FONT=$(jq -r '.fonts[0]' "$CONFIG_FILE")
export ALACRITTY_FONT=$(jq -r '.fonts[0]' "$CONFIG_FILE")

echo "Loaded config for $HOSTNAME @ $DISPLAY_RESOLUTION: polybar=$POLYBAR_FONT_SIZE alacritty=$ALACRITTY_FONT_SIZE i3=$I3_FONT_SIZE gaps=$GAPS_INNER font=$POLYBAR_FONT"
