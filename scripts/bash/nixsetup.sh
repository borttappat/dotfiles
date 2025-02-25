#!/run/current-system/sw/bin/bash

set -eo pipefail  # Exit on errors and undefined variables

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

# Check for required utilities
check_requirements() {
    log_info "Checking requirements..."
    for cmd in git python3 sudo; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd is required but not installed. Exiting."
            exit 1
        fi
    done
    log_success "All requirements met"
}

# Back up existing configuration
backup_config() {
    log_info "Backing up existing configuration..."
    local timestamp=$(date +%Y%m%d%H%M%S)
    local backup_dir="/tmp/nixos-backup-${timestamp}"
    
    if [ -d /etc/nixos ]; then
        sudo mkdir -p "$backup_dir"
        sudo cp -r /etc/nixos/* "$backup_dir"
        log_success "Configuration backed up to $backup_dir"
    else
        log_warning "No existing configuration found at /etc/nixos"
    fi
}

# Create symlinks to dotfiles
create_links() {
    log_info "Creating symlinks..."
    if [ -f "$HOME/dotfiles/scripts/bash/links.sh" ]; then
        chmod +x "$HOME/dotfiles/scripts/bash/links.sh"
        "$HOME/dotfiles/scripts/bash/links.sh"
        log_success "Links created successfully"
    else
        log_error "links.sh not found!"
        exit 1
    fi
}

# Setup boot configuration
setup_boot() {
    log_info "Setting up boot configuration..."
    if [ -f "$HOME/dotfiles/scripts/python/nixboot.py" ]; then
        sudo python3 "$HOME/dotfiles/scripts/python/nixboot.py"
        log_success "Boot configuration set up"
    else
        log_error "nixboot.py not found!"
        exit 1
    fi
}

# Update username in configuration
update_username() {
    log_info "Updating username in configuration files..."
    if [ -f "$HOME/dotfiles/scripts/python/userswitch.py" ]; then
        sudo python3 "$HOME/dotfiles/scripts/python/userswitch.py"
        log_success "Username updated in configuration files"
    else
        log_error "userswitch.py not found!"
        exit 1
    fi
}

# Detect and build for the specific hardware
build_system() {
    log_info "Detecting hardware and building system..."
    local hw_vendor=$(hostnamectl | grep -i "Hardware Vendor" || echo "Unknown")
    
    if echo "$hw_vendor" | grep -q "Razer"; then
        log_info "Razer hardware detected, building with razer profile"
        sudo nixos-rebuild boot --flake "$HOME/dotfiles#razer" || {
            log_error "Build failed for Razer profile"
            return 1
        }
    elif echo "$hw_vendor" | grep -q "QEMU"; then
        log_info "Virtual machine detected, building with VM profile"
        sudo nixos-rebuild boot --flake "$HOME/dotfiles#VM" || {
            log_error "Build failed for VM profile"
            return 1
        }
    elif echo "$hw_vendor" | grep -q "ASUS"; then
        log_info "ASUS hardware detected, building with asus profile"
        sudo nixos-rebuild boot --flake "$HOME/dotfiles#asus" || {
            log_error "Build failed for ASUS profile"
            return 1
        }
    elif echo "$hw_vendor" | grep -q "Schenker"; then
        log_info "XMG/Schenker hardware detected, building with xmg profile"
        sudo nixos-rebuild boot --flake "$HOME/dotfiles#xmg" || {
            log_error "Build failed for XMG profile"
            return 1
        }
    else
        log_warning "Unknown hardware: $hw_vendor"
        log_info "Building with default profile"
        sudo nixos-rebuild boot --flake "$HOME/dotfiles#default" || {
            log_error "Build failed for default profile"
            return 1
        }
    fi
    
    log_success "System built successfully"
    return 0
}

# Main function to run all steps
main() {
    log_info "Starting NixOS setup..."
    
    check_requirements
    backup_config
    create_links
    setup_boot
    update_username
    
    if build_system; then
        log_success "Setup completed successfully!"
        log_info "Please reboot your system to use the new configuration."
    else
        log_error "Setup failed during system build."
        exit 1
    fi
}

# Run the main function
main
