#!/run/current-system/sw/bin/bash

sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old

sudo python link_file.py --files alacritty.yml,config.ini,rifle.conf,.bashrc,config.rasi,config,picom.conf,.vimrc,config.fish,cozette.otb,rc.conf,.xinitrc --dirs $HOME/.config/alacritty,$HOME/.config/polybar,$HOME/.config/ranger,$HOME,$HOME/.config/rofi,$HOME/.config/i3,$HOME/.config/picom,$HOME/,$HOME/.config/fish,$HOME/.local/share/fonts,$HOME/.config/ranger,$HOME


sudo python link_file.py --files .ticker.yaml --dirs ~/

# links for /etc/nixos
sudo python link_file.py --files configuration.nix --dirs /etc/nixos
sudo python link_file.py --files flake.nix --dirs /etc/nixos
sudo python link_file.py --files packages.nix --dirs /etc/nixos
sudo python link_file.py --files users.nix --dirs /etc/nixos
sudo python link_file.py --files services.nix --dirs /etc/nixos
sudo python link_file.py --files nixp.nix --dirs /etc/nixos
sudo python link_file.py --files hosts.nix --dirs /etc/nixos

sudo python link_file.py --files fish_variables  --dirs $HOME/.config/fish
sudo python link_file.py --files joshuto.toml --dirs $HOME/.config/joshuto
sudo python link_file.py --files MemoryFixed.png --dirs $HOME/Wallpapers


python userswitch.py
python nixboot.py

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
sudo nixos-rebuild boot --flake /etc/nixos#traum
