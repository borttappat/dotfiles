#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: walrgb /path/to/file"
  exit 1
fi

file_path="$1"
file_name="${file_path##*/}"
directory="${file_path%/*}"

echo "File path: $file_path"
echo "File name: $file_name"
echo "Directory: $directory"

echo "Setting colorscheme according to $file_path"
wal -q -i "${file_path}"
echo "Colorscheme set"

HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')

if command -v asusctl >/dev/null 2>&1 && asusctl -v >/dev/null 2>&1; then
  echo "ASUS hardware detected, using asusctl"
  asusctl led-mode static -c $HEX_CODE
elif command -v openrgb >/dev/null 2>&1; then
  echo "Checking for RGB devices..."
  if openrgb --list-devices 2>/dev/null | grep -q "Device [0-9]"; then
    echo "RGB devices found, using OpenRGB to set device lighting"  
    openrgb --device 0 --mode static --color "${HEX_CODE/#/}"
  else
    echo "No RGB devices detected, skipping OpenRGB"
  fi
else
  echo "No compatible RGB control tool found. Skipping RGB lighting control."
fi

echo "Backlight set"

polybar-msg cmd restart
echo "Restarting polybar..."

~/dotfiles/scripts/bash/nixwal.sh

startpage="$HOME/dotfiles/misc/startpage.html"
colors_css="$HOME/.cache/wal/colors.css"

sed -i '12,28d' "$startpage"
sed -n '12,28p' "$colors_css" | sed -i '11r /dev/stdin' "$startpage"

echo "Starting GitHub Pages color update..."

site_colors="$HOME/borttappat.github.io/assets/css/colors.css"
colors_css="$HOME/.cache/wal/colors.css"

mkdir -p "$(dirname "$site_colors")"

{
    echo "/* Theme colors - automatically generated */"
    echo ":root {"
    echo "    /* Colors extracted from pywal */"
    sed -n '12,28p' "$colors_css"
    echo ""
    echo "    /* Additional theme variables */"
    echo "    --scanline-color: rgba(12, 12, 12, 0.1);"
    echo "    --flicker-color: rgba(152, 217, 2, 0.01);"
    echo "    --text-shadow-color: var(--color1);"
    echo "    --header-shadow-color: var(--color0);"
    echo "}"
} > "$site_colors"
echo "Updated GitHub Pages colors"

colors_file="$HOME/.cache/wal/colors.sh"
zathura_config="$HOME/.config/zathura/zathurarc"

source "$colors_file"

sed -i "s/^set notification-error-bg.*/set notification-error-bg \"$background\"/" "$zathura_config"
sed -i "s/^set notification-error-fg.*/set notification-error-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set notification-warning-bg.*/set notification-warning-bg \"$background\"/" "$zathura_config"
sed -i "s/^set notification-warning-fg.*/set notification-warning-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set notification-bg.*/set notification-bg \"$background\"/" "$zathura_config"
sed -i "s/^set notification-fg.*/set notification-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set completion-group-bg.*/set completion-group-bg \"$background\"/" "$zathura_config"
sed -i "s/^set completion-group-fg.*/set completion-group-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set completion-bg.*/set completion-bg \"$color1\"/" "$zathura_config"
sed -i "s/^set completion-fg.*/set completion-fg \"$foreground\"/" "$zathura_config"
sed -i "s/^set completion-highlight-bg.*/set completion-highlight-bg \"$color3\"/" "$zathura_config"
sed -i "s/^set completion-highlight-fg.*/set completion-highlight-fg \"$foreground\"/" "$zathura_config"
sed -i "s/^set index-bg.*/set index-bg \"$background\"/" "$zathura_config"
sed -i "s/^set index-fg.*/set index-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set index-active-bg.*/set index-active-bg \"$color1\"/" "$zathura_config"
sed -i "s/^set index-active-fg.*/set index-active-fg \"$foreground\"/" "$zathura_config"
sed -i "s/^set inputbar-bg.*/set inputbar-bg \"$color1\"/" "$zathura_config"
sed -i "s/^set inputbar-fg.*/set inputbar-fg \"$foreground\"/" "$zathura_config"
sed -i "s/^set statusbar-bg.*/set statusbar-bg \"$color3\"/" "$zathura_config"
sed -i "s/^set statusbar-fg.*/set statusbar-fg \"$background\"/" "$zathura_config"
sed -i "s/^set highlight-color.*/set highlight-color \"$color2\"/" "$zathura_config"
sed -i "s/^set highlight-active-color.*/set highlight-active-color \"$color3\"/" "$zathura_config"
sed -i "s/^set default-bg.*/set default-bg \"$background\"/" "$zathura_config"
sed -i "s/^set default-fg.*/set default-fg \"$color2\"/" "$zathura_config"
sed -i "s/^set recolor-lightcolor.*/set recolor-lightcolor \"$background\"/" "$zathura_config"
sed -i "s/^set recolor-darkcolor.*/set recolor-darkcolor \"$color2\"/" "$zathura_config"

echo "Zathura colors updated successfully."

pywalfox update
echo "Colors updated!"
