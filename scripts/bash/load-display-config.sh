#!/usr/bin/env bash

CONFIG_FILE="$HOME/dotfiles/configs/display-config.json"
HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

if [ ! -f "$CONFIG_FILE" ]; then
echo "Config file not found: $CONFIG_FILE"
exit 1
fi

CURRENT_RESOLUTION=$(xrandr --listmonitors | awk '/\+\*/ {gsub(/\/[0-9]+/, "", $3); print $3}' | grep -oP '[0-9]{3,5}x[0-9]{3,5}' | head -n1)

MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if [ "$MACHINE_OVERRIDE" != "null" ]; then
FORCED_RES=$(echo "$MACHINE_OVERRIDE" | jq -r '.force_resolution // "null"')
FORCED_DPI=$(echo "$MACHINE_OVERRIDE" | jq -r '.dpi // "null"')
FORCED_GDK_SCALE=$(echo "$MACHINE_OVERRIDE" | jq -r '.gdk_scale // "null"')

# Check for external monitors
EXTERNAL_MONITOR_PATTERNS=$(echo "$MACHINE_OVERRIDE" | jq -r '.external_monitor_resolutions // [] | join("|")')
EXTERNAL_MONITOR=0
if [ -n "$EXTERNAL_MONITOR_PATTERNS" ] && xrandr --listmonitors | grep -qE "(${EXTERNAL_MONITOR_PATTERNS}/)"; then
    EXTERNAL_MONITOR=1
fi

if [ "$FORCED_RES" != "null" ]; then
CURRENT_RESOLUTION="$FORCED_RES"
# Apply the forced resolution
INTERNAL_DISPLAY=$(xrandr | grep "eDP" | cut -d' ' -f1 | head -n1)
if [ -n "$INTERNAL_DISPLAY" ]; then
if [ "$FORCED_DPI" != "null" ]; then
xrandr --output "$INTERNAL_DISPLAY" --mode "$FORCED_RES" --dpi "$FORCED_DPI" 2>/dev/null || echo "Warning: Could not set resolution to $FORCED_RES"
else
xrandr --output "$INTERNAL_DISPLAY" --mode "$FORCED_RES" 2>/dev/null || echo "Warning: Could not set resolution to $FORCED_RES"
fi
fi
fi

# Apply DPI scaling for HiDPI displays
if [ "$FORCED_DPI" != "null" ]; then
echo "Xft.dpi: $FORCED_DPI" | xrdb -merge
fi

# Apply GTK/Qt scaling
if [ "$FORCED_GDK_SCALE" != "null" ]; then
export GDK_SCALE="$FORCED_GDK_SCALE"
export QT_AUTO_SCREEN_SCALE_FACTOR=1
fi

# Use external monitor settings if external monitor is detected
if [ "$EXTERNAL_MONITOR" -eq 1 ]; then
export POLYBAR_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_font_size_external // .polybar_font_size // null")
export POLYBAR_HEIGHT=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_height_external // .polybar_height // null")
export POLYBAR_LINE_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_line_size_external // .polybar_line_size // null")
export ALACRITTY_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size_external // .alacritty_font_size // null")
export I3_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_font_size_external // .i3_font_size // null")
# Export both internal and external border/gap values for per-workspace configuration
export I3_BORDER_THICKNESS=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness // null")
export I3_BORDER_THICKNESS_EXTERNAL=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness_external // .i3_border_thickness // null")
export GAPS_INNER=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // null")
export GAPS_INNER_EXTERNAL=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner_external // .gaps_inner // null")
export ROFI_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".rofi_font_size_external // .rofi_font_size // null")
export ALACRITTY_SCALE_FACTOR=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_scale_factor_external // .alacritty_scale_factor // null")
else
export POLYBAR_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_font_size // null")
export POLYBAR_HEIGHT=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_height // null")
export POLYBAR_LINE_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".polybar_line_size // null")
export ALACRITTY_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_font_size // null")
export I3_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_font_size // null")
export I3_BORDER_THICKNESS=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness // null")
export I3_BORDER_THICKNESS_EXTERNAL=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness // null")
export GAPS_INNER=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // null")
export GAPS_INNER_EXTERNAL=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // null")
export ROFI_FONT_SIZE=$(echo "$MACHINE_OVERRIDE" | jq -r ".rofi_font_size // null")
export ALACRITTY_SCALE_FACTOR=$(echo "$MACHINE_OVERRIDE" | jq -r ".alacritty_scale_factor // null")
fi
else
export POLYBAR_FONT_SIZE="null"
export POLYBAR_HEIGHT="null"
export POLYBAR_LINE_SIZE="null"
export ALACRITTY_FONT_SIZE="null"
export I3_FONT_SIZE="null"
export I3_BORDER_THICKNESS="null"
export I3_BORDER_THICKNESS_EXTERNAL="null"
export GAPS_INNER="null"
export GAPS_INNER_EXTERNAL="null"
export ROFI_FONT_SIZE="null"
export ALACRITTY_SCALE_FACTOR="null"
fi

RES_DEFAULTS=$(jq -r ".resolution_defaults[\"$CURRENT_RESOLUTION\"] // null" "$CONFIG_FILE")

if [ "$RES_DEFAULTS" = "null" ]; then
echo "No defaults found for resolution: $CURRENT_RESOLUTION, using 1920x1080 defaults"
RES_DEFAULTS=$(jq -r '.resolution_defaults["1920x1080"]' "$CONFIG_FILE")
fi

[ "$POLYBAR_FONT_SIZE" = "null" ] && export POLYBAR_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.polybar_font_size')
[ "$POLYBAR_HEIGHT" = "null" ] && export POLYBAR_HEIGHT=$(echo "$RES_DEFAULTS" | jq -r '.polybar_height')
[ "$POLYBAR_LINE_SIZE" = "null" ] && export POLYBAR_LINE_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.polybar_line_size')
[ "$ALACRITTY_FONT_SIZE" = "null" ] && export ALACRITTY_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.alacritty_font_size')
[ "$I3_FONT_SIZE" = "null" ] && export I3_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.i3_font_size')
[ "$I3_BORDER_THICKNESS" = "null" ] && export I3_BORDER_THICKNESS=$(echo "$RES_DEFAULTS" | jq -r '.i3_border_thickness')
[ "$I3_BORDER_THICKNESS_EXTERNAL" = "null" ] && export I3_BORDER_THICKNESS_EXTERNAL=$(echo "$RES_DEFAULTS" | jq -r '.i3_border_thickness')
[ "$GAPS_INNER" = "null" ] && export GAPS_INNER=$(echo "$RES_DEFAULTS" | jq -r '.gaps_inner')
[ "$GAPS_INNER_EXTERNAL" = "null" ] && export GAPS_INNER_EXTERNAL=$(echo "$RES_DEFAULTS" | jq -r '.gaps_inner')
[ "$ROFI_FONT_SIZE" = "null" ] && export ROFI_FONT_SIZE=$(echo "$RES_DEFAULTS" | jq -r '.rofi_font_size')

export DISPLAY_RESOLUTION="$CURRENT_RESOLUTION"
export DISPLAY_FONTS=$(jq -r '.fonts | join(",")' "$CONFIG_FILE")
export POLYBAR_FONT=$(jq -r '.fonts[0]' "$CONFIG_FILE")
export ALACRITTY_FONT=$(jq -r '.fonts[0]' "$CONFIG_FILE")

# Generate the WINIT_X11_SCALE_FACTOR line for alacritty if scale factor is set
if [ "$ALACRITTY_SCALE_FACTOR" != "null" ] && [ "$ALACRITTY_SCALE_FACTOR" != "1" ]; then
export ALACRITTY_SCALE_FACTOR_LINE="WINIT_X11_SCALE_FACTOR = \"$ALACRITTY_SCALE_FACTOR\""
else
export ALACRITTY_SCALE_FACTOR_LINE=""
fi

echo "Loaded config for $HOSTNAME @ $DISPLAY_RESOLUTION: polybar=$POLYBAR_FONT_SIZE alacritty=$ALACRITTY_FONT_SIZE (scale=$ALACRITTY_SCALE_FACTOR) i3=$I3_FONT_SIZE gaps=$GAPS_INNER font=$POLYBAR_FONT external=$EXTERNAL_MONITOR"
