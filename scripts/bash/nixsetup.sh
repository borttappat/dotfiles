#!/run/current-system/sw/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="/tmp/nixsetup-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
    exit 1
}

detect_user() {
    # Send log messages to stderr so they don't interfere with command substitution
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detecting current user..." | tee -a "$LOG_FILE" >&2
    
    # Try multiple methods to get the actual user (not root when using sudo)
    local detected_user=""
    
    # Method 1: SUDO_USER (most reliable when using sudo)
    if [[ -n "${SUDO_USER:-}" ]]; then
        detected_user="$SUDO_USER"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected user via SUDO_USER: $detected_user" | tee -a "$LOG_FILE" >&2
    # Method 2: USER environment variable
    elif [[ -n "${USER:-}" && "$USER" != "root" ]]; then
        detected_user="$USER"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected user via USER: $detected_user" | tee -a "$LOG_FILE" >&2
    # Method 3: logname command
    elif command -v logname >/dev/null 2>&1; then
        detected_user="$(logname 2>/dev/null || echo "")"
        if [[ -n "$detected_user" ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected user via logname: $detected_user" | tee -a "$LOG_FILE" >&2
        fi
    # Method 4: whoami as fallback
    else
        detected_user="$(whoami)"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected user via whoami: $detected_user" | tee -a "$LOG_FILE" >&2
    fi
    
    # Validate we have a user and it's not root
    if [[ -z "$detected_user" || "$detected_user" == "root" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Could not detect non-root user. Please run without sudo or set SUDO_USER environment variable." | tee -a "$LOG_FILE" >&2
        exit 1
    fi
    
    # Only output the username to stdout (this is what gets captured)
    echo "$detected_user"
}

replace_username_in_files() {
    local target_user="$1"
    log "Replacing all 'traum' references with '$target_user'..."
    
    # Files that contain hardcoded 'traum' references
    local files_to_update=(
        "$DOTFILES_DIR/modules/users.nix"
        "$DOTFILES_DIR/modules/arm-vm.nix"
        "$DOTFILES_DIR/modules/virt.nix"
        "$DOTFILES_DIR/modules/pentesting.nix"
        "$DOTFILES_DIR/modules/zephyrus.nix"
        "$DOTFILES_DIR/modules/vm-common.nix"
    )
    
    # Additional files that might exist and contain 'traum'
    local optional_files=(
        "$DOTFILES_DIR/modules/asus.nix"
        "$DOTFILES_DIR/modules/razer.nix"
        "$DOTFILES_DIR/modules/xmg.nix"
        "$DOTFILES_DIR/modules/zenbook.nix"
    )
    
    # Check for any other files that might contain 'traum'
    log "Scanning for additional files containing 'traum'..."
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            optional_files+=("$file")
        fi
    done < <(find "$DOTFILES_DIR" -type f -name "*.nix" -exec grep -l "traum" {} \; 2>/dev/null | sort -u | tr '\n' '\0')
    
    # Combine all files and remove duplicates
    local all_files=()
    for file in "${files_to_update[@]}" "${optional_files[@]}"; do
        if [[ -f "$file" ]]; then
            all_files+=("$file")
        fi
    done
    
    # Remove duplicates
    IFS=" " read -r -a unique_files <<< "$(printf '%s\n' "${all_files[@]}" | sort -u | tr '\n' ' ')"
    
    if [[ ${#unique_files[@]} -eq 0 ]]; then
        log "No files found containing 'traum' references"
        return
    fi
    
    log "Found ${#unique_files[@]} files to update:"
    for file in "${unique_files[@]}"; do
        log "  - $file"
    done
    
    # Backup and replace in each file
    for file in "${unique_files[@]}"; do
        if [[ -f "$file" ]]; then
            log "Processing: $file"
            
            # Create backup
            cp "$file" "$file.backup-$(date +%Y%m%d-%H%M%S)"
            
            # Perform replacements with proper escaping using @ as delimiter:
            # 1. Replace 'users.users.traum' with 'users.users.TARGET_USER'
            # 2. Replace '/home/traum/' with '/home/TARGET_USER/'
            # 3. Replace '"traum"' with '"TARGET_USER"' 
            # 4. Replace 'user = "traum"' with 'user = "TARGET_USER"'
            # 5. Replace 'chown -R traum:' with 'chown -R TARGET_USER:'
            # 6. Replace 'default = "traum"' with 'default = "TARGET_USER"'
            
            sed -i \
                -e "s@users\.users\.traum@users.users.$target_user@g" \
                -e "s@/home/traum/@/home/$target_user/@g" \
                -e "s@\"traum\"@\"$target_user\"@g" \
                -e "s@user = \"traum\"@user = \"$target_user\"@g" \
                -e "s@chown -R traum:@chown -R $target_user:@g" \
                -e "s@default = \"traum\"@default = \"$target_user\"@g" \
                "$file"
                
            log "✓ Updated: $file"
        fi
    done
    
    log "Username replacement completed successfully"
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check required commands
    command -v git >/dev/null || error "Git not found"
    command -v nixos-rebuild >/dev/null || error "nixos-rebuild not found"
    command -v hostnamectl >/dev/null || error "hostnamectl not found"
    
    # Check dotfiles structure
    [[ -d "$DOTFILES_DIR" ]] || error "Dotfiles directory not found at $DOTFILES_DIR"
    [[ -f "$DOTFILES_DIR/flake.nix" ]] || error "flake.nix not found"
    [[ -f "$DOTFILES_DIR/scripts/bash/links.sh" ]] || error "links.sh not found"
    
    log "All prerequisites satisfied"
}

create_backup() {
    log "Creating backup at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    local configs=(
        "$HOME/.config/i3"
        "$HOME/.config/alacritty" 
        "$HOME/.config/polybar"
        "$HOME/.config/rofi"
        "$HOME/.config/picom"
        "$HOME/.xinitrc"
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.local/bin"
    )
    
    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            log "Backing up $config"
            cp -r "$config" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    log "Backup created successfully"
}

setup_symlinks() {
    log "Setting up symlinks..."
    
    chmod +x "$DOTFILES_DIR/scripts/bash/links.sh"
    "$DOTFILES_DIR/scripts/bash/links.sh" || error "Failed to create symlinks"
    
    log "Symlinks created successfully"
}

build_system() {
    local target_user="$1"
    log "Building NixOS system configuration for user: $target_user"
    
    export USER="$target_user"
    export SUDO_USER="$target_user"
    
    log "Calling nixbuild.sh for hardware detection and system build..."
    
    chmod +x "$DOTFILES_DIR/scripts/bash/nixbuild.sh"
    "$DOTFILES_DIR/scripts/bash/nixbuild.sh" || error "System build failed"
    
    log "System built successfully"
}

cleanup() {
    local target_user="$1"
    log "Setup completed successfully!"
    log "Configuration is now active for user: $target_user"
    log "Backup stored at: $BACKUP_DIR"
    log "Log file: $LOG_FILE"
    log ""
    log "Next steps:"
    log "1. Configuration is already active (using switch)"
    log "2. If on TTY, run 'x' to start X server"  
    log "3. If issues occur, restore from backup at $BACKUP_DIR"
    log ""
    log "Note: Your dotfiles have been personalized for user '$target_user'"
    log "File backups with original 'traum' references are available with .backup-* extension"
}

main() {
    log "Starting NixOS dotfiles setup..."
    log "Dotfiles directory: $DOTFILES_DIR"
    
    # Detect the target user
    local target_user
    target_user="$(detect_user)"
    log "Target user: $target_user"
    
    # Validate username format (basic safety check)
    if [[ ! "$target_user" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        error "Invalid username format detected: '$target_user'. Username must start with letter/underscore and contain only alphanumeric characters, underscores, and hyphens."
    fi
    
    # Check if we need to do username replacement
    if grep -r "traum" "$DOTFILES_DIR/modules/" >/dev/null 2>&1; then
        log "Found 'traum' references in configuration files"
        log "This appears to be the first setup - personalizing for user '$target_user'"
        replace_username_in_files "$target_user"
    else
        log "No 'traum' references found - configuration appears to be already personalized"
    fi
    
    check_prerequisites
    create_backup
    setup_symlinks
    build_system "$target_user"
    cleanup "$target_user"
}

trap 'error "Setup failed at line $LINENO"' ERR

main "$@"
