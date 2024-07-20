#!/usr/bin/env bash

# File to store the last window offset
offset_file="/tmp/i3_float_offset"

# Initial offset
x_offset=20
y_offset=20

# Read the last offset if the file exists
if [ -f "$offset_file" ]; then
    read x_offset y_offset < "$offset_file"
fi

# Get current mouse position
eval $(xdotool getmouselocation --shell)

# Calculate new position
x=$((X + x_offset))
y=$((Y + y_offset))

# Increment offset for next window
x_offset=$((x_offset + 20))
y_offset=$((y_offset + 20))

# Reset offset if it gets too large
if [ $x_offset -gt 200 ] || [ $y_offset -gt 200 ]; then
    x_offset=20
    y_offset=20
fi

# Save the new offset
echo "$x_offset $y_offset" > "$offset_file"

# Launch Alacritty at the new position
alacritty --class floating -o window.position.x=$x -o window.position.y=$y
