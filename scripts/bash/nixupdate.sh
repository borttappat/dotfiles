#!/run/current-system/sw/bin/bash
set -eo pipefail

# Colors for better readability
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Log functions
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# Save current directory
ORIGINAL_DIR=$(pwd)

# Function to handle errors
handle_error() {
    log_error "An error occurred during the update process!"
    cd "$ORIGINAL_DIR"
    exit 1
}

# Set up trap to call handle_error on any error
trap handle_error ERR

# Update flake inputs
update_flake() {
    log_info "Updating flake inputs..."
    cd "$HOME/dotfiles"

    if ! sudo nix flake update; then
        log_error "Failed to update flake inputs"
        return 1
    fi

    log_success "Flake inputs updated"
    return 0
}

# Run garbage collection
run_gc() {
    log_info "Running garbage collection..."

    if ! sudo nix-collect-garbage -d; then
        log_warning "Garbage collection completed with errors"
    else
        log_success "Garbage collection completed"
    fi
}

# Rebuild the system
rebuild_system() {
    log_info "Rebuilding system..."

    if ! "$HOME/dotfiles/scripts/bash/nixbuild.sh"; then
        log_error "Failed to rebuild system"
        return 1
    fi

    log_success "System rebuilt successfully"
    return 0
}

# Main function
main() {
    log_info "Starting NixOS update process..."

    # Ask for confirmation
    read -p "Do you want to update your system? This might take a while. [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Update canceled"
        exit 0
    fi

    # Ask about garbage collection
    read -p "Do you want to run garbage collection? [y/N] " -n 1 -r
    echo
    RUN_GC=$([[ $REPLY =~ ^[Yy]$ ]] && echo true || echo false)

    if update_flake; then
        if $RUN_GC; then
            run_gc
        fi

        if rebuild_system; then
            log_success "Update completed successfully!"
            log_info "You may need to reboot to apply all changes."
        else
            log_error "Update failed during system rebuild."
            exit 1
        fi
    else
        log_error "Update failed during flake update."
        exit 1
    fi

    # Return to original directory
    cd "$ORIGINAL_DIR"
}

# Run the main function
main
