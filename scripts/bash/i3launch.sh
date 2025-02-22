#!/run/current-system/sw/bin/bash

# Function to get the primary display resolution
get_primary_resolution() {
    xrandr | grep primary | grep -oP '\d+x\d+' | head -n1
}

# Get current resolution
RESOLUTION=$(get_primary_resolution)

# Base directory for configs
CONFIG_DIR="$HOME/.config/i3"

# Select the appropriate config file based on resolution
case $RESOLUTION in
    "1920x1080")
        config_file="$CONFIG_DIR/config1080p"
        ;;
    "2880x1800")
        config_file="$CONFIG_DIR/config2880"
        ;;
    "3840x2160")
        config_file="$CONFIG_DIR/config4k"
        ;;
    *)
        config_file="$CONFIG_DIR/config"
        ;;
esac

# Create the final config by combining base config with resolution-specific settings
{
    # First include the base config that contains all shared settings
    cat "$CONFIG_DIR/config.base"
    
    # Then add resolution-specific settings
    echo "" # Add a newline for clarity
    echo "# Resolution-specific settings for $RESOLUTION"
    cat "$config_file"
} > "$CONFIG_DIR/config"

# Launch i3
exec i3
