#!/run/current-system/sw/bin/bash

AUTOSTART_LOG="/tmp/autostart.log"
echo "$(date): ========== Autostart.sh invoked ==========" >> "$AUTOSTART_LOG"

# Ensure dunst uses wal colors
mkdir -p ~/.config/dunst
ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

# Notify user that display configuration is starting
notify-send "Display Setup" "Configuring monitors..." -t 2000

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ ! $hostname =~ [vV][mM] ]]; then
killall -q picom
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
picom -b
fi

# Configure external monitors (DP and HDMI)
# Give displays a moment to stabilize
sleep 0.5

INTERNAL_DISPLAY=$(xrandr --query | grep "eDP" | grep " connected" | cut -d' ' -f1)
EXTERNAL_DISPLAYS=$(xrandr --query | grep " connected" | grep -E "(DP-|HDMI-)" | cut -d' ' -f1)

echo "$(date): Internal: $INTERNAL_DISPLAY, External: $EXTERNAL_DISPLAYS" >> /tmp/autostart.log

if [ -n "$INTERNAL_DISPLAY" ] && [ -n "$EXTERNAL_DISPLAYS" ]; then
echo "$(date): Configuring display layout: external monitors above internal" >> /tmp/autostart.log
for external in $EXTERNAL_DISPLAYS; do
xrandr --output "$external" --auto --above "$INTERNAL_DISPLAY"
echo "$(date): Positioned $external above $INTERNAL_DISPLAY" >> /tmp/autostart.log
done

# Restore wallpaper after xrandr changes
sleep 0.5
wal -Rnq
~/.fehbg &
fi

source ~/.config/scripts/load-display-config.sh

AUTOSTART_LOG="/tmp/autostart.log"
echo "$(date): Autostart.sh starting" >> "$AUTOSTART_LOG"

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Get all connected monitors
MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)
echo "$(date): Detected monitors: $MONITORS" >> "$AUTOSTART_LOG"

# Launch polybar on each monitor with appropriate config
for monitor in $MONITORS; do
    # Get monitor resolution
    MONITOR_RES=$(xrandr --query | grep "^${monitor} connected" | grep -oP '\d{3,5}x\d{3,5}' | head -n1)
    echo "$(date): Monitor $monitor resolution: $MONITOR_RES" >> "$AUTOSTART_LOG"

    # Determine settings for this monitor (defaults from load-display-config.sh)
    MONITOR_POLYBAR_FONT_SIZE="$POLYBAR_FONT_SIZE"
    MONITOR_POLYBAR_HEIGHT="$POLYBAR_HEIGHT"
    MONITOR_POLYBAR_LINE_SIZE="$POLYBAR_LINE_SIZE"

    # Check if this monitor is an external monitor (for zen machine)
    if [ "$HOSTNAME" = "zen" ]; then
        EXTERNAL_MONITOR_PATTERNS=$(jq -r ".machine_overrides.zen.external_monitor_resolutions // [] | join(\"|\")" ~/dotfiles/configs/display-config.json)
        if echo "$MONITOR_RES" | grep -qE "^(${EXTERNAL_MONITOR_PATTERNS})x"; then
            # External monitor - use external settings
            MONITOR_POLYBAR_FONT_SIZE=$(jq -r '.machine_overrides.zen.polybar_font_size_external // .machine_overrides.zen.polybar_font_size' ~/dotfiles/configs/display-config.json)
            MONITOR_POLYBAR_HEIGHT=$(jq -r '.machine_overrides.zen.polybar_height_external // .machine_overrides.zen.polybar_height' ~/dotfiles/configs/display-config.json)
            MONITOR_POLYBAR_LINE_SIZE=$(jq -r '.machine_overrides.zen.polybar_line_size_external // .machine_overrides.zen.polybar_line_size' ~/dotfiles/configs/display-config.json)
        else
            # Internal monitor - use standalone settings
            MONITOR_POLYBAR_FONT_SIZE=$(jq -r '.machine_overrides.zen.polybar_font_size' ~/dotfiles/configs/display-config.json)
            MONITOR_POLYBAR_HEIGHT=$(jq -r '.machine_overrides.zen.polybar_height' ~/dotfiles/configs/display-config.json)
            MONITOR_POLYBAR_LINE_SIZE=$(jq -r '.machine_overrides.zen.polybar_line_size' ~/dotfiles/configs/display-config.json)
        fi
    fi

    echo "$(date): Monitor $monitor using: font=$MONITOR_POLYBAR_FONT_SIZE height=$MONITOR_POLYBAR_HEIGHT line=$MONITOR_POLYBAR_LINE_SIZE" >> "$AUTOSTART_LOG"

    # Generate monitor-specific config
    MONITOR_CONFIG="/tmp/polybar-${monitor}.ini"
    sed -e "s/\${POLYBAR_FONT_SIZE}/$MONITOR_POLYBAR_FONT_SIZE/g" \
        -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
        -e "s/\${POLYBAR_HEIGHT}/$MONITOR_POLYBAR_HEIGHT/g" \
        -e "s/\${POLYBAR_LINE_SIZE}/$MONITOR_POLYBAR_LINE_SIZE/g" \
        ~/.config/polybar/config.ini.template > "$MONITOR_CONFIG"

    # Launch polybar on this monitor with its config
    echo "$(date): Launching polybar on $monitor with config $MONITOR_CONFIG" >> "$AUTOSTART_LOG"
    MONITOR=$monitor polybar -q --config="$MONITOR_CONFIG" main >> "$AUTOSTART_LOG" 2>&1 &
done

notify-send "Display Setup" "Configuration complete!" -t 2000

echo "$(date): Autostart completed... Resolution: $DISPLAY_RESOLUTION, Polybar font: $POLYBAR_FONT_SIZE" >> "$AUTOSTART_LOG"
