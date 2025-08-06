#!/run/current-system/sw/bin/bash

# User validation and re-personalization script
# Place this in ~/dotfiles/scripts/bash/check-user.sh

set -euo pipefail

readonly DOTFILES_DIR="$(cd "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")" && pwd)"

detect_current_user() {
    local current_user=""
    
    if [[ -n "${SUDO_USER:-}" ]]; then
        current_user="$SUDO_USER"
    elif [[ -n "${USER:-}" && "$USER" != "root" ]]; then
        current_user="$USER"
    elif command -v logname >/dev/null 2>&1; then
        current_user="$(logname 2>/dev/null || echo "")"
    else
        current_user="$(whoami)"
    fi
    
    echo "$current_user"
}

detect_configured_user() {
    # Check users.nix for the configured username
    if [[ -f "$DOTFILES_DIR/modules/users.nix" ]]; then
        grep -o "users\.users\.[a-zA-Z_][a-zA-Z0-9_]*" "$DOTFILES_DIR/modules/users.nix" | head -1 | cut -d'.' -f3
    else
        echo ""
    fi
}

main() {
    echo "🔍 Checking user configuration consistency..."
    echo
    
    local current_user configured_user
    current_user="$(detect_current_user)"
    configured_user="$(detect_configured_user)"
    
    # Validate username format
    if [[ ! "$current_user" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "❌ Invalid username format detected: '$current_user'"
        echo "Username must start with letter/underscore and contain only alphanumeric characters, underscores, and hyphens."
        exit 1
    fi
    
    echo "Current system user: $current_user"
    echo "Configured dotfiles user: $configured_user"
    echo
    
    if [[ "$current_user" == "$configured_user" ]]; then
        echo "✅ Configuration matches current user - no action needed"
        exit 0
    fi
    
    echo "⚠️  User mismatch detected!"
    echo
    echo "This can happen if:"
    echo "  • You're running on a different user account"
    echo "  • You pulled upstream changes that reset the username"  
    echo "  • You copied these dotfiles from another system"
    echo
    
    read -p "Do you want to re-personalize the dotfiles for user '$current_user'? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        echo "🔧 Re-personalizing dotfiles for user '$current_user'..."
        
        # Call the same username replacement function from nixsetup.sh
        # We could extract this to a shared script, but for now, inline it
        
        local files_to_check=(
            "$DOTFILES_DIR/modules/users.nix"
            "$DOTFILES_DIR/modules/arm-vm.nix"
            "$DOTFILES_DIR/modules/virt.nix"
            "$DOTFILES_DIR/modules/pentesting.nix"
            "$DOTFILES_DIR/modules/zephyrus.nix"
            "$DOTFILES_DIR/modules/vm-common.nix"
        )
        
        # Find all .nix files that might contain the old username
        local all_files=()
        for file in "${files_to_check[@]}"; do
            if [[ -f "$file" ]]; then
                all_files+=("$file")
            fi
        done
        
        # Also scan for any other files containing the configured user
        if [[ -n "$configured_user" ]]; then
            while IFS= read -r -d '' file; do
                if [[ -f "$file" ]]; then
                    all_files+=("$file")
                fi
            done < <(find "$DOTFILES_DIR" -type f -name "*.nix" -exec grep -l "$configured_user" {} \; 2>/dev/null | sort -u | tr '\n' '\0')
        fi
        
        # Remove duplicates
        IFS=" " read -r -a unique_files <<< "$(printf '%s\n' "${all_files[@]}" | sort -u | tr '\n' ' ')"
        
        if [[ ${#unique_files[@]} -gt 0 ]]; then
            echo "Updating ${#unique_files[@]} configuration files..."
            
            for file in "${unique_files[@]}"; do
                if [[ -f "$file" ]]; then
                    echo "  Updating: $file"
                    
                    # Create backup
                    cp "$file" "$file.backup-$(date +%Y%m%d-%H%M%S)"
                    
                    # Replace old user with new user using @ as delimiter
                    sed -i \
                        -e "s@users\.users\.$configured_user@users.users.$current_user@g" \
                        -e "s@/home/$configured_user/@/home/$current_user/@g" \
                        -e "s@\"$configured_user\"@\"$current_user\"@g" \
                        -e "s@user = \"$configured_user\"@user = \"$current_user\"@g" \
                        -e "s@chown -R $configured_user:@chown -R $current_user:@g" \
                        -e "s@default = \"$configured_user\"@default = \"$current_user\"@g" \
                        "$file"
                fi
            done
            
            echo
            echo "✅ Re-personalization complete!"
            echo "💡 You can now run 'nixbuild' to apply the updated configuration"
            echo "📁 Changes are tracked in git - use 'git diff' to see modifications"
        else
            echo "No files found to update"
        fi
    else
        echo "Skipped - no changes made"
    fi
}

main "$@"
