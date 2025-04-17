#!/run/current-system/sw/bin/bash

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
