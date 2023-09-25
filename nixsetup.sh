#!/run/current-system/sw/bin/bash

# Links files after git clone 
#sudo chmod +x links.sh
#links.sh
# I know this is the hackiest solution known to lizardkind, but I clearly don't know how Python uses links/or file paths. It does however, work.
sudo python link_file.py --files alacritty.yml,config.ini,rifle.conf,.bashrc,config.rasi,config,picom.conf,.vimrc,config.fish,cozette.otb,rc.conf,.xinitrc --dirs $HOME/.config/alacritty,$HOME/.config/polybar,$HOME/.config/ranger,$HOME,$HOME/.config/rofi,$HOME/.config/i3,$HOME/.config/picom,$HOME/,$HOME/.config/fish,$HOME/.local/share/fonts,$HOME/.config/ranger,$HOME

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

sudo python link_file.py --file fish_variables  --dirs $HOME/.config/fis

sudo python link_file.py --file MemoryFixed.png --dirs $HOME/Wallpapers
echo "Files linked."


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
python i3setup.py

# Rebuilds using flake, edit the name after # to your username after editing flake.nix in the same way
sudo nixos-rebuild switch --flake /etc/nixos#traum
