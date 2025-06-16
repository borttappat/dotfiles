#!/run/current-system/sw/bin/bash

# Get architecture
ARCH=$(uname -m)
# Get hardware vendor information
VENDOR=$(hostnamectl | grep -i "Hardware Vendor" | awk -F': ' '{print $2}' | xargs)

# Check for ARM architecture (including Apple hardware)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [[ "$VENDOR" == *"Apple"* && ("$ARCH" == *"arm"* || "$ARCH" == *"aarch"*) ]]; then
    echo "Detected ARM architecture, building ARM configuration"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM
    exit $?
fi

# Get hardware information for x86 systems
current_host=$(hostnamectl | grep -i "Hardware Vendor")

# For Razer-hosts
if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#razer

# For Virtual machines
elif echo "$current_host" | grep -q "QEMU"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#VM 

# For ASUS Zenbook specifically (check before general ASUS)
elif echo "$current_host" | grep -qi "zenbook"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook

# For other Asus-hosts
elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#asus

# For Schenker machines
elif echo "$current_host" | grep -q "Schenker"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#xmg

# Check again for Apple vendor as fallback ARM detection
elif [[ "$VENDOR" == *"Apple"* ]]; then
    echo "Detected Apple hardware, assuming ARM architecture"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM

# Fallback for other or new hardware, simpler configuration
else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#default
fi#!/run/current-system/sw/bin/bash
