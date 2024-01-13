#!/run/current-system/sw/bin/bash

# Store the current working directory
original_dir=$(pwd)

# Change directory to /etc/nixos
cd /etc/nixos || exit 1

# Update flake.nix in /etc/nixos
sudo nix flake update

# Update the system
sudo nixos-rebuild switch --flake /etc/nixos#traum

# Return to the original directory
cd "$original_dir" || exit 1

# Optionally, print a message indicating the completion of the script
echo "Script completed. Returned to the original directory: $original_dir"

