#!/run/current-system/sw/bin/bash

# I know this is the hackiest solution known to lizardkind, but I clearly don't know how Python uses links/or file paths. It does however, work.
sudo python link_file.py --files alacritty.yml,config.ini,rifle.conf,.bashrc,config.rasi,config,picom.conf,.vimrc,config.fish,cozette.otb,rc.conf,.xinitrc --dirs $HOME/.config/alacritty,$HOME/.config/polybar,$HOME/.config/ranger,$HOME,$HOME/.config/rofi,$HOME/.config/i3,HOME/.config/picom,$HOME/,$HOME/.config/fish,$HOME/.local/share/fonts,$HOME/.config/ranger,$HOME

# additional files can be linked apart from the above blob by running it according to the example below;
#   sudo python link_file.py --files FILE_NAME --dirs DIR_PATH

sudo python link_file.py --files .ticker.yaml --dirs ~/

# links for /etc/nixos
#sudo python link_file.py --file configuration.nix --dirs /etc/nixos
sudo python link_file.py --file flake.nix --dirs /etc/nixos
sudo python link_file.py --file packages.nix --dirs /etc/nixos
sudo python link_file.py --file users.nix --dirs /etc/nixos
sudo python link_file.py --file services.nix --dirs /etc/nixos
sudo python link_file.py --file nixp.nix --dirs /etc/nixos
sudo python link_file.py --file fish_variables  --dirs $HOME/.config/fish

sudo python link_file.py --file MemoryFixed.png --dirs $HOME/Wallpapers
echo "files linked"



