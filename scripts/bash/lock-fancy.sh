#!/run/current-system/sw/bin/bash

# Kill any existing instances of i3lock
killall -q i3lock

# Create temporary files
img=/tmp/i3lock.png
blur_img=/tmp/i3lock_blur.png

# Take a screenshot
scrot -o $img

# Apply blur/pixelate effect using magick (ImageMagick 7 syntax)
magick $img -scale 20% -scale 500% $blur_img

# Source wal colors for consistent theming
. "$HOME/.cache/wal/colors.sh"

# Run i3lock with the blurred image
i3lock \
    -i $blur_img \
    --clock \
    --time-str="%H:%M:%S" \
    --date-str="%A, %Y-%m-%d" \
    --time-size=48 \
    --date-size=18 \
    --time-font="CozetteVector" \
    --date-font="CozetteVector" \
    --time-color="${color7:1}" \
    --date-color="${color7:1}" \
    --inside-color="${color0:1}00" \
    --ring-color="${color2:1}ff" \
    --insidever-color="${color0:1}00" \
    --insidewrong-color="${color1:1}ff" \
    --ringver-color="${color2:1}ff" \
    --ringwrong-color="${color1:1}ff" \
    --line-color="${color0:1}00" \
    --separator-color="${color0:1}00" \
    --keyhl-color="${color2:1}ff" \
    --bshl-color="${color1:1}ff" \
    --radius=120 \
    --ring-width=4 \
    --indicator \
    --ignore-empty-password

# Clean up temporary files
rm $img $blur_img
