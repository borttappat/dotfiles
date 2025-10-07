#!/run/current-system/sw/bin/bash

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ ! $hostname =~ [vV][mM] ]]; then
killall -q picom
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
picom -b
fi

source ~/.config/scripts/load-display-config.sh

sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar -q main &

echo "Autostart completed... Resolution: $DISPLAY_RESOLUTION, Polybar font: $POLYBAR_FONT_SIZE"
