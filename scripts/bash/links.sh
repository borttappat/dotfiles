#!/run/current-system/sw/bin/bash

# Exit on error
set -e

# Store the path to the link script
LINK_SCRIPT="$HOME/dotfiles/scripts/python/link.py"
DOTFILES="$HOME/dotfiles"

# Function to create a link with proper error handling
create_link() {
    local source_file="$1"
    local target_dir="$2"
    
    echo "Linking: $(basename "$source_file") → $target_dir"
    if ! sudo python "$LINK_SCRIPT" --file "$source_file" --dir "$target_dir"; then
        echo "Failed to link $source_file"
        return 1
    fi
}

# Define mappings of source files to target directories
declare -A file_mappings=(
    # Configuration groups
    ["zathura"]="$HOME/.config/zathura"
    ["alacritty"]="$HOME/.config/alacritty"
    ["i3"]="$HOME/.config/i3"
    ["polybar"]="$HOME/.config/polybar"
    ["joshuto"]="$HOME/.config/joshuto"
    ["htop"]="$HOME/.config/htop"
    ["picom"]="$HOME/.config/picom"
    ["ranger"]="$HOME/.config/ranger"
    ["fish"]="$HOME/.config/fish"
    ["rofi"]="$HOME/.config/rofi"
    ["misc"]="$HOME"
    ["xorg"]="$HOME"
    ["bin"]="$HOME/.local/bin"
    ["zsh"]="$HOME"
    ["vim"]="$HOME"
)

# Define specific files within each group
declare -A group_files=(
    ["zathura"]="zathurarc"
    ["alacritty"]="alacritty.toml alacritty4k.toml alacritty1080p.toml"
    ["i3"]="config config.base config1080p config2880 config4k"
    ["polybar"]="config.ini"
    ["joshuto"]="joshuto.toml mimetype.toml preview_file.sh"
    ["htop"]="htoprc"
    ["picom"]="picom.conf"
    ["rofi"]="config.rasi"
    ["ranger"]="rifle.conf rc.conf scope.sh"
    ["fish"]="config.fish fish_variables"
    ["xorg"]=".xinitrc .Xmodmap .xsessionrc"
    ["bin"]="pomo traumhound"
    ["zsh"]=".zshrc"
    ["vim"]=".vimrc"
)

# Print header
echo "Starting to create links..."
echo "------------------------"

# Create links for each group
for group in "${!group_files[@]}"; do
    target_dir="${file_mappings[$group]}"
    files="${group_files[$group]}"
    
    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        echo "Created directory: $target_dir"
    fi
    
    # Create links for each file in the group
    for file in $files; do
        if [[ "$file" == *"/"* ]]; then
            # Handle files in subdirectories (like ticker/.ticker.yaml)
            create_link "$DOTFILES/$file" "$target_dir"
        else
            create_link "$DOTFILES/$group/$file" "$target_dir"
        fi
    done
done

# Make scripts executable
echo "------------------------"
echo "Making scripts executable..."
find "$DOTFILES/scripts/bash" -name "*.sh" -type f -exec sudo chmod +x {} \;
find "$HOME/.local/bin" -type f -exec sudo chmod +x {} \;

# Ensure proper ownership
echo "------------------------"
echo "Setting proper ownership..."
# Get the primary group of the current user
PRIMARY_GROUP=$(id -gn)
echo "Using primary group: $PRIMARY_GROUP for user $(whoami)"

for dir in "${file_mappings[@]}"; do
    if [ -d "$dir" ]; then
        sudo chown -R $(whoami):$PRIMARY_GROUP "$dir"
        echo "Set ownership for $dir"
    fi
done

# Print summary
echo "------------------------"
echo "Link creation complete!"
echo "All files properly linked and owned."
