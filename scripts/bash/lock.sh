#!/run/current-system/sw/bin/bash
# Kill any existing instances of i3lock
killall -q i3lock

# Source wal colors for consistent theming
. "$HOME/.cache/wal/colors.sh"

# Create temporary files
img=/tmp/i3lock.png
blur_img=/tmp/i3lock_blur.png
text_img=/tmp/i3lock_text.png

# Take a screenshot
scrot -o $img

# Apply blur/pixelate effect using magick (ImageMagick 7 syntax)
magick $img -scale 20% -scale 500% $blur_img

# Add text to the upper left corner of the blurred image
magick $blur_img -gravity NorthWest -pointsize 143 -font "CozetteVector" -fill "$color1" \
    -annotate +50+50 'Enter password' $text_img

# Run i3lock-color with custom positions
i3lock \
    -i $text_img \
    --clock \
    --time-str="%H:%M:%S" \
    --date-str="%A, %Y-%m-%d" \
    --layout-font="CozetteVector" \
    --layout-size=26 \
    --time-font="CozetteVector" \
    --date-font="CozetteVector" \
    --time-size=104 \
    --date-size=1 \
    --time-color="${color3:1}" \
    --date-color="${color7:1}" \
    --inside-color="${color0:1}00" \
    --ring-color="${color0:1}00" \
    --ringwrong-color="${color0:1}00" \
    --line-color="${color0:1}ff" \
    --separator-color="${color0:1}00" \
    --keyhl-color="${color3:1}ff" \
    --bshl-color="${color0:1}ff" \
    --time-pos="245:270" \
    --date-pos="220:190" \
    --indicator \
    --radius=50 \
    --ring-color="${color0:1}00" \
    --ringver-color="${color6:1}00" \
    --ringwrong-color="${color7:1}00" \
    --verif-text="Verifying..." \
    --verif-font="CozetteVector" \
    --verif-size=91 \
    --verif-color="$color3" \
    --verif-pos="311:270" \
    --wrong-text="Ah ah ah! You didn't say the magic word!!" \
    --wrong-pos="920:270" \
    --wrong-font="CozetteVector" \
    --wrong-size=91 \
    --wrong-color="$color3" \
    --noinput-text="Err: no input" \
    --ind-pos="328:270" \
    --bar-indicator \
    --bar-step=5 \
    --bar-max-height 5 \
    --bar-color="${color0:1}00"

rm "$img" "$blur_img" 
