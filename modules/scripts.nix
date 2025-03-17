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
      HEX_CODE=$(${gnused}/bin/sed -n '2p' ~/.cache/wal/colors | ${gnused}/bin/sed 's/#//')

      # Check if this is an ASUS machine (by checking if asusctl exists and works)
      if command -v asusctl >/dev/null 2>&1 && asusctl -v >/dev/null 2>&1; then
        echo "ASUS hardware detected, using asusctl"
        # Use asusctl to set LED color
        asusctl led-mode static -c $HEX_CODE
      elif command -v openrgb >/dev/null 2>&1; then
        echo "Using OpenRGB to set device lighting"
        # Use OpenRGB to set device color
        ${openrgb}/bin/openrgb --device 0 --mode static --color "''${HEX_CODE/#/}"
      else
        echo "No compatible RGB control tool found. Skipping RGB lighting control."
      fi

      echo "Backlight set"

      # refresh polybar
      ${polybar}/bin/polybar-msg cmd restart
      echo "Polybar updated"

      # Paste colors from wal-cache ~/dotfiles/wal/nix-colors
      ~/dotfiles/scripts/bash/nixwal.sh
        
      # Change colors for startpage
      # define file paths
      startpage="$HOME/dotfiles/misc/startpage.html"
      colors_css="$HOME/.cache/wal/colors.css"

      # Remove content from lines 12 to 28 in startpage.html
      ${gnused}/bin/sed -i '12,28d' "$startpage"

      # Extract lines 12 to 28 from colors.css and insert them into startpage.html at line 12
      ${gnused}/bin/sed -n '12,28p' "$colors_css" | ${gnused}/bin/sed -i '11r /dev/stdin' "$startpage"

      # Update GitHub Pages colors.css
      echo "Starting GitHub Pages color update..."

      # Define file paths
      site_colors="$HOME/borttappat.github.io/assets/css/colors.css"
      colors_css="$HOME/.cache/wal/colors.css"

      # Ensure the css directory exists
      mkdir -p "$(dirname "$site_colors")"

      # Create or update colors.css
      {
          echo "/* Theme colors - automatically generated */"
          echo ":root {"
          echo "    /* Colors extracted from pywal */"
          # Extract color definitions from pywal
          ${gnused}/bin/sed -n '12,28p' "$colors_css"
          echo ""
          echo "    /* Additional theme variables */"
          echo "    --scanline-color: rgba(12, 12, 12, 0.1);"
          echo "    --flicker-color: rgba(152, 217, 2, 0.01);"
          echo "    --text-shadow-color: var(--color1);"
          echo "    --header-shadow-color: var(--color0);"
          echo "}"
      } > "$site_colors"
      echo "Updated GitHub Pages colors"

      #Zathura-colors
      colors_file="$HOME/.cache/wal/colors.sh"
      zathura_config="$HOME/.config/zathura/zathurarc"

      # Read color values from colors.sh
      source "$colors_file"

      # Update zathurarc with new color values
      ${gnused}/bin/sed -i "s/^set notification-error-bg.*/set notification-error-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set notification-error-fg.*/set notification-error-fg \"$color2\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set notification-warning-bg.*/set notification-warning-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set notification-warning-fg.*/set notification-warning-fg \"$color2\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set notification-bg.*/set notification-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set notification-fg.*/set notification-fg \"$color2\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set completion-group-bg.*/set completion-group-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set completion-group-fg.*/set completion-group-fg \"$color2\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set completion-bg.*/set completion-bg \"$color1\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set completion-fg.*/set completion-fg \"$foreground\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set completion-highlight-bg.*/set completion-highlight-bg \"$color3\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set completion-highlight-fg.*/set completion-highlight-fg \"$foreground\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set index-bg.*/set index-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set index-fg.*/set index-fg \"$color2\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set index-active-bg.*/set index-active-bg \"$color1\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set index-active-fg.*/set index-active-fg \"$foreground\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set inputbar-bg.*/set inputbar-bg \"$color1\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set inputbar-fg.*/set inputbar-fg \"$foreground\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set statusbar-bg.*/set statusbar-bg \"$color3\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set statusbar-fg.*/set statusbar-fg \"$background\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set highlight-color.*/set highlight-color \"$color2\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set highlight-active-color.*/set highlight-active-color \"$color3\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set default-bg.*/set default-bg \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set default-fg.*/set default-fg \"$color2\"/" "$zathura_config"

      ${gnused}/bin/sed -i "s/^set recolor-lightcolor.*/set recolor-lightcolor \"$background\"/" "$zathura_config"
      ${gnused}/bin/sed -i "s/^set recolor-darkcolor.*/set recolor-darkcolor \"$color2\"/" "$zathura_config"

      echo "Zathura colors updated successfully."

      pywalfox update
      echo "Pywalfox updated successfully"

      echo "Colors updated!"
    '')
  ];
}
