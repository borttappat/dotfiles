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

sed -e "s/\${MOD_KEY}/$MOD_KEY/g" \
    -e "s/\${I3_FONT_SIZE}/$I3_FONT_SIZE/g" \
    -e "s/\${I3_BORDER_THICKNESS}/$I3_BORDER_THICKNESS/g" \
    -e "s/\${GAPS_INNER}/$GAPS_INNER/g" \
    ~/.config/i3/config.template > ~/.config/i3/config
sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
    -e "s/\${POLYBAR_HEIGHT}/$POLYBAR_HEIGHT/g" \
    -e "s/\${POLYBAR_LINE_SIZE}/$POLYBAR_LINE_SIZE/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini
sed -e "s/\${ALACRITTY_FONT_SIZE}/$ALACRITTY_FONT_SIZE/g" \
    -e "s/\${ALACRITTY_FONT}/$ALACRITTY_FONT/g" \
    -e "s/\${ALACRITTY_SCALE_FACTOR_LINE}/$ALACRITTY_SCALE_FACTOR_LINE/g" \
    ~/.config/alacritty/alacritty.toml.template > ~/.config/alacritty/alacritty.toml
sed -e "s/${DUNST_FONT}/$DUNST_FONT/g" \
    -e "s/${DUNST_FONT_SIZE}/$DUNST_FONT_SIZE/g" \
    -e "s/${DUNST_WIDTH}/$DUNST_WIDTH/g" \
    -e "s/${DUNST_HEIGHT}/$DUNST_HEIGHT/g" \
    -e "s/${DUNST_OFFSET_X}/$DUNST_OFFSET_X/g" \
    -e "s/${DUNST_OFFSET_Y}/$DUNST_OFFSET_Y/g" \
    -e "s/${DUNST_PADDING}/$DUNST_PADDING/g" \
    -e "s/${DUNST_FRAME_WIDTH}/$DUNST_FRAME_WIDTH/g" \
    -e "s/${DUNST_ICON_SIZE}/$DUNST_ICON_SIZE/g" \
    ~/dotfiles/dunst/dunstrc.template > ~/.config/dunst/dunstrc
exec i3
