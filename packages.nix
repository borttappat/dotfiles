#                        __                                 _
#      ____  ____ ______/ /______ _____ ____  _____  ____  (_)  __
#     / __ \/ __ `/ ___/ //_/ __ `/ __ `/ _ \/ ___/ / __ \/ / |/_/
#    / /_/ / /_/ / /__/ ,< / /_/ / /_/ /  __(__  ) / / / / />  <
#   / .___/\__,_/\___/_/|_|\__,_/\__, /\___/____(_)_/ /_/_/_/|_|
#  /_/                          /____/

{ config, pkgs, ... }:

{

# Allowing unfree and unstable packages
    
    # I'm sorry, Stallman
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;

    nix.package = pkgs.nixUnstable;
 
# Fonts
    fonts.packages = with pkgs; [
    cozette
    ];

# Packages to install on a system-wide level
 environment.systemPackages = with pkgs; [

    
# Editors
    vim
    inkscape
    obs-studio
    #davinci-resolve


# Compilers
    #gcc
    python3

# Programs
    librewolf
    brave
    #mullvad
    mullvad-browser
    #mullvad-vpn
    tor
    vlc
    mpv
    gimp

# Terminal stuff
    rsync
    tgpt
    du-dust
    tmux
    zellij
    ripgrep
    wiki-tui
    fzf
    alacritty
    htop
    glances
    gotop
    neofetch
    bunnyfetch
    pfetch
    nitch
    cbonsai
    cmatrix
    ranger
    zoxide
    joshuto
    figlet
    ticker
    tickrs
    eza
    ttyper
    #matrixcli
    dfrs #df-replacement
    pipes-rs #rust-written replacement
    gurk-rs
    bat #cat-replacement
    ddgr
    asciiquarium

# WM
    polybar
    rofi
    picom
    #picom-allusive #to be replaced by compfy
    #wpgtk
    pywal
    feh
    #eww
    #conky
    betterlockscreen
    #dunst
    i3lock-color
    i3lock
    #i3lock-fancy
    autorandr

# Tools
    bandwhich
    bottles
    gping
    openconnect
    openvpn
    brightnessctl
    #obsidian
    light 
    undervolt
    git
    gh
    chatgpt-cli
    nmon
    zathura
    xdotool
    killall
    qemu
    #kvmtool
    #onionshare
    #picosnitch
    flameshot
    rar
    pciutils
    curl
    wget
    lshw
    toybox
    findutils
    busybox
    inetutils
    udisks
    docker  #added with virt.enable = true in services.nix
    signal-cli
    whois
    remmina
    warpd
    
# Pentesting
    awscli2
    seclists
    uncover
    wifite2
    nikto
    iw
    nmap
    rustscan
    wireshark
    sherlock
    dig
    wirelesstools
    hydra-cli
    thc-hydra
    metasploit
    hashcat
    cowpatty
    hcxtools
    aircrack-ng
    airgeddon
    mdk4
    hcxdumptool
    openssl
    asleap
    netcat
    rustcat
    samba
    gobuster
    ffuf
    exploitdb
    libxml2
    hcxtools
    enum4linux
    redis
    xrdp
    mariadb
    udevil #udisks replacement
    burpsuite
    proxychains-ng
    wprecon
    monsoon
    crunch
    websploit
    routersploit
    hostapd-mana
    bully
    sleuthkit
    dbmonster
    linux-router
    pixiewps
    theharvester
    dirb
    medusa
    libargon2
    kismet
    steghide
    stegseek
    parsero
    commix
    cewl
    bettercap
    whatweb
    reaverwps
    reaverwps-t6x
    john
    netdiscover
    lynis
    fcrackzip
    dnsrecon
    socat
    macchanger 
    httrack
    foremost
    dnsenum
    fierce
    cryptsetup
    wfuzz
    testdisk
    sqlmap
    wpscan
    tcpdump
    ettercap
    masscan
    fping
    evil-winrm
    driftnet    
    
# X11
    xorg.xinit
    xorg.xrdb
    xorg.xorgserver
    xorg.xmodmap
    
# Uncategorized
    unclutter
    unzip
    tealdeer
];
}
