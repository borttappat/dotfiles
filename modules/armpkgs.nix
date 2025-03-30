# modules/arm-packages.nix
{ config, pkgs, lib, ... }:

let
  # Function to check if a package exists for the current system
  checkPkgAvailability = pkg: builtins.tryEval pkg;
  
  # Function to safely include a package only if it exists
  safeInclude = pkg: 
    let result = checkPkgAvailability pkg;
    in if result.success then [pkg] else [];

in {
  # ARM-compatible packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim neovim
    git
    curl
    wget
    htop
    tmux
    bat
    fzf
    
    # Shell and environment
    zsh
    starship
    eza
    fastfetch
    zoxide
    
    # System tools
    killall
    pciutils
    usbutils
    file
    
    # Window manager and desktop
    i3-gaps
    picom
    i3lock-color
    feh
    rofi
    polybar
    alacritty
    
    # Development
    python3
    nodejs
    gcc
    
    # Networking
    nmap
    openvpn
    
    # Input device support
    xorg.xf86inputlibinput
    xorg.xf86inputevdev
    
    # Remove problematic packages from regular install:
    # rar 
    # thermald
  ];
  
  # Input device configuration for ARM VMs
  services.xserver = {
    # Make sure evdev and libinput are explicitly enabled
    libinput.enable = true;
    modules = [ pkgs.xorg.xf86inputlibinput ];
  };
}
