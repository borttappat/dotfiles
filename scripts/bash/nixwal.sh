#!/run/current-system/sw/bin/bash

# Define the paths
source_file="$HOME/.cache/wal/colors"
target_file="$HOME/dotfiles/wal/nix-colors"

# Check if source file exists
if [ ! -f "$source_file" ]; then
    echo "Source file '$source_file' not found."
    exit 1
fi

# Remove target file if it exists
if [ -f "$target_file" ]; then
    rm "$target_file"
fi

# Read each line from source file, remove "#" and add quotes
while IFS= read -r line; do
    line="${line//#/}"   # Remove '#'
    line="\"$line\""    # Add quotes
    echo "$line" >> "$target_file"
done < "$source_file"

echo "New file 'nix-colors' created in '~/dotfiles/wal' with modified colors."

