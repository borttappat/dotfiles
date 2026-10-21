#                    __                                     __
#  .-----.---.-.----|  |--.---.-.-----.-----.-----.  .-----|__.--.--.
#  |  _  |  _  |  __|    <|  _  |  _  |  -__|__ --|__|     |  |_   _|
#  |   __|___._|____|__|__|___._|___  |_____|_____|__|__|__|__|__.__|
#  |__|                         |_____|

{ config, pkgs, ... }:

{

# Editor-settings
environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
};

nixpkgs.config.packageOverrides = pkgs: {
    librewolf = pkgs.librewolf.override {
        extraPrefs = ''
            pref("browser.startup.homepage", "https://borttappat.github.io/links.html");
            pref("browser.newtab.url", "https://borttappat.github.io/links.html");
            pref("browser.newtabpage.enabled", true);
            pref("browser.newtab.preload", true);
            pref("browser.newtabpage.enhanced", true);
            pref("browser.newtabpage.activity-stream.showSearch", true);
            pref("browser.newtabpage.activity-stream.default.sites", "");
        '';
    };
  
    firefox = pkgs.firefox.override {
        extraPrefs = ''
            pref("browser.startup.homepage", "https://borttappat.github.io/links.html");
            pref("browser.newtab.url", "https://borttappat.github.io/links.html");
            pref("browser.newtabpage.enabled", true);
            pref("browser.newtab.preload", true);
            pref("browser.newtabpage.enhanced", true);
            pref("browser.newtabpage.activity-stream.showSearch", true);
            pref("browser.newtabpage.activity-stream.default.sites", "");
        '';
    };
};

# Allowing unfree and unstable packages
# I'm sorry, Stallman
nixpkgs.config.allowUnfree = true;
nixpkgs.config.allowUnstable = true;

nix.package = pkgs.nixVersions.git;
 
# Fonts
fonts.packages = with pkgs; [
    cozette      # alacritty (CozetteVector*) + rofi
   #hack-font
    tamzen       # polybar
];

# Packages to install on a system-wide level
environment.systemPackages = with pkgs; [

# Editors
    vim
    #neovim
    #helix
    #inkscape
    #obs-studio
    #davinci-resolve

# Compilers
    gcc
    python3
    jython

# Programs
    #librewolf
    firefox
    #brave
    #ungoogled-chromium
    #google-chrome
    mullvad
    #nyxt
    #qutebrowser
    #mullvad-browser
    mullvad-vpn
    #tor
    mpv
    #pipewire
    openssl

# Terminal stuff
    #tmate
    unstable.nix-output-monitor
    zsh
    fish
    #rsync 
    starship
    asciinema       # terminal recording (fish/config.fish, start-recording/stop-recording)

    # Render a recording (.cast) to clean plain text on stdout, defaulting to the
    # current session. The input is snapshotted first so a still-growing live
    # recording can't change under the converter, and asciinema convert only
    # writes txt to a real file, so it goes via a temp file.
    (writeShellScriptBin "rec-text" ''
      set -eu
      f="''${1:-''${HYDRIX_REC_FILE:-}}"
      [ -n "$f" ] || { echo "Usage: rec-text [file.cast]  (defaults to the current session)" >&2; exit 1; }
      [ -f "$f" ] || { echo "rec-text: no such file: $f" >&2; exit 1; }
      in=$(${coreutils}/bin/mktemp)
      out=$(${coreutils}/bin/mktemp)
      trap 'rm -f "$in" "$out"' EXIT
      ${coreutils}/bin/head -c "$(${coreutils}/bin/stat -c %s "$f")" "$f" > "$in"
      ${asciinema}/bin/asciinema convert --overwrite -f txt "$in" "$out" 2>/dev/null || true
      ${coreutils}/bin/cat "$out"
    '')
    #mop
    dust            #better version of du
    tmux 
    #zellij
    #ripgrep
    ugrep
    #wiki-tui
    fzf
    alacritty
    #ghostty
    #thefuck         #Magnificent app which corrects your previous console command
    #kitty
    htop
    #glances
    bottom          # visual process monitor
    #neofetch
    fastfetch
    #bunnyfetch 
    #nitch
    ranger
    zoxide          #cd without amnesia, sourced in config.fish
    blesh           #Bash Line Editor
    joshuto         #ranger-like file manager written in rust
    figlet          #for outputting ascii-text in banners etc.
    #ticker          #text-based price tracker
    #tickrs          #visual price tracker
    eza             #better ls
    #gurk-rs
    #ddgr
    bat

# WM
    polybar
    rofi
    picom
   #picom-pijulius
    pywal
    pywalfox-native
    #theme-sh
    imagemagick
    feh
    #eww
    #conky
    #dunst
    scrot
    i3lock-color
    i3lock-fancy
    #i3lock-fancy-rapid
    #i3wsr
    #autorandr

# Tools
    #dog                    #replacecment for cat
    alsa-utils
    #catppuccinifier-cli     #modify wallpapers with a catppucin style
    bandwhich           #bandwith tracker
    iw
    wirelesstools
    #youtube-tui
    ngrok           #web server running on local machine
    #pgrok          #similar to the above
    procs           #ps written in rust
    #bottles        #client for running windows-software
    gping           #graphical ping tool
    openvpn         #openvpn-client
    brightnessctl   #brightness-handler
    #notesnook       #OS-alternative to obsidian
    #light           #backlight-controller
    #undervolt
    git
    gh              #git CLI tool
    zathura         #pdf-reader
    xdotool
    #jq
    killall 
    rar             #RAR-archive tool
    pciutils
    curl
    wget
    lshw
    findutils
    udisks
    nix-prefetch
    nix-prefetch-github
    
    ansible         #we be devs now

    whois
    warpd           #click stuff without mouse input
    unstable.claude-code
    #khoj
    #aichat          #CLI gpt-chatbot 
    unclutter       #hides mouse cursor when not in use
    unzip           #zip-archiving tool 
    tealdeer        #alternative to man
    #udevil          #udisks replacement
    jq              #JSON processor, do not remove, is unfortunately used in a few places
    envsubst

    
# X11
    xinit
    xrdb
    xorg-server
    xmodmap
    xmessage
    xcursor-themes
    xdpyinfo
    


# Uncategorized
    pulseaudioFull
];

}
