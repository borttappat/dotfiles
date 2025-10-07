#!/run/current-system/sw/bin/bash

unclutter -grab &
wal -Rn &

# Cleanup old serverauth files (2+ days old)
find "$HOME" -maxdepth 1 -name ".serverauth.*" -type f -mtime +2 -delete 2>/dev/null

# VM Detection
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ $hostname =~ [vV][mM] ]]; then
echo "VM detected, configuring VM environment..."

# Start spice-vdagent for VM clipboard/display
spice-vdagent -x &

# Find VM display and set resolution
VM_DISPLAY=$(xrandr | grep -E "(Virtual-1|qxl-0)" | grep " connected" | cut -d' ' -f1 | head -n1)
if [ -n "$VM_DISPLAY" ]; then
echo "Found VM display: $VM_DISPLAY"
if xrandr --output "$VM_DISPLAY" --mode 1920x1200 2>/dev/null; then
echo "Set $VM_DISPLAY to 1920x1200"
else
echo "Could not set 1920x1200, using current resolution"
fi
fi

# Use Alt key for VMs
export MOD_KEY="Mod1"
else
# Physical machine - use Super key
export MOD_KEY="Mod4"

# Handle internal display resolution for zenbook
INTERNAL_DISPLAY=$(xrandr | grep "eDP" | cut -d' ' -f1 | head -n1)
if [ -n "$INTERNAL_DISPLAY" ]; then
NATIVE_RES=$(xrandr | grep "$INTERNAL_DISPLAY" | grep -oP '\d+x\d+' | head -n1)
if [ "$NATIVE_RES" = "2880x1800" ]; then
xrandr --output "$INTERNAL_DISPLAY" --mode 1920x1200
echo "Set internal display to 1920x1200 for font clarity"
fi
fi
fi

sleep 0.5

# Load display configuration
source ~/.config/scripts/load-display-config.sh

# Generate i3 config from template
envsubst < ~/.config/i3/config.template > ~/.config/i3/config

exec i3
