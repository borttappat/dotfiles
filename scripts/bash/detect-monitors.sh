#!/run/current-system/sw/bin/bash

# Simple script to detect monitors and restart polybar
# Run this when you plug/unplug a monitor

# Get displays
INTERNAL=$(xrandr | grep "eDP" | grep " connected" | cut -d' ' -f1)
EXTERNAL=$(xrandr | grep " connected" | grep -v "eDP" | cut -d' ' -f1)

# Configure xrandr
if [ -n "$EXTERNAL" ]; then
    xrandr --output $INTERNAL --mode 2880x1800 --primary --output $EXTERNAL --auto --above $INTERNAL
    notify-send "Monitors" "Configured $EXTERNAL above $INTERNAL"
else
    xrandr --output $INTERNAL --mode 2880x1800 --primary
    notify-send "Monitors" "Using only $INTERNAL"
fi

# Move all workspaces to available outputs (fixes workspaces stuck on disconnected monitors)
for workspace in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
    i3-msg "[workspace=$workspace] move workspace to output $INTERNAL"
done

# Refresh wallpaper
wal -R

# Restart polybar
~/dotfiles/scripts/bash/polybar-restart.sh
