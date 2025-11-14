#!/run/current-system/sw/bin/bash

AUTOSTART_LOG="/tmp/autostart.log"
echo "$(date): ========== Autostart.sh invoked ==========" >> "$AUTOSTART_LOG"

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
# Give displays a moment to stabilize
sleep 0.5

INTERNAL_DISPLAY=$(xrandr --query | grep "eDP" | grep " connected" | cut -d' ' -f1)
EXTERNAL_DISPLAYS=$(xrandr --query | grep " connected" | grep -E "(DP-|HDMI-)" | cut -d' ' -f1)

echo "$(date): Internal: $INTERNAL_DISPLAY, External: $EXTERNAL_DISPLAYS" >> /tmp/autostart.log

if [ -n "$INTERNAL_DISPLAY" ] && [ -n "$EXTERNAL_DISPLAYS" ]; then
echo "$(date): Configuring display layout: external monitors above internal" >> /tmp/autostart.log
for external in $EXTERNAL_DISPLAYS; do
xrandr --output "$external" --auto --above "$INTERNAL_DISPLAY"
echo "$(date): Positioned $external above $INTERNAL_DISPLAY" >> /tmp/autostart.log
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

AUTOSTART_LOG="/tmp/autostart.log"
echo "$(date): Autostart.sh starting" >> "$AUTOSTART_LOG"

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)
echo "$(date): Detected monitors: $MONITORS" >> "$AUTOSTART_LOG"

for monitor in $MONITORS; do
echo "$(date): Launching polybar on $monitor" >> "$AUTOSTART_LOG"
MONITOR=$monitor polybar -q main >> "$AUTOSTART_LOG" 2>&1 &
done

notify-send "Display Setup" "Configuration complete!" -t 2000

echo "$(date): Autostart completed... Resolution: $DISPLAY_RESOLUTION, Polybar font: $POLYBAR_FONT_SIZE" >> "$AUTOSTART_LOG"
