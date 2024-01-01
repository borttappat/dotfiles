#!/run/current-system/sw/bin/bash
unclutter -grab &
wal -R &
#picom -b &

# Here Xfce is kept as default
session=${1:-i3}

case $session in
    i3           ) picom -b && exec i3;;
    i3wm         ) exec i3 -c ~/dotfiles/i3configwm;;
    kde               ) exec startplasma-x11;;
    xfce|xfce4        ) exec startxfce4;;
    # No known session, try to run it as command
    *                 ) exec $1;;
esac


