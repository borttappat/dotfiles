#!/run/current-system/sw/bin/bash

current_host=$(hostnamectl | grep -i "Hardware Vendor")

if echo "$current_host" | grep -q "Razer"; then
    #sudo nixos-rebuild switch --show-trace --flake /etc/nixos#razer
    sudo nixos-rebuild switch --show-trace --flake ~/dotfiles#razer -v

elif echo "$current_host" | grep -q "QEMU"; then
    sudo nixos-rebuild switch --show-trace --flake /etc/nixos#WM -v 

elif echo "$current_host" | grep -q "ASUS"; then
    #sudo nixos-rebuild switch --flake /etc/nixos#asus
    sudo nixos-rebuild switch --show-trace --flake ~/dotfiles#asus -v
else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    #sudo nixos-rebuild switch --show-trace --flake /etc/nixos#default
    sudo nixos-rebuild switch --show-trace --flake ~/dotfiles#default -v
fi
