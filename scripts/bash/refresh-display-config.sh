#!/run/current-system/sw/bin/bash
# Save as ~/dotfiles/scripts/bash/refresh-display-config.sh

# Reload display config
source ~/.config/scripts/load-display-config.sh

# Regenerate i3 config
sed -e "s/\${MOD_KEY}/$MOD_KEY/g" \
    -e "s/\${I3_FONT_SIZE}/$I3_FONT_SIZE/g" \
    -e "s/\${GAPS_INNER}/$GAPS_INNER/g" \
    ~/.config/i3/config.template > ~/.config/i3/config

# Regenerate polybar config
sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini

# Reload i3 (which will restart polybar)
i3-msg reload

# Reload polybar
polybar-msg cmd restart

notify-send "Display Config" "Reloaded with font: $POLYBAR_FONT @ size $POLYBAR_FONT_SIZE"
