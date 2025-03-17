#!/run/current-system/sw/bin/bash

# Define paths to files
nix_colors_file="$HOME/dotfiles/wal/nix-colors"
nixos_colors_file="$HOME/dotfiles/modules/colors.nix"
temp_colors_file="/tmp/colors_temp.nix"

# Read lines from nix-colors file
nix_colors=$(<"$nix_colors_file")

# Remove lines 7 to 21 from colors.nix
sed '7,21d' "$nixos_colors_file" > "$temp_colors_file"

# Parse nix-colors into colors.nix starting at line 7
sed -i '7r /dev/stdin' "$temp_colors_file" <<< "$nix_colors"

# Replace colors.nix with the modified temporary file
mv "$temp_colors_file" "$nixos_colors_file"

echo "Script completed successfully."

