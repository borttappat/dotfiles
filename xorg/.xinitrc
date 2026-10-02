#!/run/current-system/sw/bin/bash
unclutter -grab &
wal -Rn &

find "$HOME" -maxdepth 1 -name ".serverauth.*" -type f -mtime +2 -delete 2>/dev/null

# Virtual-display (VM) handling. Detect the virtual output directly rather than
# guessing from the machine chassis/hostname (the old check grepped "Icon name:",
# which is the chassis type, not the hostname, so it never matched and this whole
# block was skipped). Start spice-vdagent for host-driven resizes and apply the
# preferred mode with --auto.
VM_DISPLAY=$(xrandr | grep -E "^(Virtual|qxl)" | grep " connected" | cut -d' ' -f1 | head -n1)
if [ -n "$VM_DISPLAY" ]; then
    spice-vdagent -x 2>/dev/null &
    xrandr --output "$VM_DISPLAY" --auto 2>/dev/null || true
fi

# Mod key: Alt inside a VM chassis, Super otherwise. Detection left unchanged on
# purpose so existing keybinding behaviour is preserved.
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)
if [[ $hostname =~ [vV][mM] ]]; then
    export MOD_KEY="Mod1"
else
    export MOD_KEY="Mod4"
    # Resolution will be set by load-display-config.sh based on machine overrides
fi

sleep 0.5

source ~/.config/scripts/load-display-config.sh

sed -e "s/\${MOD_KEY}/$MOD_KEY/g" \
    -e "s/\${I3_FONT}/$I3_FONT/g" \
    -e "s/\${I3_FONT_SIZE}/$I3_FONT_SIZE/g" \
    -e "s/\${I3_BORDER_THICKNESS_EXTERNAL}/$I3_BORDER_THICKNESS_EXTERNAL/g" \
    -e "s/\${I3_BORDER_THICKNESS}/$I3_BORDER_THICKNESS/g" \
    -e "s/\${GAPS_INNER_EXTERNAL}/$GAPS_INNER_EXTERNAL/g" \
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
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/user.js.template > ~/dotfiles/firefox/traum/user.js
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/chrome/userChrome.css.template > ~/dotfiles/firefox/traum/chrome/userChrome.css
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/chrome/userContent.css.template > ~/dotfiles/firefox/traum/chrome/userContent.css
exec i3
