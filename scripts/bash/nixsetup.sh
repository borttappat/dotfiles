#!/run/current-system/sw/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to check the exit status of the last command
check_status() {
    if [ $? -eq 0 ]; then
        echo "Step successful: $1"
    else
        echo "Failed to run: $1"
        exit 1
    fi
}

# Make links executable and use links.sh to link files to their expected dir
chmod +x ~/dotfiles/scripts/bash/links.sh
~/dotfiles/scripts/bash/links.sh
check_status "Make links executable and run links.sh"

# Replace instances of "traum" with current username in config files
sudo python ~/dotfiles/scripts/python/userswitch.py
check_status "Run userswitch.py"

# Detect hardware and rebuild system
current_host=$(hostnamectl | grep -i "Hardware Vendor")

if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#razer -v
    check_status "NixOS rebuild for Razer"
elif echo "$current_host" | grep -q "QEMU"; then
    sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#VM -v
    check_status "NixOS rebuild for QEMU"
elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#asus -v
    check_status "NixOS rebuild for ASUS"
else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#default -v
    check_status "NixOS rebuild for unknown host"
fi

echo "Success: All steps completed successfully"
