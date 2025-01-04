#!/run/current-system/sw/bin/bash

# Kill any existing instances of i3lock
killall -q i3lock

# Create temporary files
img=/tmp/i3lock.png
blur_img=/tmp/i3lock_blur.png
text_img=/tmp/i3lock_text.png

# Take a screenshot
scrot -o $img

# Apply blur/pixelate effect using magick (ImageMagick 7 syntax)
magick $img -scale 20% -scale 500% $blur_img

# Add text to the upper left corner of the blurred image
magick $blur_img -gravity NorthWest -pointsize 143 -font "CozetteVector" -fill "${color7:1}" \
    -annotate +50+50 'Enter password' $text_img

# Source wal colors for consistent theming
. "$HOME/.cache/wal/colors.sh"

# Run i3lock-color with custom positions
i3lock \
    -i $text_img \
    --clock \
    --time-str="%H:%M:%S" \
    --date-str="%A, %Y-%m-%d" \
    --time-font="CozetteVector" \
    --date-font="CozetteVector" \
    --time-size=104 \
    --date-size=1 \
    --time-color="${color7:1}" \
    --date-color="${color7:1}" \
    --inside-color="${color0:1}00" \
    --ring-color="${color0:1}00" \
    --ringver-color="${color0:1}00" \
    --ringwrong-color="${color0:1}00" \
    --line-uses-inside \
    --line-color="${color2:1}ff" \
    --separator-color="${color0:1}00" \
    --keyhl-color="${color2:1}ff" \
    --bshl-color="${color1:1}ff" \
    --time-pos="250:270" \
    --date-pos="220:190" \
    --indicator \
    --radius=1

rm "$img" "$blur_img" 
