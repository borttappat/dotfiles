{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "walrgb" ''
      #!/run/current-system/sw/bin/bash

      # Check if the file path argument is provided
      if [ -z "$1" ]; then
        echo "Usage: walrgb /path/to/file"
        exit 1
      fi

      # Extract specific part of the path using parameter expansion
      file_path="$1"
      file_name="''${file_path##*/}"
      directory="''${file_path%/*}"

      # Print the extracted parts of the path
      echo "File path: $file_path"
      echo "File name: $file_name"
      echo "Directory: $directory"

      # run wal with the specified image path
      echo "Setting colorscheme according to $file_path"
      ${pywal}/bin/wal -q -i "''${file_path}"
      echo "Colorscheme set"

      # Convert line 2 of the wal colors cache to a hex code 
      # for openrgb to read and then runs openrgb with said code
      HEX_CODE=$(${gnused}/bin/sed -n '2p' ~/.cache/wal/colors | ${gnused}/bin/sed 's/#//')
      ${openrgb}/bin/openrgb --device 0 --mode static --color "''${HEX_CODE/#/}"
      echo "Backlight set"

      # refresh polybar
      ${polybar}/bin/polybar-msg cmd restart
      echo "Polybar updated"

      # Paste colors from wal-cache ~/dotfiles/wal/nix-colors
      ~/dotfiles/scripts/bash/nixwal.sh

      # Update /etc/nixos/colors.nix with colors from ~/dotfiles/wal/nix-color
      ${python3}/bin/python ~/dotfiles/scripts/python/nixcolors.py

        # Define file paths
        startpage="$HOME/dotfiles/misc/startpage.html"
        colors_css="$HOME/.cache/wal/colors.css"

        # Remove content from lines 12 to 28 in startpage.html
        sed -i '12,28d' "$startpage"

        # Extract lines 12 to 28 from colors.css and insert them into startpage.html at line 12
        sed -n '12,28p' "$colors_css" | sed -i '11r /dev/stdin' "$startpage"


        # Path to your colors.sh file


        #Zathura-colors

        colors_file="$HOME/.cache/wal/colors.sh"

        # Path to your zathurarc file
        zathura_config="$HOME/.config/zathura/zathurarc"

        # Read color values from colors.sh
        source "$colors_file"

        # Update zathurarc with new color values
        sed -i "s/^set notification-error-bg.*/set notification-error-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set notification-error-fg.*/set notification-error-fg \"$color2\"/" "$zathura_config"
        sed -i "s/^set notification-warning-bg.*/set notification-warning-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set notification-warning-fg.*/set notification-warning-fg \"$color2\"/" "$zathura_config"
        sed -i "s/^set notification-bg.*/set notification-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set notification-fg.*/set notification-fg \"$color2\"/" "$zathura_config"

        sed -i "s/^set completion-group-bg.*/set completion-group-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set completion-group-fg.*/set completion-group-fg \"$color2\"/" "$zathura_config"
        sed -i "s/^set completion-bg.*/set completion-bg \"$color1\"/" "$zathura_config"
        sed -i "s/^set completion-fg.*/set completion-fg \"$foreground\"/" "$zathura_config"
        sed -i "s/^set completion-highlight-bg.*/set completion-highlight-bg \"$color3\"/" "$zathura_config"
        sed -i "s/^set completion-highlight-fg.*/set completion-highlight-fg \"$foreground\"/" "$zathura_config"

        sed -i "s/^set index-bg.*/set index-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set index-fg.*/set index-fg \"$color2\"/" "$zathura_config"
        sed -i "s/^set index-active-bg.*/set index-active-bg \"$color1\"/" "$zathura_config"
        sed -i "s/^set index-active-fg.*/set index-active-fg \"$foreground\"/" "$zathura_config"

        sed -i "s/^set inputbar-bg.*/set inputbar-bg \"$color1\"/" "$zathura_config"
        sed -i "s/^set inputbar-fg.*/set inputbar-fg \"$foreground\"/" "$zathura_config"

        sed -i "s/^set statusbar-bg.*/set statusbar-bg \"$color3\"/" "$zathura_config"
        sed -i "s/^set statusbar-fg.*/set statusbar-fg \"$background\"/" "$zathura_config"

        sed -i "s/^set highlight-color.*/set highlight-color \"$color2\"/" "$zathura_config"
        sed -i "s/^set highlight-active-color.*/set highlight-active-color \"$color3\"/" "$zathura_config"

        sed -i "s/^set default-bg.*/set default-bg \"$background\"/" "$zathura_config"
        sed -i "s/^set default-fg.*/set default-fg \"$color2\"/" "$zathura_config"

        sed -i "s/^set recolor-lightcolor.*/set recolor-lightcolor \"$background\"/" "$zathura_config"
        sed -i "s/^set recolor-darkcolor.*/set recolor-darkcolor \"$color2\"/" "$zathura_config"

        echo "Zathura colors updated successfully."


        echo "Colors updated!"
    '')
  ];
}
