#!/run/current-system/sw/bin/bash

wal -i ~/Wallpapers -o wal-set

HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')
openrgb --device 0 --mode static --color ${HEX_CODE/#/}

killall polybar
polybar
