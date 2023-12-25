#!/run/current-system/sw/bin/bash

# misc
sudo python link.py --file .ticker.yaml --dir ~/
sudo python link.py --file .bashrc --dir ~/
sudo python link.py --file .vimrc --dir ~/
sudo python link.py --file .xinitrc --dir ~/
sudo python link.py --file .Xmodmap --dir ~/

sudo python link.py --file alacritty.yml --dir ~/.config/alacritty
sudo python link.py --file config.rasi --dir ~/.config/rofi
sudo python link.py --file config --dir ~/.config/i3
sudo python link.py --file config.ini --dir ~/.config/polybar
sudo python link.py --file joshuto.toml --dir ~/.config/joshuto
sudo python link.py --file picom.conf --dir ~/.config/picom

# fish
sudo python link.py --file config.fish --dir ~/.config/fish
sudo python link.py --file fish_variables  --dir ~/.config/fish

# ranger
sudo python link.py --file rifle.comf --dir ~/.config/ranger
sudo python link.py --file rc.conf --dir ~/.config/ranger

# nix
sudo python link.py --file configuration.nix --dir /etc/nixos
sudo python link.py --file flake.nix --dir /etc/nixos
sudo python link.py --file packages.nix --dir /etc/nixos
sudo python link.py --file users.nix --dir /etc/nixos
sudo python link.py --file services.nix --dir /etc/nixos
sudo python link.py --file nixp.nix --dir /etc/nixos
sudo python link.py --file hosts.nix --dir /etc/nixos
