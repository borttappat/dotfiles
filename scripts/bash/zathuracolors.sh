#!/run/current-system/sw/bin/bash

# Path to your colors.sh file
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
