#!/run/current-system/sw/bin/bash

dotfiles_dir="$HOME/dotfiles"
config_file="configuration.nix"
extra_config="razerconf.txt"

    # Search for the line containing "environment.systemPackages = with pkgs; [" in configuration.nix
    line_number=$(grep -n "environment.systemPackages = with pkgs; \[" "$dotfiles_dir/$config_file" | cut -d ':' -f1)

    # Check if the line was found
    if [ -n "$line_number" ]; then
       line_number=$((line_number + 1))  # Go to the line above the match
       sed -i "${line_number}r $dotfiles_dir/$extra_config" "$dotfiles_dir/$config_file"
       echo "Content of $extra_config pasted into $config_file."
    else
       echo "Line 'environment.systemPackages = with pkgs; [' not found in $config_file"
    fi
