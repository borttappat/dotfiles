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

# Launch polybar on each connected monitor
MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)
echo "$(date): Launching polybar on: $MONITORS" >> "$LOGFILE"

for monitor in $MONITORS; do
    MONITOR=$monitor polybar -q main &
done

echo "$(date): Polybar restart complete" >> "$LOGFILE"
