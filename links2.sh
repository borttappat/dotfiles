#!/run/current-system/sw/bin/bash

# misc
sudo python link.py --file ~/dotfiles/ticker/.ticker.yaml --dir ~/
sudo python link.py --file ~/dotfiles/bash/.bashrc --dir ~/
sudo python link.py --file ~/dotfiles/vim/.vimrc --dir ~/
sudo python link.py --file ~/dotfiles/xorg/.xinitrc --dir ~/
sudo python link.py --file ~/dotfiles/xorg/.Xmodmap --dir ~/
sudo python link.py --file ~/dotfiles/zathura/zathurarc --dir ~/zathura
sudo python link.py --file ~/dotfiles/alacritty/alacritty.toml --dir ~/.config/alacritty
sudo python link.py --file ~/dotfiles/rofi/config.rasi --dir ~/.config/rofi
sudo python link.py --file ~/dotfiles/i3/config --dir ~/.config/i3
sudo python link.py --file ~/dotfiles/polybar/config.ini --dir ~/.config/polybar
sudo python link.py --file ~/dotfiles/joshuto/joshuto.toml --dir ~/.config/joshuto
sudo python link.py --file ~/dotfiles/picom/picom.conf --dir ~/.config/picom

# fish
sudo python link.py --file ~/dotfiles/fish/config.fish --dir ~/.config/fish
sudo python link.py --file ~/dotfiles/fish/fish_variables  --dir ~/.config/fish

# ranger
sudo python link.py --file ~/dotfiles/ranger/rifle.conf --dir ~/.config/ranger
sudo python link.py --file ~/dotfiles/ranger/rc.conf --dir ~/.config/ranger

# nix
sudo python link.py --file configuration.nix --dir /etc/nixos
sudo python link.py --file flake.nix --dir /etc/nixos
sudo python link.py --file packages.nix --dir /etc/nixos
sudo python link.py --file users.nix --dir /etc/nixos
sudo python link.py --file services.nix --dir /etc/nixos
sudo python link.py --file hosts.nix --dir /etc/nixos
sudo python link.py --file razer.nix --dir /etc/nixos
sudo python link.py --file asus.nix --dir /etc/nixos
sudo python link.py --file steam.nix --dir /etc/nixos



# make every script in ~/dotfiles executeable
sudo chmod +x ~/dotfiles/scripts/bash/*.sh



