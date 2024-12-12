#!/run/current-system/sw/bin/bash

current_host=$(hostnamectl | grep -i "Hardware Vendor")

if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#razer

elif echo "$current_host" | grep -q "QEMU"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#VM 

elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#asus

else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#default
fi
