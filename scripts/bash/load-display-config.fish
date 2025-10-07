#!/usr/bin/env fish

set CONFIG_FILE "$HOME/.config/display-config.json"
set HOSTNAME (hostnamectl hostname | cut -d'-' -f1)

if not test -f "$CONFIG_FILE"
echo "Config file not found: $CONFIG_FILE"
exit 1
end

set CURRENT_RESOLUTION (xrandr --listmonitors | awk '/\+\*/ {gsub(/\/[0-9]+/, "", $3); print $3}' | grep -oP '[0-9]{3,5}x[0-9]{3,5}' | head -n1)

set MACHINE_OVERRIDE (jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if test "$MACHINE_OVERRIDE" != "null"
set FORCED_RES (echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
if test "$FORCED_RES" != "null"
set CURRENT_RESOLUTION "$FORCED_RES"
end

set -gx POLYBAR_FONT_SIZE (echo "$MACHINE_OVERRIDE" | jq -r ".polybar_font_size // null")
set -gx ALACRITTY_FONT_SIZE (echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size // null")
set -gx I3_FONT_SIZE (echo "$MACHINE_OVERRIDE" | jq -r ".i3_font_size // null")
set -gx GAPS_INNER (echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // null")
set -gx ROFI_FONT_SIZE (echo "$MACHINE_OVERRIDE" | jq -r ".rofi_font_size // null")
else
set -gx POLYBAR_FONT_SIZE "null"
set -gx ALACRITTY_FONT_SIZE "null"
set -gx I3_FONT_SIZE "null"
set -gx GAPS_INNER "null"
set -gx ROFI_FONT_SIZE "null"
end

set RES_DEFAULTS (jq -r ".resolution_defaults[\"$CURRENT_RESOLUTION\"] // null" "$CONFIG_FILE")

if test "$RES_DEFAULTS" = "null"
echo "No defaults found for resolution: $CURRENT_RESOLUTION, using 1920x1080 defaults"
set RES_DEFAULTS (jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
end

test "$POLYBAR_FONT_SIZE" = "null"; and set -gx POLYBAR_FONT_SIZE (echo "$RES_DEFAULTS" | jq -r '.polybar_font_size')
test "$ALACRITTY_FONT_SIZE" = "null"; and set -gx ALACRITTY_FONT_SIZE (echo "$RES_DEFAULTS" | jq -r '.alacritty_font_size')
test "$I3_FONT_SIZE" = "null"; and set -gx I3_FONT_SIZE (echo "$RES_DEFAULTS" | jq -r '.i3_font_size')
test "$GAPS_INNER" = "null"; and set -gx GAPS_INNER (echo "$RES_DEFAULTS" | jq -r '.gaps_inner')
test "$ROFI_FONT_SIZE" = "null"; and set -gx ROFI_FONT_SIZE (echo "$RES_DEFAULTS" | jq -r '.rofi_font_size')

set -gx DISPLAY_RESOLUTION "$CURRENT_RESOLUTION"
set -gx DISPLAY_FONTS (jq -r '.fonts | join(",")' "$CONFIG_FILE")

echo "Loaded config for $HOSTNAME @ $DISPLAY_RESOLUTION: polybar=$POLYBAR_FONT_SIZE alacritty=$ALACRITTY_FONT_SIZE i3=$I3_FONT_SIZE gaps=$GAPS_INNER"
