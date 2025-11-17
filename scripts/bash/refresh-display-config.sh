#!/run/current-system/sw/bin/bash
# Save as ~/dotfiles/scripts/bash/refresh-display-config.sh

# Set MOD_KEY (same logic as .xinitrc)
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)
if [[ $hostname =~ [vV][mM] ]]; then
    export MOD_KEY="Mod1"
else
    export MOD_KEY="Mod4"
fi

# Reload display config
source ~/.config/scripts/load-display-config.sh

# Regenerate i3 config
sed -e "s/\${MOD_KEY}/$MOD_KEY/g" \
    -e "s/\${I3_FONT}/$I3_FONT/g" \
    -e "s/\${I3_FONT_SIZE}/$I3_FONT_SIZE/g" \
    -e "s/\${I3_BORDER_THICKNESS_EXTERNAL}/$I3_BORDER_THICKNESS_EXTERNAL/g" \
    -e "s/\${I3_BORDER_THICKNESS}/$I3_BORDER_THICKNESS/g" \
    -e "s/\${GAPS_INNER_EXTERNAL}/$GAPS_INNER_EXTERNAL/g" \
    -e "s/\${GAPS_INNER}/$GAPS_INNER/g" \
    ~/.config/i3/config.template > ~/.config/i3/config

# Regenerate polybar config (will be overridden by polybar-restart with per-monitor configs)
sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
    -e "s/\${POLYBAR_HEIGHT}/$POLYBAR_HEIGHT/g" \
    -e "s/\${POLYBAR_LINE_SIZE}/$POLYBAR_LINE_SIZE/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini

# Regenerate alacritty config
sed -e "s/\${ALACRITTY_FONT_SIZE}/$ALACRITTY_FONT_SIZE/g" \
    -e "s/\${ALACRITTY_FONT}/$ALACRITTY_FONT/g" \
    -e "s/\${ALACRITTY_SCALE_FACTOR_LINE}/$ALACRITTY_SCALE_FACTOR_LINE/g" \
    ~/.config/alacritty/alacritty.toml.template > ~/.config/alacritty/alacritty.toml

# Regenerate Firefox configs
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/user.js.template > ~/dotfiles/firefox/traum/user.js
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/chrome/userChrome.css.template > ~/dotfiles/firefox/traum/chrome/userChrome.css
sed -e "s/\${FIREFOX_FONT}/$FIREFOX_FONT/g" \
    ~/dotfiles/firefox/traum/chrome/userContent.css.template > ~/dotfiles/firefox/traum/chrome/userContent.css

# Regenerate Obsidian font config
sed -e "s/\${OBSIDIAN_FONT}/$OBSIDIAN_FONT/g" \
    -e "s/\${OBSIDIAN_FONT_SIZE}/$OBSIDIAN_FONT_SIZE/g" \
    -e "s/\${OBSIDIAN_HEADER_FONT_SIZE}/$OBSIDIAN_HEADER_FONT_SIZE/g" \
    ~/dotfiles/obsidian/font.css.template > ~/hack_the_world/.obsidian/snippets/font.css

# Reload i3 (which will reload config including gaps and borders)
i3-msg reload

# Regenerate dunst config
# Use wal template if wal colors exist and is not empty, otherwise use basic template
if [ -f ~/.cache/wal/dunstrc ] && [ -s ~/.cache/wal/dunstrc ]; then
    # Expand display-config variables in the wal-generated config
    sed -e "s/###DUNST_FONT###/$DUNST_FONT/g" \
        -e "s/###DUNST_FONT_SIZE###/$DUNST_FONT_SIZE/g" \
        -e "s/###DUNST_WIDTH###/$DUNST_WIDTH/g" \
        -e "s/###DUNST_HEIGHT###/$DUNST_HEIGHT/g" \
        -e "s/###DUNST_OFFSET_X###/$DUNST_OFFSET_X/g" \
        -e "s/###DUNST_OFFSET_Y###/$DUNST_OFFSET_Y/g" \
        -e "s/###DUNST_PADDING###/$DUNST_PADDING/g" \
        -e "s/###DUNST_FRAME_WIDTH###/$DUNST_FRAME_WIDTH/g" \
        -e "s/###DUNST_ICON_SIZE###/$DUNST_ICON_SIZE/g" \
        ~/.cache/wal/dunstrc > ~/.config/dunst/dunstrc
else
    # Use basic template as fallback
    sed -e "s/\${DUNST_FONT}/$DUNST_FONT/g" \
        -e "s/\${DUNST_FONT_SIZE}/$DUNST_FONT_SIZE/g" \
        -e "s/\${DUNST_WIDTH}/$DUNST_WIDTH/g" \
        -e "s/\${DUNST_HEIGHT}/$DUNST_HEIGHT/g" \
        -e "s/\${DUNST_OFFSET_X}/$DUNST_OFFSET_X/g" \
        -e "s/\${DUNST_OFFSET_Y}/$DUNST_OFFSET_Y/g" \
        -e "s/\${DUNST_PADDING}/$DUNST_PADDING/g" \
        -e "s/\${DUNST_FRAME_WIDTH}/$DUNST_FRAME_WIDTH/g" \
        -e "s/\${DUNST_ICON_SIZE}/$DUNST_ICON_SIZE/g" \
        ~/dotfiles/dunst/dunstrc.template > ~/.config/dunst/dunstrc
fi

# Restart dunst to apply new config
killall dunst 2>/dev/null; dunst &

# Reload polybar with per-monitor configs
~/dotfiles/scripts/bash/polybar-restart.sh

notify-send "Display Config" "Reloaded: external=$EXTERNAL_MONITOR font=$POLYBAR_FONT_SIZE gaps=$GAPS_INNER border=$I3_BORDER_THICKNESS"
