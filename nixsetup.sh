#!/run/current-system/sw/bin/bash

# Adds a line allowing flakes to configuration.nix 
new_line='nix.settings.experimental-features = [ "nix-command" "flakes" ];'

# Define the file and line number
file_path="/etc/nixos/configuration.nix"
line_number=6

# Check if the file exists
if [ -f "$file_path" ]; then
    # Add the new line to the file
    sed -i "${line_number}i$new_line" "$file_path"
    echo "Line added successfully."
else
    echo "File not found: $file_path"
    exit 1
fi

# Links files after git clone 
links.sh

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
sudo nixos-rebuild switch --flake /etc/nixos#traum
