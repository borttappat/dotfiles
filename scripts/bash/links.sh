#!/run/current-system/sw/bin/bash

# misc
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/ticker/.ticker.yaml --dir ~/
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/bash/.bashrc --dir ~/
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/vim/.vimrc --dir ~/
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/wallust/wallust.toml --dir ~/.config/wallust

sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/zathura/zathurarc --dir ~/.config/zathura
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/alacritty/alacritty.toml --dir ~/.config/alacritty
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/alacritty/alacritty4k.toml --dir ~/.config/alacritty
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/alacritty/alacritty1080p.toml --dir ~/.config/alacritty

sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/rofi/config.rasi --dir ~/.config/rofi

# i3
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/i3/config --dir ~/.config/i3
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/i3/config.base --dir ~/.config/i3
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/i3/config1080p --dir ~/.config/i3
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/i3/config2880 --dir ~/.config/i3
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/i3/config4k --dir ~/.config/i3

sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/polybar/config.ini --dir ~/.config/polybar
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/joshuto/joshuto.toml --dir ~/.config/joshuto
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/joshuto/mimetype.toml --dir ~/.config/joshuto
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/joshuto/preview_file.sh --dir ~/.config/joshuto

sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/htop/htoprc --dir ~/.config/htop
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/picom/picom.conf --dir ~/.config/picom
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/starship/starship.toml --dir ~/.config

# ~/.local/bin
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/bin/pomo --dir ~/.local/bin
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/bin/traumhound --dir ~/.local/bin

# fish
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/fish/config.fish --dir ~/.config/fish
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/fish/fish_variables  --dir ~/.config/fish

# ranger
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/ranger/rifle.conf --dir ~/.config/ranger
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/ranger/rc.conf --dir ~/.config/ranger
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/ranger/scope.sh --dir ~/.config/ranger

# xorg
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/xorg/.xinitrc --dir ~/
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/xorg/.Xmodmap --dir ~/
sudo python ~/dotfiles/scripts/python/link.py --file ~/dotfiles/xorg/.xsessionrc --dir ~/

# make every script in ~/dotfiles/scripts/bash executeable
sudo chmod +x ~/dotfiles/scripts/bash/*.sh
# make every script in ~/.local/bin executeable
sudo chmod +x ~/.local/bin/*

echo "Files linked"
