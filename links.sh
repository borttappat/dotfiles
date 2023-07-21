#!/run/current-system/sw/bin/bash

# I know this is the hackiest solution known to lizardkind, but I clearly don't know how Python uses links/or file paths. It does however, work.
sudo python link_file.py --files alacritty.yml,config.ini,rifle.conf,.bashrc,config.rasi,config,configuration.nix,picom.conf,.vimrc,config.fish,cozette.otb,rc.conf,.xinitrc --dirs $HOME/.config/alacritty,$HOME/.config/polybar,$HOME/.config/ranger,$HOME,$HOME/.config/rofi,$HOME/.config/i3,/etc/nixos,$HOME/.config/picom,$HOME/,$HOME/.config/fish,$HOME/.local/share/fonts,$HOME/.config/ranger,$HOME

# additional files can be linked apart from the above blob by running it according to the example below;
#   sudo python link_file.py --files FILE_NAME --dirs DIR_PATH

# For some reason, the configuration.nix file tries to run from this directory instead of in /etc/nixos
# To fix this, the file is removed and then hard-linked ti the expected directory
sudo rm /etc/nixos/configuration.nix
sudo ln ~/dotfiles/configuration.nix /etc/nixos/configuration.nix

echo "files linked"


