#!/run/current-system/sw/bin/bash

# Check if the file path argument is provided
if [ -z "$1" ]; then
  echo "Usage: walrgb /path/to/file"
  exit 1
fi

# Extract specific part of the path using parameter expansion
file_path="$1"
file_name="${file_path##*/}"
directory="${file_path%/*}"

# Print the extracted parts of the path
echo "File path: $file_path"
echo "File name: $file_name"
echo "Directory: $directory"

# Run wal with the specified image path
echo "Setting colorscheme according to $file_path"
wal -q -i "${file_path}"
echo "Colorscheme set"

# IMPORTANT: Explicitly merge the X resources to fix border colors
xrdb -merge "${HOME}/.cache/wal/colors.Xresources"

# Convert line 2 of the wal colors cache to a hex code for RGB lighting
HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')

# Check if this is an ASUS machine (by checking if asusctl exists and works)
if command -v asusctl >/dev/null 2>&1 && asusctl -v >/dev/null 2>&1; then
  echo "ASUS hardware detected, using asusctl"
  # Use asusctl to set LED color
  asusctl led-mode static -c "$HEX_CODE"
elif command -v openrgb >/dev/null 2>&1; then
  echo "Using OpenRGB to set device lighting"
  # Use OpenRGB to set device color
  openrgb --device 0 --mode static --color "${HEX_CODE}"
else
  echo "No compatible RGB control tool found. Skipping RGB lighting control."
fi

echo "Backlight set"

# Restart polybar (more reliable approach)
echo "Restarting polybar..."
polybar-msg cmd restart

# Only kill and restart if the above command failed
if [ $? -ne 0 ]; then
  echo "Polybar message failed, trying full restart..."
  killall -q polybar
  while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done
  # Get the primary display resolution to determine which polybar config to use
  RESOLUTION=$(xrandr | grep " connected primary" | grep -oP '\d+x\d+' | head -n1)
  
  case $RESOLUTION in
    "2880x1800")
      polybar -q hidpi &
      ;;
    "1920x1080")
      polybar -q main &
      ;;
    "3840x2160")
      polybar -q 4k &
      ;;
    *)
      polybar -q main &  # Default to main bar
      ;;
  esac
fi

# Paste colors from wal-cache ~/dotfiles/wal/nix-colors
~/dotfiles/scripts/bash/nixwal.sh

# Update /etc/nixos/colors.nix with colors from ~/dotfiles/wal/nix-color
python ~/dotfiles/scripts/python/nixcolors.py

# Change colors for startpage
# Define file paths
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
echo "Updated GitHub Pages colors"

# Update zathura colors
~/dotfiles/scripts/bash/zathuracolors.sh

# Reload i3 to apply border changes
i3-msg reload > /dev/null

# Try to update Firefox/Librewolf themes
pywalfox update

echo "Colors updated!"
