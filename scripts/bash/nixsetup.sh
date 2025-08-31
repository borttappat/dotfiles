#!/run/current-system/sw/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="/tmp/nixsetup-$(date +%Y%m%d-%H%M%S).log"
readonly CURRENT_USER="$(whoami)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    command -v git >/dev/null || error "Git not found"
    command -v nixos-rebuild >/dev/null || error "nixos-rebuild not found"
    
    [[ -d "$DOTFILES_DIR" ]] || error "Dotfiles directory not found at $DOTFILES_DIR"
    [[ -f "$DOTFILES_DIR/flake.nix" ]] || error "flake.nix not found"
    [[ -f "$DOTFILES_DIR/scripts/bash/links.sh" ]] || error "links.sh not found"
    
    log "All prerequisites satisfied"
}

replace_username() {
    log "Replacing 'traum' with current user '$CURRENT_USER' throughout dotfiles..."
    
    # Find all files (excluding .git directory and binary files)
    find "$DOTFILES_DIR" -type f -not -path "*/.git/*" -not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" -not -name "*.gif" -not -name "*.ico" -not -name "*.svg" -exec grep -l "traum" {} \; 2>/dev/null | while read -r file; do
        log "Updating file: $file"
        sed -i "s/traum/$CURRENT_USER/g" "$file"
    done
    
    log "Username replacement completed"
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
    log "Building NixOS system configuration for user: $CURRENT_USER"
    
    export USER="${USER:-$CURRENT_USER}"
    export SUDO_USER="${SUDO_USER:-$USER}"
    
    log "Calling nixbuild.sh for hardware detection and system build..."
    
    chmod +x "$DOTFILES_DIR/scripts/bash/nixbuild.sh"
    "$DOTFILES_DIR/scripts/bash/nixbuild.sh" || error "System build failed"
    
    log "System built successfully"
}

cleanup() {
    log "Setup completed successfully!"
    log "Configuration is now active for user: $CURRENT_USER"
    log "Backup stored at: $BACKUP_DIR"
    log "Log file: $LOG_FILE"
    log ""
    log "Next steps:"
    log "1. Configuration is already active (using switch)"
    log "2. If on TTY, run 'x' to start X server"
    log "3. If issues occur, restore from backup at $BACKUP_DIR"
}

main() {
    log "Starting NixOS dotfiles setup..."
    log "Dotfiles directory: $DOTFILES_DIR"
    log "Target user: $CURRENT_USER"
    
    check_prerequisites
    replace_username
    create_backup
    setup_symlinks
    build_system
    cleanup
}

trap 'error "Setup failed at line $LINENO"' ERR

main "$@"
