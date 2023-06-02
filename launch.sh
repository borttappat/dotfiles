#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q polybar

# Generate colors from Xresources
# xrdb -merge ~/.cache/wal/colors.Xresources

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

MONITORS=$MONITORS polybar main

echo "Bars launched..."
