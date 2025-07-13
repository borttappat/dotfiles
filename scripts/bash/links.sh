#!/run/current-system/sw/bin/bash

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly LINK_SCRIPT="$DOTFILES_DIR/scripts/python/link.py"

echo "Starting to link dotfiles..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Link script: $LINK_SCRIPT"
echo "-----------------------------------------"

# Check if link script exists
if [[ ! -f "$LINK_SCRIPT" ]]; then
    echo "Error: Link script not found at $LINK_SCRIPT"
    exit 1
fi

VERBOSE=false
QUIET=false

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
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-v|--verbose] [-q|--quiet]"
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
    
    if [[ ! -f "$source_file" ]]; then
        if ! $QUIET; then
            echo "Warning: Source file $source_file does not exist, skipping..."
        fi
        return 1
    fi
    
    mkdir -p "$target_dir" 2>/dev/null || true
    
    local link_args=("--file" "$source_file" "--dir" "$target_dir")
    
    if $VERBOSE; then
        link_args+=("--verbose")
    elif $QUIET; then
        link_args+=("--quiet")
    fi
    
    if ! $QUIET && ! $VERBOSE; then
        echo -n "Linking $file_name... "
    fi
    
    if python3 "$LINK_SCRIPT" "${link_args[@]}" 2>/dev/null; then
        if ! $QUIET && ! $VERBOSE; then
            echo "✓"
        elif ! $QUIET; then
            echo "✓ Linked: $file_name"
        fi
        return 0
    else
        if ! $QUIET; then
            echo "✗ Failed: $file_name"
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
    ((CURRENT++))
    
    if $VERBOSE && ! $QUIET; then
        echo "[$CURRENT/$TOTAL] Processing: $source_file -> $target_dir"
    elif ! $QUIET; then
        echo -n "[$CURRENT/$TOTAL] "
    fi
    
    if create_link "$source_file" "$target_dir"; then
        ((SUCCESS++))
    else
        ((FAILED++))
    fi
done

if ! $QUIET; then
    echo "-----------------------------------------"
    echo "Making scripts executable..."
fi

chmod +x "$DOTFILES_DIR/scripts/bash/"*.sh 2>/dev/null || true
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

if ! $QUIET; then
    echo "Setting proper ownership..."
fi

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
fi

exit 0
