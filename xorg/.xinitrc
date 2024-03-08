#!/run/current-system/sw/bin/bash

unclutter -grab &
wal -Rn &
#mullvad connect & 

# Here i3 is kept as default
session=${1:-i3}

case $session in
    i3           ) picom -b && wal -R && exec i3;;
    i3wm         ) exec i3;;

# No known session, try to run it as command
    *                 ) exec $1;;
esac


