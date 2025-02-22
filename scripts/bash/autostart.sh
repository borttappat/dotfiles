#!/run/current-system/sw/bin/bash

# Get the hostname from hostnamectl's "Icon name" field
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

# Check if hostname contains "vm" (case-insensitive)
if [[ ! $hostname =~ [vV][mM] ]]; then
    # If hostname doesn't contain "vm", run picom
    killall -q picom
    while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
    picom -b
fi

# Function to get the primary display resolution
get_primary_resolution() {
    xrandr | grep primary | grep -oP '\d+x\d+' | head -n1
}

# Get current resolution
RESOLUTION=$(get_primary_resolution)

# Kill any existing polybar instances
killall -q polybar

# Wait for them to terminate
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar based on resolution
case $RESOLUTION in
    "2880x1800")
        polybar -q hidpi &
        ;;
    "1920x1080")
        polybar -q main &
        ;;
    "3840x2160")
        polybar -q 4k &
        ;;
    *)
        polybar -q main &  # Default to main bar
        ;;
esac

echo "Autostart completed... Resolution: $RESOLUTION"
