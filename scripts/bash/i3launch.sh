#!/run/current-system/sw/bin/bash

# Get display info
INTERNAL_DISPLAY=$(xrandr | grep "eDP" | cut -d' ' -f1 | head -n1)
EXTERNAL_CONNECTED=$(xrandr | grep " connected" | grep -v "eDP" | wc -l)

# Only set resolution for internal display if no external monitor
if [ "$EXTERNAL_CONNECTED" -eq 0 ] && [ -n "$INTERNAL_DISPLAY" ]; then
    # Get native resolution of internal display
    NATIVE_RES=$(xrandr | grep "$INTERNAL_DISPLAY" | grep -oP '\d+x\d+' | head -n1)
    
    case $NATIVE_RES in
        "2880x1800")
            # Zenbook - set to 1920x1200 for sharp fonts
            xrandr --output "$INTERNAL_DISPLAY" --mode 1920x1200
            echo "Set internal display to 1920x1200 for font clarity"
            ;;
        "1920x1080")
            # Zephyrus - keep native
            echo "Keeping native 1920x1080 resolution"
            ;;
        *)
            echo "Unknown internal resolution: $NATIVE_RES, keeping native"
            ;;
    esac
else
    echo "External monitor detected or no internal display found, keeping current setup"
fi

# Small delay to let resolution change take effect
sleep 0.5

# Function to get the primary display resolution
get_primary_resolution() {
    xrandr | grep " connected primary" | grep -oP '\d+x\d+' | head -n1
}

# Fallback function if no primary display is set
get_any_resolution() {
    xrandr | grep " connected" | grep -oP '\d+x\d+' | head -n1
}

# Get current resolution
RESOLUTION=$(get_primary_resolution)

# If no primary display found, get any connected display
if [ -z "$RESOLUTION" ]; then
    RESOLUTION=$(get_any_resolution)
    echo "No primary display found, using first connected display: $RESOLUTION"
fi

# Log the detected resolution
echo "Detected resolution: $RESOLUTION"

# Base directory for configs
CONFIG_DIR="$HOME/.config/i3"
BASE_CONFIG="$CONFIG_DIR/config.base"
FINAL_CONFIG="$CONFIG_DIR/config"

# Check if base config exists
if [ ! -f "$BASE_CONFIG" ]; then
    echo "Error: Base config file not found at $BASE_CONFIG"
    exit 1
fi

# Select the appropriate config file based on resolution
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

# Create the final config
{
    # First include the base config that contains all shared settings
    cat "$BASE_CONFIG"
    
    # Then add resolution-specific settings if available
    if [ -n "$resolution_config" ] && [ -f "$resolution_config" ]; then
        echo "" # Add a newline for clarity
        echo "# Resolution-specific settings for $RESOLUTION"
        cat "$resolution_config"
    else
        echo "" # Add a newline for clarity
        echo "# Using default settings (no specific config for $RESOLUTION)"
    fi
} > "$FINAL_CONFIG"

echo "Created i3 config at $FINAL_CONFIG"

# Launch i3
exec i3
