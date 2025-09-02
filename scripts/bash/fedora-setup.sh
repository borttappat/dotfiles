#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

install_core_packages() {
    log "Installing window manager and desktop environment..."
    
    local wm_packages=(
        i3 polybar rofi alacritty
        feh picom dunst flameshot
        xrandr xdotool xorg-x11-server-Xorg xinit
    )
    
    sudo dnf install -y "${wm_packages[@]}"
    
    log "Installing terminal tools and shell..."
    
    local terminal_tools=(
        fish vim neovim tmux
        htop ranger
        git curl wget jq
        figlet fastfetch
    )
    
    sudo dnf install -y "${terminal_tools[@]}"
    
    log "Installing modern CLI tools..."
    
    local modern_tools=(
        zoxide bat fd-find ripgrep
        bottom starship
    )
    
    sudo dnf install -y --skip-unavailable "${modern_tools[@]}"
    
    log "Installing eza manually (not in repos)..."
    if ! command -v eza &> /dev/null; then
        wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
        sudo chmod +x eza
        sudo mv eza /usr/local/bin/
        log "eza installed to /usr/local/bin/"
    else
        log "eza already available"
    fi
    
    log "Installing development tools..."
    
    local dev_tools=(
        python3 python3-pip python3-devel
        nodejs npm
        gcc make
    )
    
    sudo dnf install -y "${dev_tools[@]}"
    
    log "Installing media and document applications..."
    
    local media_apps=(
        mpv zathura zathura-pdf-mupdf
        firefox
    )
    
    sudo dnf install -y "${media_apps[@]}"
    
    log "Installing system utilities..."
    
    local system_tools=(
        NetworkManager-wifi
        util-linux-user
        unzip
    )
    
    sudo dnf install -y "${system_tools[@]}"
}

install_python_packages() {
    log "Installing Python packages for theming and utilities..."
    
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
    
    log "Installing Cozette font (primary)..."
    wget -O /tmp/cozette.zip https://github.com/the-moonwitch/Cozette/releases/download/v.1.30.0/CozetteFonts-v-1-30-0.zip
    unzip -o /tmp/cozette.zip -d ~/.local/share/fonts/
    
    log "Installing bitmap fonts from repositories..."
    sudo dnf install -y bitmap-fonts terminus-fonts
    
    fc-cache -fv
    rm -rf /tmp/cozette.zip
}

setup_shell() {
    log "Setting up Fish shell..."
    
    if ! grep -q "$(which fish)" /etc/shells; then
        echo "$(which fish)" | sudo tee -a /etc/shells
    fi
    
    log "Changing default shell to Fish..."
    chsh -s $(which fish)
    
    log "Fish shell configured as default"
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

setup_environment() {
    log "Setting up environment variables..."
    
    echo 'export EDITOR=vim' >> ~/.bashrc
    echo 'export VISUAL=vim' >> ~/.bashrc
    echo 'export BROWSER=firefox' >> ~/.bashrc
    echo 'export TERM=xterm' >> ~/.bashrc
    
    mkdir -p ~/.config/fish
    echo 'set -x EDITOR vim' >> ~/.config/fish/config.fish
    echo 'set -x VISUAL vim' >> ~/.config/fish/config.fish
    echo 'set -x BROWSER firefox' >> ~/.config/fish/config.fish
    echo 'set -x TERM xterm' >> ~/.config/fish/config.fish
}

create_script_fixes() {
    log "Creating script path fix helper..."
    
    cat > ~/fix_script_paths.sh << 'EOF'
#!/bin/bash

echo "Fixing NixOS paths in dotfiles scripts..."

find ~/dotfiles/scripts -name "*.sh" -type f -exec sed -i 's|#!/run/current-system/sw/bin/bash|#!/usr/bin/bash|g' {} \;
find ~/dotfiles/scripts -name "*.sh" -type f -exec sed -i 's|#!/run/current-system/sw/bin/fish|#!/usr/bin/fish|g' {} \;

echo "Fixed script paths for Fedora environment"
echo "All scripts now use standard system paths"
EOF
    
    chmod +x ~/fix_script_paths.sh
}

show_next_steps() {
    echo -e "\n${BLUE}=== CORE SETUP COMPLETE ===${NC}"
    echo -e "${GREEN}Installed:${NC} i3, polybar, alacritty, fish, and all essential tools"
    echo -e "${GREEN}Fonts:${NC} Cozette fonts installed successfully"
    echo -e "${GREEN}Shell:${NC} Fish shell set as default"
    echo -e "${GREEN}Environment:${NC} Configured for your workflow"
    echo ""
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo "1. Clone dotfiles: git clone https://github.com/borttappat/dotfiles ~/dotfiles"
    echo "2. Fix script paths: ~/fix_script_paths.sh"
    echo "3. Link configs: cd ~/dotfiles && chmod +x scripts/bash/links.sh && ./scripts/bash/links.sh"
    echo "4. Set wallpaper: wal -i ~/dotfiles/wallpapers/[your-wallpaper]"
    echo "5. Start i3: startx"
    echo ""
    echo -e "${YELLOW}NOTES:${NC}"
    echo "- Fish shell will be active on next login"
    echo "- All your essential packages are installed"
    echo "- VMware can be set up later if needed"
    echo "- Rust tools (joshuto, etc.) can be added later with cargo"
}

main() {
    log "Starting Fedora core environment setup..."
    
    check_fedora
    setup_repositories
    install_core_packages
    install_python_packages
    install_fonts
    create_directories
    setup_environment
    setup_shell
    create_script_fixes
    
    show_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
