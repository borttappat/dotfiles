#!/usr/bin/env bash

LOGFILE="/tmp/monitor-hotplug.log"
LOCKFILE="/tmp/monitor-hotplug.lock"

echo "$(date): Monitor change" >> "$LOGFILE"

# Debounce
if [ -f "$LOCKFILE" ]; then
    LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)))
    if [ $LOCK_AGE -lt 3 ]; then
        echo "$(date): Debouncing" >> "$LOGFILE"
        exit 0
    fi
fi
touch "$LOCKFILE"

sleep 1

# Set environment to talk to traum's X session
export DISPLAY=:0
export XAUTHORITY="/home/traum/.Xauthority"
export HOME="/home/traum"

# Get displays
INTERNAL=$(xrandr | grep "eDP" | grep " connected" | cut -d' ' -f1)
EXTERNAL=$(xrandr | grep " connected" | grep -v "eDP" | cut -d' ' -f1)

echo "$(date): Internal=$INTERNAL External=$EXTERNAL" >> "$LOGFILE"

# Configure xrandr
if [ -n "$EXTERNAL" ]; then
    echo "$(date): Configuring external monitor $EXTERNAL above $INTERNAL" >> "$LOGFILE"
    xrandr --output $INTERNAL --mode 2880x1800 --primary --output $EXTERNAL --auto --above $INTERNAL >> "$LOGFILE" 2>&1
else
    echo "$(date): No external monitor, using only $INTERNAL" >> "$LOGFILE"
    xrandr --output $INTERNAL --mode 2880x1800 --primary >> "$LOGFILE" 2>&1
fi

echo "$(date): Triggering polybar restart via i3" >> "$LOGFILE"

# Restart polybar via i3-msg
i3-msg exec /home/traum/dotfiles/scripts/bash/polybar-restart.sh >> "$LOGFILE" 2>&1

echo "$(date): Done" >> "$LOGFILE"
