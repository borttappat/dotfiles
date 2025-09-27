#!/run/current-system/sw/bin/bash

cleanup_old_serverauth() {
    echo "Cleaning up old serverauth files..."
    find "$HOME" -maxdepth 1 -name ".serverauth.*" -type f -mtime +2 -print0 | while IFS= read -r -d '' file; do
        echo "Removing old serverauth file: $(basename "$file")"
        rm -f "$file"
    done
}

cleanup_old_serverauth

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ $hostname =~ [vV][mM] ]]; then
echo "VM detected, setting up VM display resolution..."

VM_DISPLAY=$(xrandr | grep -E "(Virtual-1|qxl-0)" | grep " connected" | cut -d' ' -f1 | head -n1)

if [ -n "$VM_DISPLAY" ]; then
echo "Found VM display: $VM_DISPLAY"
xrandr --newmode "1920x1200" 193.25 1920 2056 2256 2592 1200 1203 1209 1245 -hsync +vsync 2>/dev/null || true
xrandr --newmode "2560x1440" 312.25 2560 2752 3024 3488 1440 1443 1448 1493 -hsync +vsync 2>/dev/null || true
xrandr --addmode "$VM_DISPLAY" 1920x1200 2>/dev/null || true
xrandr --addmode "$VM_DISPLAY" 2560x1440 2>/dev/null || true
if xrandr --output "$VM_DISPLAY" --mode 2560x1440 2>/dev/null; then
echo "Successfully set $VM_DISPLAY to 2560x1440"
elif xrandr --output "$VM_DISPLAY" --mode 1920x1200 2>/dev/null; then
echo "Successfully set $VM_DISPLAY to 1920x1200"
else
echo "Could not set custom resolution, using current resolution"
fi
else
echo "No VM display found, proceeding with normal logic"
fi
else
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

generate_resolution_settings() {
    local res=$1
    case $res in
        "1920x1080"|"1920x1200")
            cat << 'EOF'

# Resolution-specific settings for 1920x1080/1200
font pango:Cozette 8
gaps inner 6
gaps outer 0
for_window [class=".*"] border pixel 2
EOF
            ;;
        "2560x1440")
            cat << 'EOF'

# Resolution-specific settings for 2560x1440
font pango:Cozette 9
gaps inner 8
gaps outer 0
for_window [class=".*"] border pixel 2
EOF
            ;;
        "2880x1800"|"2288x1436")
            cat << 'EOF'

# Resolution-specific settings for 2880x1800/2288x1436
font pango:Cozette 10
gaps inner 10
gaps outer 0
for_window [class=".*"] border pixel 3
EOF
            ;;
        "3840x2160")
            cat << 'EOF'

# Resolution-specific settings for 4K
font pango:Cozette 12
gaps inner 12
gaps outer 0
for_window [class=".*"] border pixel 4
EOF
            ;;
        *)
            cat << 'EOF'

# Default settings
font pango:Cozette 8
gaps inner 6
gaps outer 0
for_window [class=".*"] border pixel 2
EOF
            ;;
    esac
}

generate_modifier_settings() {
    local is_vm=$1
    if [[ $is_vm == "true" ]]; then
        echo ""
        echo "# VM-specific modifier override"
        echo "set \$mod Mod4"
    fi
}

CONFIG_DIR="$HOME/.config/i3"
BASE_CONFIG="$CONFIG_DIR/config.base"
FINAL_CONFIG="$CONFIG_DIR/config"

if [ ! -f "$BASE_CONFIG" ]; then
echo "Error: Base config file not found at $BASE_CONFIG"
exit 1
fi

IS_VM="false"
if [[ $hostname =~ [vV][mM] ]]; then
    IS_VM="true"
fi

{
cat "$BASE_CONFIG"
generate_modifier_settings "$IS_VM"
generate_resolution_settings "$RESOLUTION"
} > "$FINAL_CONFIG"

echo "Created i3 config at $FINAL_CONFIG for resolution $RESOLUTION"
if [[ $IS_VM == "true" ]]; then
    echo "VM detected: Using Mod4 (Super) as modifier"
else
    echo "Regular system: Using Mod1 (Alt) as modifier"
fi

exec i3
