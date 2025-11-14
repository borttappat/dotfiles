#!/run/current-system/sw/bin/bash
unclutter -grab &
wal -Rn &

find "$HOME" -maxdepth 1 -name ".serverauth.*" -type f -mtime +2 -delete 2>/dev/null

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)
if [[ $hostname =~ [vV][mM] ]]; then
    spice-vdagent -x &
    VM_DISPLAY=$(xrandr | grep -E "(Virtual-1|qxl-0)" | grep " connected" | cut -d' ' -f1 | head -n1)
    if [ -n "$VM_DISPLAY" ]; then
        xrandr --output "$VM_DISPLAY" --mode 1920x1200 2>/dev/null || true
    fi
    export MOD_KEY="Mod1"
else
    export MOD_KEY="Mod4"
    # Resolution will be set by load-display-config.sh based on machine overrides
fi

sleep 0.5

source ~/.config/scripts/load-display-config.sh

sed -e "s/\${MOD_KEY}/$MOD_KEY/g" -e "s/\${I3_FONT_SIZE}/$I3_FONT_SIZE/g" -e "s/\${GAPS_INNER}/$GAPS_INNER/g" ~/.config/i3/config.template > ~/.config/i3/config
sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini
exec i3
