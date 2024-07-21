#!/usr/bin/env bash

# Path to the wal colors file
COLOR_FILE="$HOME/.cache/wal/colors"

# Read the first color from the file
color=$(head -n 1 "$COLOR_FILE")

# Remove any leading '#' if present
color="${color#\#}"

# Add transparency (50% opaque) and ensure a single '#' at the beginning
echo "#80${color}"
