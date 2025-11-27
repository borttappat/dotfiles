#!/run/current-system/sw/bin/bash

CONFIG_FILE="$HOME/dotfiles/configs/display-config.json"
HOSTNAME=$(hostnamectl hostname | cut -d'-' -f1)

# Get machine override settings
MACHINE_OVERRIDE=$(jq -r ".machine_overrides[\"$HOSTNAME\"] // null" "$CONFIG_FILE")

if [ "$MACHINE_OVERRIDE" != "null" ]; then
    # Check for external monitors
    EXTERNAL_MONITOR_PATTERNS=$(echo "$MACHINE_OVERRIDE" | jq -r '.external_monitor_resolutions // [] | join("|")')
    EXTERNAL_MONITOR=0

    if [ -n "$EXTERNAL_MONITOR_PATTERNS" ] && xrandr --listmonitors | grep -qE "(${EXTERNAL_MONITOR_PATTERNS}/)"; then
        EXTERNAL_MONITOR=1
        # Get monitor names
        INTERNAL_MONITOR=$(xrandr --listmonitors | grep "eDP" | awk '{print $4}')
        EXTERNAL_MONITOR_NAME=$(xrandr --listmonitors | grep -vE "eDP|Monitors:" | grep -E "(${EXTERNAL_MONITOR_PATTERNS}/)" | awk '{print $4}' | head -n1)

        # Get border thicknesses and gaps from config
        INTERNAL_BORDER=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness // 2")
        EXTERNAL_BORDER=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness_external // 1")
        INTERNAL_GAPS=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // 5")
        EXTERNAL_GAPS=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner_external // 5")

        echo "External monitor detected: $EXTERNAL_MONITOR_NAME"
        echo "Internal border: $INTERNAL_BORDER, External border: $EXTERNAL_BORDER"
        echo "Internal gaps: $INTERNAL_GAPS, External gaps: $EXTERNAL_GAPS"

        # Assign workspaces to monitors
        i3-msg "workspace 1 output $INTERNAL_MONITOR"
        i3-msg "workspace 2 output $EXTERNAL_MONITOR_NAME"
        i3-msg "workspace 3 output $INTERNAL_MONITOR"
        i3-msg "workspace 4 output $EXTERNAL_MONITOR_NAME"
        i3-msg "workspace 5 output $INTERNAL_MONITOR"
        i3-msg "workspace 6 output $EXTERNAL_MONITOR_NAME"
        i3-msg "workspace 7 output $INTERNAL_MONITOR"
        i3-msg "workspace 8 output $EXTERNAL_MONITOR_NAME"
        i3-msg "workspace 9 output $INTERNAL_MONITOR"
        i3-msg "workspace 10 output $EXTERNAL_MONITOR_NAME"

        # Set borders per workspace
        i3-msg "[workspace=\"1\"] border pixel $INTERNAL_BORDER"
        i3-msg "[workspace=\"3\"] border pixel $INTERNAL_BORDER"
        i3-msg "[workspace=\"5\"] border pixel $INTERNAL_BORDER"
        i3-msg "[workspace=\"7\"] border pixel $INTERNAL_BORDER"
        i3-msg "[workspace=\"9\"] border pixel $INTERNAL_BORDER"

        i3-msg "[workspace=\"2\"] border pixel $EXTERNAL_BORDER"
        i3-msg "[workspace=\"4\"] border pixel $EXTERNAL_BORDER"
        i3-msg "[workspace=\"6\"] border pixel $EXTERNAL_BORDER"
        i3-msg "[workspace=\"8\"] border pixel $EXTERNAL_BORDER"
        i3-msg "[workspace=\"10\"] border pixel $EXTERNAL_BORDER"

        # Set gaps per workspace
        i3-msg "workspace 1 gaps inner $INTERNAL_GAPS"
        i3-msg "workspace 3 gaps inner $INTERNAL_GAPS"
        i3-msg "workspace 5 gaps inner $INTERNAL_GAPS"
        i3-msg "workspace 7 gaps inner $INTERNAL_GAPS"
        i3-msg "workspace 9 gaps inner $INTERNAL_GAPS"

        i3-msg "workspace 2 gaps inner $EXTERNAL_GAPS"
        i3-msg "workspace 4 gaps inner $EXTERNAL_GAPS"
        i3-msg "workspace 6 gaps inner $EXTERNAL_GAPS"
        i3-msg "workspace 8 gaps inner $EXTERNAL_GAPS"
        i3-msg "workspace 10 gaps inner $EXTERNAL_GAPS"
    else
        # No external monitor - use internal border and gaps for all workspaces
        INTERNAL_BORDER=$(echo "$MACHINE_OVERRIDE" | jq -r ".i3_border_thickness // 2")
        INTERNAL_GAPS=$(echo "$MACHINE_OVERRIDE" | jq -r ".gaps_inner // 5")

        echo "No external monitor - using internal border: $INTERNAL_BORDER and gaps: $INTERNAL_GAPS for all workspaces"

        for ws in {1..10}; do
            i3-msg "[workspace=\"$ws\"] border pixel $INTERNAL_BORDER"
            i3-msg "workspace $ws gaps inner $INTERNAL_GAPS"
        done
    fi
else
    echo "No machine override found for $HOSTNAME"
fi
