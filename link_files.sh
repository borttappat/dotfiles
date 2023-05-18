 #!/bin/bash

    # List of files to link
    files=("config" "configuration.nix" "picom.conf" ".xinitc" "alacritty.yml" "Nervnasa.png" "config.fish" "config.rasi" "cozette.otb" "rc.conf" "rifle.conf" "Schematic.png" "startup.sh")

    # List of directories to link to
    directories=("~/.config/i3" "/etc/nixos" "~/.config/picom" "~/.config" "~/config/alacritty" "~/Wallpapers" "~/.config/fish" "~/.config/rofi" "~/.local/share/fonts" "~/.config/ranger" "~/.config/ranger" "~/Wallpapers" "~/.config/i3/scripts")

    # Loop through the files and directories and call the Python
    script for each combination
    for file in "${files[@]}"
    do
        for dir in "${directories[@]}"
        do
            python link_file.py "$file" "$dir"
        done
    done
