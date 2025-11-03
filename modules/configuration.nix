# _______ __         _______ _______
#|    |  |__|.--.--.|       |     __|
#|       |  ||_   _||   -   |__     |
#|__|____|__||__.__||_______|_______|

{ config, pkgs, lib, ... }:

{   

services.logind.lidSwitch = "suspend";

systemd.services.i3lock-on-suspend = {
  description = "Lock screen before suspend";
  before = [ "sleep.target" ];
  wantedBy = [ "sleep.target" ];
  serviceConfig = {
    User = "traum";
    Type = "forking";
    Environment = [
      "DISPLAY=:0"
      "XAUTHORITY=/home/traum/.Xauthority"
      "HOME=/home/traum"
      "PATH=/run/current-system/sw/bin"
    ];
    ExecStart = "/home/traum/dotfiles/scripts/bash/lock.sh";
  };
};

# Autorandr is dope
services.autorandr.enable = true;

# Set ranger as default file manager
xdg.mime.defaultApplications = {
  "inode/directory" = "ranger.desktop";
};

# Setting to avoid download buffer warnings
nix.settings.download-buffer-size = 524288000;

# Enable parallel startup of systemd services
systemd = {
    services.nix-daemon.enable = true;
    extraConfig = ''
        DefaultTimeoutStopSec=10s
    '';
};

# Enable earlyoom to prevent system freezes
services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
};

boot = {
    # Reduce system shutdown timeout
    kernel.sysctl = {
        "kernel.sysrq" = 1;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "kernel.nmi_watchdog" = 0;  # Saves power
    };
};

# Enable zram for better memory management
zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
};

# Binary cache for faster downloads
nix.settings = {
    substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
};


# Set PAM limits to allow avoid NixOS error with too many open files
security.pam.loginLimits = [
    {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "4096";
    }
    {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "8192";
    }
];

# Enable all firmware
hardware.enableAllFirmware = true;

# Allowing for flakes and nix-command 
nix.settings.experimental-features = [ 
    "nix-command" 
    "flakes" 
];

# Nix-ld
programs.nix-ld.enable = true;

# Setting fish shell as default
programs.fish = {
  enable = true;
};
users.defaultUserShell = pkgs.fish;

# Qt and gtk support
qt = {
    enable = true;
    platformTheme = "gtk2";
};

environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
];

environment.variables = {
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "1.0";
    QT_SCALE_FACTOR = "1.5";
    XCURSOR_SIZE = "32";
    BAT_THEME = "ansi";

    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
};

environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
'';

# Use latest kernel
boot.kernelPackages = pkgs.linuxPackages_latest;

# Default networking hostname and NetworkManager
networking.hostName = "nix"; # default, unless declared in other configs with mkForce
networking.networkmanager.enable = true;


# Firewall settings
#networking.firewall.allowedTCPPorts = [ 21 22 25 80 110 135 139 389 445 587 1234 1433 3128 3141 8080 4444 4445 8000 53 3389 ];
networking.firewall.allowedTCPPorts = [ 22 80 8080 4444 4445 8000 ];
#networking.firewall.allowedUDPPorts = [ 137 138 53 389 1434 4444 5353 5355 5453 ];
networking.firewall.allowedUDPPorts = [ 22 53 80 4444 4445 5353 5355 5453 ];

networking.firewall.enable = true;
networking.nftables.enable = false;

# Time zone
time.timeZone = "Europe/Stockholm";

# Locale settings
i18n.defaultLocale = "en_US.UTF-8";

i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
};

# Configure console keymap
console.keyMap = "sv-latin1";

# Enable the X11 windowing system
services.xserver.enable = true;

# Window manager and display manager
services.xserver.displayManager.startx.enable = true;
services.xserver.windowManager.i3.enable = true;

# Configure keymap in X11
services.xserver.xkb = {
    layout = "se";
    variant = "";
};

# Automatic garbage collection
nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
};

# Automatic nix-store optimizing
nix.settings.auto-optimise-store = true;

# System state version
system.stateVersion = "22.11"; 
}
