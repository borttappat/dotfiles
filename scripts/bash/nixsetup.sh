#!/run/current-system/sw/bin/bash

chmod +x ~/dotfiles/scripts/bash/links.sh
~/dotfiles/scripts/bash/links.sh

sudo python ~/dotfiles/scripts/python/nixboot.py
sudo python ~/dotfiles/scripts/python/userswitch.py

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
~/dotfiles/scripts/bash/nixbuild.sh
