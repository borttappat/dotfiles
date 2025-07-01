#!/run/current-system/sw/bin/bash

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ ! $hostname =~ [vV][mM] ]]; then
    killall -q picom
    while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
    picom -b
fi

get_primary_resolution() {
    xrandr | grep primary | grep -oP '\d+x\d+' | head -n1
}

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

PRIMARY_RESOLUTION=$(get_primary_resolution)

case $PRIMARY_RESOLUTION in
    "2880x1800")
        polybar -q hidpi &
        ;;
    "1920x1080")
        polybar -q main &
        ;;
    "1920x1200")
        polybar -q main &
        ;;
    "3840x2160")
        polybar -q 4k &
        ;;
    "3600x2252")
        polybar -q 3k &
        ;;
    "2288x1436")
        polybar -q 3k &
        ;;    
    "2560x1440")
        polybar -q 4k &
        ;;
    *)
        polybar -q main &
        ;;
esac

if xrandr | grep " connected" | grep -v "eDP" | grep -q "2560x1440"; then
    echo "External 2560x1440 display detected, launching 4k polybar for external"
    MONITOR=$(xrandr | grep " connected" | grep -v "eDP" | grep "2560x1440" | cut -d' ' -f1) polybar -q 4k &
fi

echo "Autostart completed... Primary: $PRIMARY_RESOLUTION, External 2560x1440: $(xrandr | grep " connected" | grep -v "eDP" | grep -q "2560x1440" && echo 'Yes' || echo 'No')"
