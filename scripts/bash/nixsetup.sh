#!/run/current-system/sw/bin/bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly LOG_FILE="/tmp/nixsetup-$(date +%Y%m%d-%H%M%S).log"

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
    [[ -f "$DOTFILES_DIR/scripts/bash/nixbuild.sh" ]] || error "nixbuild.sh not found"
    
    log "All prerequisites satisfied"
}

check_user_config() {
    log "Running user validation..."
    
    if [[ -f "$DOTFILES_DIR/scripts/bash/check-user.sh" ]]; then
        chmod +x "$DOTFILES_DIR/scripts/bash/check-user.sh"
        "$DOTFILES_DIR/scripts/bash/check-user.sh" || error "User validation failed"
    fi
    
    log "User configuration validated"
}

setup_symlinks() {
    log "Setting up symlinks..."
    
    chmod +x "$DOTFILES_DIR/scripts/bash/links.sh"
    "$DOTFILES_DIR/scripts/bash/links.sh" || error "Failed to create symlinks"
    
    log "Symlinks created successfully"
}

build_system() {
    log "Building NixOS system configuration for user: $(whoami)"
    
    chmod +x "$DOTFILES_DIR/scripts/bash/nixbuild.sh"
    "$DOTFILES_DIR/scripts/bash/nixbuild.sh" || error "System build failed"
    
    log "System built successfully"
}

cleanup() {
    log "Setup completed successfully!"
    log "Configuration is now active for user: $(whoami)"
    log "Log file: $LOG_FILE"
    log ""
    log "Next steps:"
    log "1. Reboot to activate new configuration"
    log "2. Login to TTY and run '\''x'\'' to start X server"
    log "3. Use '\''git status'\'' to see any configuration changes"
}

main() {
    log "Starting NixOS dotfiles setup..."
    log "Dotfiles directory: $DOTFILES_DIR"
    log "Target user: $(whoami)"
    
    check_prerequisites
    check_user_config
    setup_symlinks
    build_system
    cleanup
}

trap '\''error "Setup failed at line $LINENO"'\'' ERR

main "$@"
