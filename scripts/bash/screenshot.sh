#!/usr/bin/env bash
# Interactive region screenshot, replaces "flameshot gui" ($mod+F12).
# Select a region with the mouse; saves to ~/Pictures/Screenshots and copies
# the image to the clipboard. Uses scrot + xclip (both already installed).
set -eu

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

scrot -s "$file"
xclip -selection clipboard -t image/png -i "$file"

command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot saved" "$file"
