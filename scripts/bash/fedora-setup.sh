#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STABLE_KERNEL_VERSION="6.11.8"
VMWARE_VERSION="17.6.0"

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        error "This script is designed for Fedora only."
    fi
    log "Detected Fedora: $(cat /etc/fedora-release)"
}

setup_repositories() {
    log "Setting up Fedora repositories..."
    
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    sudo dnf copr enable -y atim/bottom
    sudo dnf copr enable -y atim/starship
    
    sudo dnf update -y
}

pin_kernel() {
    log "Pinning kernel to version $STABLE_KERNEL_VERSION..."
    
    sudo dnf install -y kernel-$STABLE_KERNEL_VERSION kernel-devel-$STABLE_KERNEL_VERSION kernel-headers-$STABLE_KERNEL_VERSION
    
    log "Adding kernel exclusions to DNF config..."
    echo 'exclude=kernel* kmod-nvidia*' | sudo tee -a /etc/dnf/dnf.conf
    
    sudo grub2-set-default "Fedora Linux (${STABLE_KERNEL_VERSION}) 39 (Workstation Edition)"
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    
    warn "System will boot to kernel $STABLE_KERNEL_VERSION by default"
}

install_vmware() {
    log "Installing VMware Workstation Pro $VMWARE_VERSION..."
    
    sudo dnf install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r) gcc make
    
    local vmware_url="https://download3.vmware.com/software/WKST-${VMWARE_VERSION//.}/VMware-Workstation-Full-${VMWARE_VERSION}-24238078.x86_64.bundle"
    
    if [ ! -f "/tmp/vmware-installer.bundle" ]; then
        log "Downloading VMware Workstation Pro..."
        wget -O /tmp/vmware-installer.bundle "$vmware_url"
    fi
    
    chmod +x /tmp/vmware-installer.bundle
    sudo /tmp/vmware-installer.bundle --console --required --eulas-agreed
    
    log "Setting up VMware services..."
    sudo systemctl enable vmware
    sudo systemctl start vmware
    
    log "Installing VMware package exclusions..."
    echo 'exclude=vmware*' | sudo tee -a /etc/dnf/dnf.conf
    
    rm -f /tmp/vmware-installer.bundle
}

install_core_packages() {
    log "Installing core packages..."
    
    local wm_packages=(
        i3 i3-gaps polybar rofi alacritty
        feh picom dunst flameshot
        xrandr xdotool
    )
    
    local terminal_tools=(
        fish vim neovim tmux
        htop bottom
        ranger joshuto
        git curl wget jq
        figlet fastfetch
        zoxide bat eza fd-find ripgrep ugrep
    )
    
    local development=(
        python3 python3-pip python3-devel
        nodejs npm
        gcc make kernel-devel
        docker docker-compose
    )
    
    local media_apps=(
        mpv zathura zathura-pdf-mupdf
        firefox
    )
    
    local system_tools=(
        NetworkManager-wifi
        util-linux-user
        fuse-overlayfs
    )
    
    sudo dnf install -y "${wm_packages[@]}" "${terminal_tools[@]}" "${development[@]}" "${media_apps[@]}" "${system_tools[@]}"
}

install_rust_tools() {
    log "Installing Rust and Cargo tools..."
    
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        echo 'source ~/.cargo/env' >> ~/.bashrc
    fi
    
    local rust_tools=(
        joshuto
        pipes-rs
        cbonsai
        du-dust
        procs
        bandwhich
    )
    
    cargo install "${rust_tools[@]}"
}

install_python_packages() {
    log "Installing Python packages..."
    
    local python_packages=(
        pywal
        pillow
        requests
        psutil
    )
    
    pip3 install --user "${python_packages[@]}"
    
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
}

install_fonts() {
    log "Installing fonts..."
    
    mkdir -p ~/.local/share/fonts
    
    log "Installing Cozette (primary font)..."
    wget -O /tmp/cozette.zip https://github.com/slavfox/Cozette/releases/latest/download/CozetteFonts.zip
    unzip -o /tmp/cozette.zip -d ~/.local/share/fonts/
    
    log "Installing Hack Nerd Font..."
    wget -O /tmp/hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    unzip -o /tmp/hack.zip -d ~/.local/share/fonts/hack/
    
    log "Installing bitmap fonts from repos..."
    sudo dnf install -y bitmap-fonts terminus-fonts spleen-fonts tamzen-fonts creep2-fonts
    
    log "Installing JetBrains Mono..."
    wget -O /tmp/jetbrains.zip https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip
    unzip -o /tmp/jetbrains.zip -d /tmp/jetbrains/
    cp /tmp/jetbrains/fonts/ttf/*.ttf ~/.local/share/fonts/
    
    fc-cache -fv
    rm -rf /tmp/{cozette.zip,hack.zip,jetbrains.zip,jetbrains}
}

setup_services() {
    log "Setting up system services..."
    
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
}

setup_shell_config() {
    log "Setting up shell configuration..."
    
    if ! grep -q "$(which fish)" /etc/shells; then
        echo "$(which fish)" | sudo tee -a /etc/shells
    fi
    
    mkdir -p ~/.config/fish
    
    echo 'export EDITOR=vim' >> ~/.bashrc
    echo 'export VISUAL=vim' >> ~/.bashrc
    echo 'export BROWSER=firefox' >> ~/.bashrc
    echo 'export TERM=xterm' >> ~/.bashrc
    
    log "Fish shell will be set as default after reboot"
}

create_directories() {
    log "Creating configuration directories..."
    
    local dirs=(
        ~/.config/{i3,polybar,alacritty,rofi,picom,joshuto,htop,zathura,ranger,fish}
        ~/.local/bin
        ~/.cache/wal
        ~/Pictures/wallpapers
        ~/Documents/scripts
    )
    
    mkdir -p "${dirs[@]}"
}

setup_vmware_optimizations() {
    log "Setting up VMware guest optimizations..."
    
    sudo dnf install -y open-vm-tools open-vm-tools-desktop
    sudo systemctl enable vmtoolsd
    
    log "Adding VMware graphics optimizations..."
    echo 'export LIBGL_ALWAYS_SOFTWARE=1' >> ~/.bashrc
    echo 'set -x LIBGL_ALWAYS_SOFTWARE 1' >> ~/.config/fish/config.fish || true
    
    echo 'options vmw_vmci enable_fbdev=1' | sudo tee /etc/modprobe.d/vmware.conf
}

create_script_fixes() {
    log "Creating script path fix helper..."
    
    cat > ~/fix_script_paths.sh << 'EOF'
#!/bin/bash
# Helper script to fix NixOS paths in dotfiles

find ~/dotfiles/scripts -name "*.sh" -type f -exec sed -i 's|#!/run/current-system/sw/bin/bash|#!/usr/bin/bash|g' {} \;
find ~/dotfiles/scripts -name "*.sh" -type f -exec sed -i 's|#!/run/current-system/sw/bin/fish|#!/usr/bin/fish|g' {} \;

echo "Fixed script paths for non-NixOS environment"
EOF
    
    chmod +x ~/fix_script_paths.sh
}

show_next_steps() {
    echo -e "\n${BLUE}=== SETUP COMPLETE ===${NC}"
    echo -e "${GREEN}Installed packages:${NC} i3, polybar, alacritty, fish, and all your essential tools"
    echo -e "${GREEN}Kernel pinned to:${NC} $STABLE_KERNEL_VERSION"
    echo -e "${GREEN}VMware installed:${NC} Version $VMWARE_VERSION"
    echo ""
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo "1. Reboot the system"
    echo "2. After reboot, run: chsh -s \$(which fish)"
    echo "3. Clone dotfiles: git clone https://github.com/borttappat/dotfiles ~/dotfiles"
    echo "4. Fix script paths: ~/fix_script_paths.sh"
    echo "5. Link configs: cd ~/dotfiles && ./scripts/bash/links.sh"
    echo "6. Set wallpaper: wal -i ~/dotfiles/wallpapers/[your-wallpaper]"
    echo "7. Start i3: startx (or set up display manager)"
    echo ""
    echo -e "${YELLOW}IMPORTANT:${NC}"
    echo "- Kernel updates are disabled to prevent VMware breakage"
    echo "- VMware packages are pinned to prevent conflicts"
    echo "- You're added to docker group (takes effect after reboot)"
    echo "- Fish shell will be available after reboot"
}

main() {
    log "Starting Fedora workstation setup with VMware..."
    
    check_fedora
    setup_repositories
    pin_kernel
    install_vmware
    install_core_packages
    install_rust_tools
    install_python_packages
    install_fonts
    create_directories
    setup_vmware_optimizations
    setup_services
    setup_shell_config
    create_script_fixes
    
    show_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
