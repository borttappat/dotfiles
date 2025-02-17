#!/run/current-system/sw/bin/bash

# Exit on error
set -e

# Store the path to the restore script
RESTORE_SCRIPT="$HOME/dotfiles/scripts/python/restore.py"

# Function to restore a link with proper error handling
restore_link() {
    local target_dir="$1"
    local filename="$2"
    
    echo "Restoring: $filename in $target_dir"
    if ! sudo python "$RESTORE_SCRIPT" --dir "$target_dir" --file "$filename"; then
        echo "Failed to restore $filename"
        return 1
    fi
}

# Create arrays of source files and their target directories
declare -A file_mappings=(
    # misc
    ["$HOME/dotfiles/ticker/.ticker.yaml"]="$HOME"
    ["$HOME/dotfiles/bash/.bashrc"]="$HOME"
    ["$HOME/dotfiles/vim/.vimrc"]="$HOME"
    ["$HOME/dotfiles/wallust/wallust.toml"]="$HOME/.config/wallust"
    
    # Config files
    ["$HOME/dotfiles/zathura/zathurarc"]="$HOME/.config/zathura"
    ["$HOME/dotfiles/alacritty/alacritty.toml"]="$HOME/.config/alacritty"
    ["$HOME/dotfiles/alacritty/alacritty4k.toml"]="$HOME/.config/alacritty"
    ["$HOME/dotfiles/alacritty/alacritty1080p.toml"]="$HOME/.config/alacritty"
    ["$HOME/dotfiles/rofi/config.rasi"]="$HOME/.config/rofi"
    ["$HOME/dotfiles/i3/config"]="$HOME/.config/i3"
    ["$HOME/dotfiles/polybar/config.ini"]="$HOME/.config/polybar"
    ["$HOME/dotfiles/joshuto/joshuto.toml"]="$HOME/.config/joshuto"
    ["$HOME/dotfiles/joshuto/mimetype.toml"]="$HOME/.config/joshuto"
    ["$HOME/dotfiles/joshuto/preview_file.sh"]="$HOME/.config/joshuto"
    ["$HOME/dotfiles/htop/htoprc"]="$HOME/.config/htop"
    ["$HOME/dotfiles/picom/picom.conf"]="$HOME/.config/picom"
    ["$HOME/dotfiles/starship/starship.toml"]="$HOME/.config"
    
    # Local bin files
    ["$HOME/dotfiles/bin/pomo"]="$HOME/.local/bin"
    ["$HOME/dotfiles/bin/traumhound"]="$HOME/.local/bin"
    
    # Fish config
    ["$HOME/dotfiles/fish/config.fish"]="$HOME/.config/fish"
    ["$HOME/dotfiles/fish/fish_variables"]="$HOME/.config/fish"
    
    # Ranger config
    ["$HOME/dotfiles/ranger/rifle.conf"]="$HOME/.config/ranger"
    ["$HOME/dotfiles/ranger/rc.conf"]="$HOME/.config/ranger"
    ["$HOME/dotfiles/ranger/scope.sh"]="$HOME/.config/ranger"
    
    # Xorg files
    ["$HOME/dotfiles/xorg/.xinitrc"]="$HOME"
    ["$HOME/dotfiles/xorg/.Xmodmap"]="$HOME"
    ["$HOME/dotfiles/xorg/.xsessionrc"]="$HOME"
)

# Print header
echo "Starting to restore backups..."
echo "------------------------"

# Counter for successful restores
successful_restores=0
failed_restores=0

# Restore backups
for source_file in "${!file_mappings[@]}"; do
    target_dir="${file_mappings[$source_file]}"
    filename=$(basename "$source_file")
    if restore_link "$target_dir" "$filename"; then
        ((successful_restores++))
    else
        ((failed_restores++))
    fi
done

# Print summary
echo "------------------------"
echo "Backup restoration complete!"
echo "Successful restores: $successful_restores"
if [ $failed_restores -gt 0 ]; then
    echo "Failed restores: $failed_restores"
fi
