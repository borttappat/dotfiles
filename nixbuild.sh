#!/run/current-system/sw/bin/bash

#!/bin/bash

current_host=$(neofetch --stdout | grep Host)

if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild switch --flake /etc/nixos#razer
elif echo "$current_host" | grep -q "KVM/QEMU"; then
    sudo nixos-rebuild switch --flake /etc/nixos#WM
elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild switch --flake /etc/nixos#asus
else
    echo "Unknown host: $current_host, build manually or modify flake.nix"
fi
