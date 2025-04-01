#!/usr/bin/env bash

# Links script with progress indication and ownership control
LINK_SCRIPT="$HOME/dotfiles/scripts/python/link.py"

echo "Starting to link dotfiles..."
echo "-----------------------------------------"

# Check if verbose mode was requested
VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

# Array of files to link and their target directories
# Format: "source_file:target_dir"
FILES=(
    "$HOME/dotfiles/vim/.vimrc:$HOME"

    #"$HOME/dotfiles/i3/config:$HOME/.config/i3"
    "$HOME/dotfiles/i3/config.base:$HOME/.config/i3"
    "$HOME/dotfiles/i3/config1080p:$HOME/.config/i3"
    "$HOME/dotfiles/i3/config2880:$HOME/.config/i3"
    "$HOME/dotfiles/i3/config4k:$HOME/.config/i3"
    
    "$HOME/dotfiles/polybar/config.ini:$HOME/.config/polybar"
    
    "$HOME/dotfiles/zathura/zathurarc:$HOME/.config/zathura"
    
    "$HOME/dotfiles/ranger/rifle.conf:$HOME/.config/ranger"
    "$HOME/dotfiles/ranger/rc.conf:$HOME/.config/ranger"
    "$HOME/dotfiles/ranger/scope.sh:$HOME/.config/ranger"
    
    "$HOME/dotfiles/starship/starship.toml:$HOME/.config"
    "$HOME/dotfiles/htop/htoprc:$HOME/.config/htop"
    
    "$HOME/dotfiles/joshuto/joshuto.toml:$HOME/.config/joshuto"
    "$HOME/dotfiles/joshuto/mimetype.toml:$HOME/.config/joshuto"
    "$HOME/dotfiles/joshuto/preview_file.sh:$HOME/.config/joshuto"
    
    "$HOME/dotfiles/rofi/config.rasi:$HOME/.config/rofi"
    
    "$HOME/dotfiles/bin/pomo:$HOME/.local/bin"
    "$HOME/dotfiles/bin/traumhound:$HOME/.local/bin"
    
    "$HOME/dotfiles/alacritty/alacritty.toml:$HOME/.config/alacritty"
    "$HOME/dotfiles/alacritty/alacritty4k.toml:$HOME/.config/alacritty"
    "$HOME/dotfiles/alacritty/alacritty1080p.toml:$HOME/.config/alacritty"
    
    "$HOME/dotfiles/fish/config.fish:$HOME/.config/fish"
    "$HOME/dotfiles/fish/fish_variables:$HOME/.config/fish"
    
    "$HOME/dotfiles/zsh/.zshrc:$HOME"
    
    "$HOME/dotfiles/picom/picom.conf:$HOME/.config/picom"
    
    "$HOME/dotfiles/xorg/.xinitrc:$HOME"
    "$HOME/dotfiles/xorg/.Xmodmap:$HOME"
    "$HOME/dotfiles/xorg/.xsessionrc:$HOME"
    # Add more files as needed
)

# Total number of files
TOTAL=${#FILES[@]}
SUCCESS=0

# Process each file
for i in "${!FILES[@]}"; do
    # Split the entry into source and target
    entry="${FILES[$i]}"
    source_file="${entry%%:*}"
    target_dir="${entry##*:}"
    
    # Display progress
    file_name=$(basename "$source_file")
    echo -n "[$((i+1))/$TOTAL] Linking $file_name... "
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_dir" 2>/dev/null
    
    # Run the link script
    if $VERBOSE; then
        sudo python "$LINK_SCRIPT" --file "$source_file" --dir "$target_dir" --verbose
    else
        sudo python "$LINK_SCRIPT" --file "$source_file" --dir "$target_dir" --quiet
    fi
    
    # Check if linking was successful
    if [ $? -eq 0 ]; then
        echo "Done"
        ((SUCCESS++))
    else
        echo "Failed"
    fi
done

echo "-----------------------------------------"
echo "Making scripts executable..."
sudo chmod +x "$HOME/dotfiles/scripts/bash/"*.sh
sudo chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

# Set proper ownership
echo "-----------------------------------------"
echo "Setting proper ownership..."

# Get user's primary group
PRIMARY_GROUP=$(id -gn)
echo "Using primary group: $PRIMARY_GROUP for user $USER"

# Collect unique target directories
declare -A TARGET_DIRS
for entry in "${FILES[@]}"; do
    target_dir="${entry##*:}"
    TARGET_DIRS["$target_dir"]=1
done

# Set ownership for all target directories
for dir in "${!TARGET_DIRS[@]}"; do
    if $VERBOSE; then
        echo "Setting ownership for $dir..."
    fi
    sudo chown -R "$USER:$PRIMARY_GROUP" "$dir"
done

echo "-----------------------------------------"
echo "Linking complete!"
echo "Successfully linked $SUCCESS of $TOTAL files"
