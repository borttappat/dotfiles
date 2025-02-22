#!/run/current-system/sw/bin/bash

unclutter -grab &
wal -Rn &
#mullvad connect & 
#picom -b

#exec i3
exec ~/dotfiles/scripts/bash/i3launch.sh

# Here i3 is kept as default
#session=${1:-i3}
#
#case $session in
#    i3           ) wal -Rnq && exec i3;;
#    i3wm         ) wal -Rnq && exec i3;;
#
# No known session, try to run it as command
#    *                 ) exec $1;;
#esac


