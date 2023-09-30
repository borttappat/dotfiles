{ config, pkgs, ... }:

{

# Allowing unfree and unstable packages
    
    # I'm sorry, Stallman
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnstable = true;

    nix.package = pkgs.nixUnstable;
 
# Fonts
    fonts.packages = with pkgs; [
    nerdfonts
    ];

# Packages to install on a system-wide level
 environment.systemPackages = with pkgs; [

# Editors
    vim
    
# Intel drivers
    intel-ocl
    ocl-icd
    clinfo
    #intelmetool
    #intel-media-driver
    #intel-compute-runtime
    #intel-graphics-compiler

# Compilers
    #gcc
    python3

# Programs
    librewolf
    brave
    mullvad-browser
    mullvad-vpn
    tor

# Terminal stuff
    alacritty
    htop
    glances
    neofetch
    bunnyfetch
    pfetch
    nitch
    cbonsai
    cmatrix
    ranger
    figlet
    ticker
    tickrs
    eza
    ttyper
    #matrixcli
    dfrs
    pipes

# WM
    polybar
    rofi
    picom
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

# Tools
    openconnect
    openvpn
    brightnessctl
    obsidian
    light 
    #pciutils
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
    tmux    
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

    whois

    uncover

    wifite2
    nikto
    iw
    nmap
    wireshark
    sherlock
    iw
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
    traceroute
    samba
    gobuster
    ffuf
    exploitdb
    libxml2
    hcxtools
    enum4linux
    redis
    remmina
    mariadb
    udevil #udisks replacement
 

    #burpsuite
    #proxychains-ng
    
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
    
# Uncategorized
    unclutter
    unzip
    tealdeer
    gimp
];
}
