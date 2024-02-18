#!/run/current-system/sw/bin/bash

sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old

sudo ~/dotfiles/scripts/bash/links.sh

sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/boot.nix --dir /etc/nixos
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/nixp.nix --dir /etc/nixos
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/colors.nix --dir /etc/nixos




sudo python ~/dotfiles/scripts/python/userswitch.py
sudo python ~/dotfiles/scripts/python/nixboot.py

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
sudo ~/dotfiles/scripts/bash/nixbuild.sh
