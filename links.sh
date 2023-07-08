#!/run/current-system/sw/bin/bash

# I know this is the hackiest solution known to lizardkind, but I clearly don't know how Python uses links/or file paths
sudo python link_file.py --files alacritty.yml,config.ini,rifle.conf,.bashrc,config.rasi,config,configuration.nix,picom.conf,.vimrc,config.fish,cozette.otb,rc.conf,.xinitrc --dirs /home/traum/.config/alacritty,/home/traum/.config/polybar,/home/traum/.config/ranger,/home/traum,/home/traum/.config/rofi,/home/traum/.config/i3,/etc/nixos,/home/traum/.config/picom,/home/traum/,/home/traum/.config/fish,/home/traum/.local/share/fonts,/home/traum/.config/ranger,/home/traum

# Again, don't@me, Python lins file in weird ways and I just want this to work right now
sudo rm /etc/nixos/configuration.nix
sudo ln ~/dotfiles/configuration.nix /etc/nixos/configuration.nix

echo "files linked"


