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

# Makes links executable and uses the links.sh script to call link.py in python-scripts to link files out to their expected dir.
chmod +x ~/dotfiles/scripts/bash/links.sh
~/dotfiles/scripts/bash/links.sh
check_status "Make links executable and run links.sh"

# nixboot.py copies the relevant user specific content of /etc/configuration.nix and /etc/nixos/hardware-configuration.nix 
# into ~/dotfiles/boot.nix in order to match the current systems boot-configuration and other settings generated upon install
sudo python ~/dotfiles/scripts/python/nixboot.py
check_status "Run nixboot.py"

# replaces every instance of "traum" with the current users username in configuration.nix and users.nix
# sets permissions of every file in ~/ to the current user, instead of root.
sudo python ~/dotfiles/scripts/python/userswitch.py
check_status "Run userswitch.py"

# Get architecture
ARCH=$(uname -m)
# Get hardware information 
VENDOR=$(hostnamectl | grep -i "Hardware Vendor" | awk -F': ' '{print $2}' | xargs)

# Check if we're on ARM (including checking the vendor for Apple)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [[ "$VENDOR" == *"Apple"* && ("$ARCH" == *"arm"* || "$ARCH" == *"aarch"*) ]]; then
    echo "Detected ARM architecture, building ARM configuration"
    sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#armVM -v
    check_status "NixOS rebuild for ARM"
    exit 0
fi

# For x86_64 systems, use the normal detection logic
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
    # Check again for Apple vendor as fallback ARM detection
    if [[ "$VENDOR" == *"Apple"* ]]; then
        echo "Detected Apple hardware, assuming ARM architecture"
        sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#armVM -v
        check_status "NixOS rebuild for Apple ARM"
    else
        echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
        sudo nixos-rebuild boot --show-trace --flake ~/dotfiles#default -v
        check_status "NixOS rebuild for unknown host"
    fi
fi

echo "Success: All steps completed successfully"
