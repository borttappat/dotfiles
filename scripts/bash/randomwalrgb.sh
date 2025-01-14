#!/run/current-system/sw/bin/bash

echo "Starting wallpaper and color update..."

#set a random wallpaper
wal -q -i ~/Wallpapers -o wal-set

# convert the colorscheme to HEX and run walrgb with the color to set colors of device 0
HEX_CODE=$(sed -n '4p' ~/.cache/wal/colors | sed 's/#//')
openrgb --device 0 --mode static --color ${HEX_CODE/#/}

# set the nix-colors to the generated colorscheme
# paste colors from wal-cache ~/dotfiles/wal/nix-colors
~/dotfiles/scripts/bash/nixwal.sh

# update /etc/nixos/colors.nix with colors from ~/dotfiles/wal/nix-color
${python3}/bin/python ~/dotfiles/scripts/python/nixcolors.py

# change the colors for startpage.html 
# define file paths
startpage="$HOME/dotfiles/misc/startpage.html"
colors_css="$HOME/.cache/wal/colors.css"

# Remove content from lines 12 to 28 in startpage.html
sed -i '12,28d' "$startpage"

# Extract lines 12 to 28 from colors.css and insert them into startpage.html at line 12
sed -n '12,28p' "$colors_css" | sed -i '11r /dev/stdin' "$startpage"

# Update GitHub Pages colors.css
echo "Starting GitHub Pages color update..."

# Define file paths
site_colors="$HOME/borttappat.github.io/assets/css/colors.css"
colors_css="$HOME/.cache/wal/colors.css"

# Ensure the css directory exists
mkdir -p "$(dirname "$site_colors")"

# Create or update colors.css
{
    echo "/* Theme colors - automatically generated */"
    echo ":root {"
    echo "    /* Colors extracted from pywal */"
    # Extract color definitions from pywal
    sed -n '12,28p' "$colors_css"
    echo ""
    echo "    /* Additional theme variables */"
    echo "    --scanline-color: rgba(12, 12, 12, 0.1);"
    echo "    --flicker-color: rgba(152, 217, 2, 0.01);"
    echo "    --text-shadow-color: var(--color1);"
    echo "    --header-shadow-color: var(--color0);"
    echo "}"
} > "$site_colors"

# Update other configurations
echo "Updating other configurations..."
sh ~/dotfiles/scripts/bash/zathuracolors.sh

# restart polybar
echo "Restarting polybar..."
polybar-msg cmd restart

echo "Updating pywalfox..."
pywalfox update

echo "Script completed!"
