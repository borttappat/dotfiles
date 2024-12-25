{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Your custom zsh configuration
    initExtra = ''

      # Basic ZSH Configuration
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt appendhistory
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS

      # Vi mode
      bindkey -v
      # Reduce vi mode switching delay
      export KEYTIMEOUT=1

      # Function to toggle between vi and emacs mode
      function toggle_vim_mode() {
          if [[ $KEYMAP == vicmd ]]; then
              bindkey -e
              echo "Switched to default (emacs) key bindings"
          else
              bindkey -v
              echo "Switched to vi key bindings"
          fi
      }

      # Sudo !! functionality
      sudo-command-line() {
          [[ -z $BUFFER ]] && BUFFER="$(fc -ln -1)"
          if [[ $BUFFER == sudo\ * ]]; then
              CURSOR=$(( CURSOR-5 ))
              BUFFER="''${BUFFER:5}"
          else
              BUFFER="sudo $BUFFER"
              CURSOR=$(( CURSOR+5 ))
          fi
      }
      zle -N sudo-command-line
      bindkey "^[s" sudo-command-line

      # Load pywal colors if available
      (cat ~/.cache/wal/sequences &)

      # Required for GPG
      export GPG_TTY=$(tty)
    '';

    shellAliases = {
      # Pentesting
      htblabs = "sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn";
      msf = "figlet -f cricket \"msf\" && sudo msfconsole -q";
      sesp = "searchsploit";

      # System commands
      reboot = "systemctl reboot";
      rb = "reboot";
      shutdown = "shutdown -h now";
      sd = "shutdown";
      suspend = "systemctl suspend";

      # Applications
      bat = "bat --theme=ansi";
      wp = "cd ~/Wallpapers && ranger";
      j = "joshuto";
      cb = "cbonsai -l -t 1";
      g = "glances";
      r = "ranger";
      cm = "cmatrix -u 10";
      p = "pipes-rs -f 25 -p 7 -r 1.0";
      ac = "alacrittyconf";
      bw = "sudo bandwhich";
      pc = "picomconf";
      ai = "aichat -H --save-session -s";
      vn = "vim notes.txt";

      # eza (ls replacement)
      ls = "eza -A --color=always --group-directories-first --icons";
      l = "eza -Al --color=always --group-directories-first --icons";
      lt = "eza -AT --color=always --group-directories-first --icons";
      sls = "ls | grep -i";
      sl = "eza -Al --color=always --group-directories-first --icons | grep -i";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # System utilities
      grep = "ugrep --color=auto";
      egrep = "ugrep -E --color=auto";
      fgrep = "ugrep -F --color=auto";
      grubup = "sudo update-grub";
      ip = "ip -color";

      # Docker
      kali = "docker start unruffled_edison && sudo docker attach unruffled_edison";

      # Display configuration
      xrandrwide = "xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar &&  polybar -q &";
      xrandrrestore = "xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &";

      # Common shortcuts
      x = "startx";
      v = "vim";
      h = "htop";
      ka = "killall";

      # Configuration files
      alacrittyconf = "vim ~/dotfiles/alacritty/alacritty.toml";
      asusconf = "vim ~/dotfiles/asus.nix";
      hosts = "v ~/dotfiles/modules/hosts.nix";
      nixhosts = "v ~/dotfiles/modules/hosts.nix";
      nu = "sh ~/dotfiles/scripts/bash/nixupdate.sh";
      ncg = "sudo nix-collect-garbage -d";
      nixbuild = "~/dotfiles/scripts/bash/nixbuild.sh";
      nb = "nixbuild";
      nixconf = "v ~/dotfiles/modules/configuration.nix";
      pt = "v ~/dotfiles/modules/pentesting.nix";
      nixpkgs = "v ~/dotfiles/modules/packages.nix";
      np = "nixpkgs";
      npp = "v ~/dotfiles/modules/pentesting.nix";
      nixsrv = "v ~/dotfiles/modules/services.nix";
      i3conf = "v ~/dotfiles/i3/config";
      zathconf = "v ~/dotfiles/zathura/zathurarc";
      picomconf = "v ~/dotfiles/picom/picom.conf";
      polyconf = "v ~/dotfiles/polybar/config.ini";
      poc = "polyconf";
      fishconf = "v ~/dotfiles/fish/config.fish";
      f = "fishconf";
      pyserver = "sudo python -m http.server 8002";

      # RGB control
      rgb = "openrgb --device 0 --mode static --color";
      w = "wal -Rn";

      # Git aliases
      dots = "cd ~/dotfiles && git status";
      gs = "git status";
      ga = "git add";
      gd = "git diff";
      gc = "git commit -m";
      gp = "git push -uf origin main";
      gur = "git add -A && git commit -m \"updates\" && git push -uf origin main";
      gu = "git add -u && git commit -m \"updates\" && git push -uf origin main";
      gsy = "git pull && sh ~/dotfiles/links.sh";

      # File management
      links = "sh ~/dotfiles/scripts/bash/links.sh";
      link = "sudo python ~/dotfiles/scripts/python/link_file.py";

      # Tailscale
      tds = "sudo tailscale file cp";
      tdr = "sudo tailscale file get";

      # System information
      cf = "clear && fastfetch";

      # Network management
      nwshow = "nmcli dev wifi show";
      nwconnect = "nmcli --ask dev wifi connect";
      wifirestore = "~/dotfiles/scripts/bash/wifirestore.sh";
    };
  };

  # Make sure all the required packages are available
  environment.systemPackages = with pkgs; [
    starship
    zoxide
    eza
    bat
    ranger
    joshuto
    cbonsai
    glances
    pipes-rs
    bandwhich
    fastfetch
    ugrep
    figlet
    openrgb
    pywal
  ];

  # Set zsh as default shell for root and your user
  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  # Initialize starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Initialize zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
