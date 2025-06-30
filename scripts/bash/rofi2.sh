#!/run/current-system/sw/bin/bash
source ~/dotfiles/scripts/bash/detect-resolution.sh

CONFIG="$HOME/.config/rofi/config${CONFIG_SUFFIX}.rasi"
rofi -show "$1" -config "$CONFIG"
