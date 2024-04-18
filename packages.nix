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
    firefox
    brave
    mullvad
    mullvad-browser
    mullvad-vpn
    tor
    mpv

# Terminal stuff
    rsync 
    artem #img-to-ascii
    cava
    porsmo #pomodoro-timer
    #mop
    duf #storage-visualizer
    #tgpt #gpt chatbot
    du-dust #better version of du
    tmux 
    ripgrep
    #wiki-tui
    fzf 
    alacritty
    #kitty
    htop
    glances
    neofetch
    bunnyfetch 
    nitch
    cbonsai
    cmatrix
    ranger
    zoxide #cd without amnesia
    joshuto #ranger-like file manager written in rust
    figlet #for outputting ascii-text in banners etc.
    ticker #text-based price tracker
    tickrs #visual price tracker
    eza #better ls
    ttyper #typing excercises
    dfrs #df-replacement
    pipes-rs #rust-written replacement
    #gurk-rs
    bat #cat-replacement
    #ddgr
    #asciiquarium

# WM
    polybar
    rofi
    picom
    #picom-allusive #to be replaced by compfy
    #wpgtk
    pywal
    #themechanger
    imagemagick
    feh
    #eww
    #conky
    #dunst
    i3lock
    i3lock-fancy-rapid
    #autorandr

# Tools
    bandwhich #bandwith tracker
    iftop #top for network interfaces
    #android-tools
    #lynis #vulnerability analyzer
    #youtube-tui
    #mage #make-build tool written i Go
    poetry #python dependency management
    ngrok #web server running on local machine
    #pgrok #similar to the above
    #tmate #terminal-sharing
    #exiftool
    procs #ps written in rust
    #bottles #client for running windows-software
    gping #graphical ping tool
    #openconnect
    openvpn #openvpn-client
    brightnessctl #brightness-handler
    #obsidian #note taking too
    light #backlight-controller
    #undervolt
    git
    gh #git CLI tool
    #chatgpt-cli
    nmon #top-like tool
    zathura #pdf-reader
    #xdotool
    killall 
    qemu 
    #kvmtool
    #onionshare
    #picosnitch
    flameshot #screenshot-tool
    rar #RAR-archive tool
    pciutils
    curl
    wget
    lshw
    toybox
    findutils
    busybox
    inetutils
    udisks
    docker #added with virt.enable = true in services.nix
    lazydocker
    #signal-cli
    whois
    #remmina #rdp-interface
    xrdp #rdp-interface
    warpd #click stuff without mouse input
    ollama #run llms locally
    #oterm
    aichat #CLI gpt-chatbot 
    #open-interpreter
    #llm-ls
    #llm

# Pentesting
    #awscli2
    #dirstalk
    feroxbuster #dirbuster-alike tool
    dalfox #XSS-scanner
    xsser #XSS-scanner
    snmpcheck #SNMP-enumerator
    mitmproxy #Man-in-the-middle Proxy
    #caido #Burpsuite-like tool
    ghost #Android exploitation framework
    openldap
    crackmapexec
    #bloodhound-py
    #bloodhound
    responder
    seclists #SecLists-implementation
    uncover #API wrapper to scan for exposed hosts(shodan-ish)
    #webanalyze #similar to wapalyzer
    wifite2
    nikto #scanner for website vulnerabilities
    iw
    nmap
    rustscan
    wireshark
    tshark
    #termshark
    sherlock
    #dig
    dog #replacecment for dig
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
    #netcat replaced by rustcat
    rustcat
    samba
    gobuster
    ffuf
    exploitdb
    go-exploitdb
    libxml2
    hcxtools
    #enum4linux replaced by enum4linux-ng
    enum4linux-ng
    redis
    xrdp
    mariadb
    udevil #udisks replacement
    burpsuite
    mitmproxy
    mitmproxy2swagger
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
