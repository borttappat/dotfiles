#!/run/current-system/sw/bin/bash

echo "Setting random wallpaper and colors..."

echo "Setting colorscheme from random wallpaper"
wal -q -i ~/Wallpapers
echo "Colorscheme set"

HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')

if command -v asusctl >/dev/null 2>&1 && asusctl -v >/dev/null 2>&1; then
  echo "ASUS hardware detected, using asusctl"
  asusctl aura static -c $HEX_CODE
  asusctl -k high
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

sh ~/dotfiles/scripts/bash/zathuracolors.sh

echo "updating firefox using pywalfox..."
pywalfox update
echo "pywalfox updated successfully"

sh ~/dotfiles/scripts/bash/wal-gtk.sh

echo "Updating dunst colors..."
ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
pkill dunst
dunst &
echo "Dunst colors updated"

echo "Colors updated!"
