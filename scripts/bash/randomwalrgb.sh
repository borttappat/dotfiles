#!/run/current-system/sw/bin/bash

wal -q -i ~/Wallpapers -o wal-set

HEX_CODE=$(sed -n '5p' ~/.cache/wal/colors | sed 's/#//')
openrgb --device 0 --mode static --color ${HEX_CODE/#/}

polybar-msg cmd restart
