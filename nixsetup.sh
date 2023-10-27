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

sudo python link_file.py --files fish_variables  --dirs $HOME/.config/fish

sudo python link_file.py --files MemoryFixed.png --dirs $HOME/Wallpapers


python userswitch.py

# Adds a line allowing flakes to configuration.nix 
new_line='nix.settings.experimental-features = [ "nix-command" "flakes" ];'

# Define the file and line number
file_path="/etc/nixos/configuration.nix"
line_number=6

# Check if the file exists
if [ -f "$file_path" ]; then
    # Add the new line to the file
    sed -i "${line_number}i$new_line" "$file_path"
    echo "Line added successfully."
else
    echo "File not found: $file_path"
    exit 1
fi

# Removes existing xserver-settings and replaces the lines with i3-related lines
#sudo python i3setup.py

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
sudo nixos-rebuild boot --flake /etc/nixos#traum
