#!/run/current-system/sw/bin/bash

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "Starting to link dotfiles..."
echo "Dotfiles directory: $DOTFILES_DIR"
if $CREATE_BACKUP; then
    echo "Mode: Backup existing files as .old"
else
    echo "Mode: Replace existing files (no backups)"
fi
echo "-----------------------------------------"

VERBOSE=false
QUIET=false
CREATE_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-v|--verbose] [-q|--quiet] [--backup]"
            exit 1
            ;;
    esac
done

declare -A FILE_MAPPINGS=(
    ["$DOTFILES_DIR/vim/.vimrc"]="$HOME"
    ["$DOTFILES_DIR/bash/.bashrc"]="$HOME"
    ["$DOTFILES_DIR/zsh/.zshrc"]="$HOME"
    
    ["$DOTFILES_DIR/i3/config.base"]="$HOME/.config/i3"
    ["$DOTFILES_DIR/i3/config1080p"]="$HOME/.config/i3"
    ["$DOTFILES_DIR/i3/config2880"]="$HOME/.config/i3"
    ["$DOTFILES_DIR/i3/config3k"]="$HOME/.config/i3"
    ["$DOTFILES_DIR/i3/config4k"]="$HOME/.config/i3"
    
    ["$DOTFILES_DIR/polybar/config.ini"]="$HOME/.config/polybar"
    
    ["$DOTFILES_DIR/zathura/zathurarc"]="$HOME/.config/zathura"
    
    ["$DOTFILES_DIR/ranger/rifle.conf"]="$HOME/.config/ranger"
    ["$DOTFILES_DIR/ranger/rc.conf"]="$HOME/.config/ranger"
    ["$DOTFILES_DIR/ranger/scope.sh"]="$HOME/.config/ranger"
    
    ["$DOTFILES_DIR/starship/starship.toml"]="$HOME/.config"
    ["$DOTFILES_DIR/htop/htoprc"]="$HOME/.config/htop"
    
    ["$DOTFILES_DIR/joshuto/joshuto.toml"]="$HOME/.config/joshuto"
    ["$DOTFILES_DIR/joshuto/mimetype.toml"]="$HOME/.config/joshuto"
    ["$DOTFILES_DIR/joshuto/preview_file.sh"]="$HOME/.config/joshuto"
    
    ["$DOTFILES_DIR/fish/config.fish"]="$HOME/.config/fish"
    ["$DOTFILES_DIR/fish/fish_variables"]="$HOME/.config/fish"
    
    ["$DOTFILES_DIR/picom/picom.conf"]="$HOME/.config/picom"
    
    ["$DOTFILES_DIR/bin/pomo"]="$HOME/.local/bin"
    ["$DOTFILES_DIR/bin/traumhound"]="$HOME/.local/bin"
    
    ["$DOTFILES_DIR/xorg/.xinitrc"]="$HOME"
    ["$DOTFILES_DIR/xorg/.Xmodmap"]="$HOME"
    ["$DOTFILES_DIR/xorg/.xsessionrc"]="$HOME"
)

create_link() {
    local source_file="$1"
    local target_dir="$2"
    local file_name
    file_name=$(basename "$source_file")
    local target_file="$target_dir/$file_name"
    
    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        if ! $QUIET; then
            echo "Warning: Source file $source_file does not exist, skipping..."
        fi
        return 1
    fi
    
    # Create target directory if it doesn't exist
    if ! mkdir -p "$target_dir" 2>/dev/null; then
        if ! $QUIET; then
            echo "✗ Failed to create directory: $target_dir"
        fi
        return 1
    fi
    
    # Handle existing files/links
    if [[ -e "$target_file" || -L "$target_file" ]]; then
        if [[ -L "$target_file" ]]; then
            # It's a symlink - check if it points to the right place
            local current_target
            current_target=$(readlink "$target_file")
            
            # Convert both paths to absolute paths for comparison
            local abs_current_target abs_source_file
            abs_current_target=$(realpath "$current_target" 2>/dev/null || echo "$current_target")
            abs_source_file=$(realpath "$source_file")
            
            if [[ "$abs_current_target" == "$abs_source_file" ]]; then
                if $VERBOSE && ! $QUIET; then
                    echo "✓ Already linked correctly: $file_name"
                elif ! $QUIET; then
                    echo -n "✓ "
                fi
                return 0
            else
                # Symlink points to wrong location, remove it
                rm "$target_file"
                if $VERBOSE && ! $QUIET; then
                    echo "  Removed incorrect symlink: $file_name"
                fi
            fi
        else
            # It's a regular file or directory
            if $CREATE_BACKUP; then
                # Back up the existing file
                local backup_file="${target_file}.old"
                if [[ ! -e "$backup_file" ]]; then
                    mv "$target_file" "$backup_file"
                    if $VERBOSE && ! $QUIET; then
                        echo "  Created backup: ${file_name}.old"
                    fi
                else
                    # Backup already exists, just remove the file
                    rm -rf "$target_file"
                    if $VERBOSE && ! $QUIET; then
                        echo "  Preserved existing backup: ${file_name}.old"
                    fi
                fi
            else
                # Default behavior: just remove without backing up
                rm -rf "$target_file"
                if $VERBOSE && ! $QUIET; then
                    echo "  Removed existing file: $file_name"
                fi
            fi
        fi
    fi
    
    # Create the symbolic link
    if ln -s "$source_file" "$target_file" 2>/dev/null; then
        if $VERBOSE && ! $QUIET; then
            echo "✓ Created symlink: $file_name -> $source_file"
        elif ! $QUIET; then
            echo -n "✓ "
        fi
        return 0
    else
        if ! $QUIET; then
            echo "✗ Failed to create symlink: $file_name"
        fi
        return 1
    fi
}

TOTAL=${#FILE_MAPPINGS[@]}
echo "Found $TOTAL files to link"

if [[ $TOTAL -eq 0 ]]; then
    echo "Error: No files found in FILE_MAPPINGS array"
    exit 1
fi

SUCCESS=0
FAILED=0
CURRENT=0

for source_file in "${!FILE_MAPPINGS[@]}"; do
    target_dir="${FILE_MAPPINGS[$source_file]}"
    file_name=$(basename "$source_file")
    ((CURRENT++))
    
    if $VERBOSE && ! $QUIET; then
        echo "[$CURRENT/$TOTAL] Processing: $source_file -> $target_dir"
    elif ! $QUIET; then
        echo -n "[$CURRENT/$TOTAL] Linking $file_name... "
    fi
    
    if create_link "$source_file" "$target_dir"; then
        ((SUCCESS++))
        if ! $VERBOSE && ! $QUIET; then
            echo "✓"
        fi
    else
        ((FAILED++))
    fi
done

if ! $QUIET; then
    echo "-----------------------------------------"
    echo "Making scripts executable..."
fi

# Make scripts executable
chmod +x "$DOTFILES_DIR/scripts/bash/"*.sh 2>/dev/null || true
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

if ! $QUIET; then
    echo "Setting proper ownership..."
fi

# Set proper ownership
PRIMARY_GROUP=$(id -gn)

declare -A TARGET_DIRS
for target_dir in "${FILE_MAPPINGS[@]}"; do
    TARGET_DIRS["$target_dir"]=1
done

for dir in "${!TARGET_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        chown -R "$USER:$PRIMARY_GROUP" "$dir" 2>/dev/null || true
    fi
done

if ! $QUIET; then
    echo "-----------------------------------------"
    echo "Linking complete!"
    echo "Successfully linked: $SUCCESS of $TOTAL files"
    if [[ $FAILED -gt 0 ]]; then
        echo "Failed links: $FAILED"
    fi
    if $CREATE_BACKUP; then
        echo "Note: Backups were created with --backup flag"
    fi
fi

exit 0
