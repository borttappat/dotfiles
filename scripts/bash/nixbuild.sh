#!/run/current-system/sw/bin/bash

current_host=$(hostnamectl | grep -i "Hardware Vendor")

# For Razer-hosts
if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#razer

# For Virtual machines
elif echo "$current_host" | grep -q "QEMU"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#VM 

# For Asus-hosts
elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#asus

# For Schenker machines
elif echo "$current_host" | grep -q "Schenker"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#xmg

# Fallback for other or new hardware, simpler configuration
else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#default
fi
