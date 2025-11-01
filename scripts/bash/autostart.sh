#!/run/current-system/sw/bin/bash

# Ensure dunst uses wal colors
mkdir -p ~/.config/dunst
ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

# Notify user that display configuration is starting
notify-send "Display Setup" "Configuring monitors..." -t 2000

hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

if [[ ! $hostname =~ [vV][mM] ]]; then
killall -q picom
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
picom -b
fi

# Configure external monitors (DP and HDMI)
INTERNAL_DISPLAY=$(xrandr --query | grep "eDP" | grep " connected" | cut -d' ' -f1)
EXTERNAL_DISPLAYS=$(xrandr --query | grep " connected" | grep -E "(DP-|HDMI-)" | cut -d' ' -f1)

if [ -n "$INTERNAL_DISPLAY" ] && [ -n "$EXTERNAL_DISPLAYS" ]; then
echo "Configuring display layout: external monitors above internal"
for external in $EXTERNAL_DISPLAYS; do
xrandr --output "$external" --auto --above "$INTERNAL_DISPLAY"
echo "Positioned $external above $INTERNAL_DISPLAY"
done

# Restore wallpaper after xrandr changes
sleep 0.5
wal -Rnq
~/.fehbg &
fi

source ~/.config/scripts/load-display-config.sh

sed -e "s/\${POLYBAR_FONT_SIZE}/$POLYBAR_FONT_SIZE/g" \
    -e "s/\${POLYBAR_FONT}/$POLYBAR_FONT/g" \
    ~/.config/polybar/config.ini.template > ~/.config/polybar/config.ini

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

for monitor in $(xrandr --query | grep " connected" | cut -d' ' -f1); do
echo "Launching polybar on $monitor"
MONITOR=$monitor polybar -q main &
done

notify-send "Display Setup" "Configuration complete!" -t 2000

echo "Autostart completed... Resolution: $DISPLAY_RESOLUTION, Polybar font: $POLYBAR_FONT_SIZE"
