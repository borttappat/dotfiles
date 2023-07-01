#!/run/current-system/sw/bin/bash

HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')
openrgb --device 0 --mode static --color ${HEX_CODE/#/}
