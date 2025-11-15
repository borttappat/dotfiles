#!/run/current-system/sw/bin/bash

LOCKFILE="/tmp/polybar-restart.lock"
LOGFILE="/tmp/polybar-restart.log"

echo "$(date): Polybar restart called" >> "$LOGFILE"

# Check if already running (with proper locking)
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo "$(date): Already running, exiting" >> "$LOGFILE"
    exit 0
fi

# Ensure lockfile is removed on exit
trap "rmdir '$LOCKFILE' 2>/dev/null" EXIT

echo "$(date): Killing existing polybar instances" >> "$LOGFILE"
killall -q polybar 2>/dev/null

# Wait for them to die (max 2 seconds)
for i in {1..20}; do
    pgrep -u $UID -x polybar >/dev/null || break
    sleep 0.1
done

# Small delay to ensure clean state
sleep 0.2

# Load display config to get font settings
source ~/.config/scripts/load-display-config.sh

# Launch polybar on each connected monitor
MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)
echo "$(date): Launching polybar on: $MONITORS" >> "$LOGFILE"

HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

for monitor in $MONITORS; do
    # Get monitor resolution
    MONITOR_RES=$(xrandr --query | grep "^${monitor} connected" | grep -oP '\d{3,5}x\d{3,5}' | head -n1)
    echo "$(date): Monitor $monitor resolution: $MONITOR_RES" >> "$LOGFILE"

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

    echo "$(date): Monitor $monitor using: font=$MONITOR_POLYBAR_FONT_SIZE height=$MONITOR_POLYBAR_HEIGHT line=$MONITOR_POLYBAR_LINE_SIZE" >> "$LOGFILE"

    # Generate monitor-specific config
    MONITOR_CONFIG="/tmp/polybar-${monitor}.ini"
    sed -e "s/\${POLYBAR_FONT_SIZE}/$MONITOR_POLYBAR_FONT_SIZE/g" \
        -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
        -e "s/\${POLYBAR_HEIGHT}/$MONITOR_POLYBAR_HEIGHT/g" \
        -e "s/\${POLYBAR_LINE_SIZE}/$MONITOR_POLYBAR_LINE_SIZE/g" \
        ~/.config/polybar/config.ini.template > "$MONITOR_CONFIG"

    # Launch polybar on this monitor with its config
    echo "$(date): Launching polybar on $monitor with config $MONITOR_CONFIG" >> "$LOGFILE"
    MONITOR=$monitor polybar -q --config="$MONITOR_CONFIG" main &
done

echo "$(date): Polybar restart complete" >> "$LOGFILE"
