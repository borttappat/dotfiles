#!/run/current-system/sw/bin/bash

# Cleanup old serverauth files (2+ days old)
cleanup_old_serverauth() {
    echo "Cleaning up old serverauth files..."
    find "$HOME" -maxdepth 1 -name ".serverauth.*" -type f -mtime +2 -print0 | while IFS= read -r -d '' file; do
        echo "Removing old serverauth file: $(basename "$file")"
        rm -f "$file"
    done
}

# Run cleanup
cleanup_old_serverauth

# VM Detection (same logic as autostart.sh)
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

# If we're in a VM, handle resolution setup for VM displays
if [[ $hostname =~ [vV][mM] ]]; then
echo "VM detected, setting up VM display resolution..."

# Find VM display (Virtual-1 or qxl-0)
VM_DISPLAY=$(xrandr | grep -E "(Virtual-1|qxl-0)" | grep " connected" | cut -d' ' -f1 | head -n1)

if [ -n "$VM_DISPLAY" ]; then
echo "Found VM display: $VM_DISPLAY"
# Try to set to 1920x1200
if xrandr --output "$VM_DISPLAY" --mode 1920x1200 2>/dev/null; then
echo "Successfully set $VM_DISPLAY to 1920x1200"
else
echo "Could not set $VM_DISPLAY to 1920x1200, using current resolution"
fi
else
echo "No VM display found, proceeding with normal logic"
fi
else
# Normal laptop/desktop logic for non-VM systems
INTERNAL_DISPLAY=$(xrandr | grep "eDP" | cut -d' ' -f1 | head -n1)
EXTERNAL_CONNECTED=$(xrandr | grep " connected" | grep -v "eDP" | wc -l)

if [ -n "$INTERNAL_DISPLAY" ]; then
NATIVE_RES=$(xrandr | grep "$INTERNAL_DISPLAY" | grep -oP '\d+x\d+' | head -n1)

case $NATIVE_RES in
"2880x1800")
xrandr --output "$INTERNAL_DISPLAY" --mode 1920x1200 
echo "Set internal display to 1920x1200 for font clarity"
;;
"1920x1080")
echo "Keeping native 1920x1080 resolution"
;;
*)
echo "Unknown internal resolution: $NATIVE_RES, keeping native"
;;
esac
else
echo "No internal display found"
fi
fi

sleep 0.5

get_primary_resolution() {
xrandr | grep " connected primary" | grep -oP '\d+x\d+' | head -n1
}

get_any_resolution() {
xrandr | grep " connected" | grep -oP '\d+x\d+' | head -n1
}

RESOLUTION=$(get_primary_resolution)

if [ -z "$RESOLUTION" ]; then
RESOLUTION=$(get_any_resolution)
echo "No primary display found, using first connected display: $RESOLUTION"
fi

echo "Detected resolution: $RESOLUTION"

CONFIG_DIR="$HOME/.config/i3"
BASE_CONFIG="$CONFIG_DIR/config.base"
FINAL_CONFIG="$CONFIG_DIR/config"

if [ ! -f "$BASE_CONFIG" ]; then
echo "Error: Base config file not found at $BASE_CONFIG"
exit 1
fi

case $RESOLUTION in
"1920x1080")
resolution_config="$CONFIG_DIR/config1080p"
echo "Using 1080p config"
;;
"1920x1200")
resolution_config="$CONFIG_DIR/config1080p"
echo "Using 1080p config"
;;
"2880x1800")
resolution_config="$CONFIG_DIR/config2880"
echo "Using 2880p config"
;;
"3840x2160")
resolution_config="$CONFIG_DIR/config4k"
echo "Using 4K config"
;;
"2288x1436")
resolution_config="$CONFIG_DIR/config3k"
echo "Using 3K config"
;;
*)
resolution_config=""
echo "No specific config for resolution $RESOLUTION, using defaults"
;;
esac

{
cat "$BASE_CONFIG"

if [ -n "$resolution_config" ] && [ -f "$resolution_config" ]; then
echo ""
echo "# Resolution-specific settings for $RESOLUTION"
cat "$resolution_config"
else
echo ""
echo "# Using default settings (no specific config for $RESOLUTION)"
fi
} > "$FINAL_CONFIG"

echo "Created i3 config at $FINAL_CONFIG"

exec i3
