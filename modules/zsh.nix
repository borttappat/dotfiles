{ config, pkgs, ... }:

{
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  environment.etc."zshrc".text = ''
    # History Configuration
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt appendhistory
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_SAVE_NO_DUPS
    
    # Remove greeting
    PROMPT_EOL_MARK=""

    # PATH configuration
    path+=("$HOME/.local/bin")
    export PATH

    # Vi mode
    bindkey -v
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

    # Load pywal colors
    (cat ~/.cache/wal/sequences &)

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

    # thefuck integration
    eval $(thefuck --alias)

    # Starship and zoxide
    eval "$(starship init zsh)"
    eval "$(zoxide init zsh)"

    # GPG configuration
    export GPG_TTY=$(tty)

    # Aliases
    alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
    alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
    alias sesp='searchsploit'
    alias reboot='systemctl reboot'
    alias rb='reboot'
    alias shutdown='shutdown -h now'
    alias sd='shutdown'
    alias suspend='systemctl suspend'
    alias bat='bat --theme=ansi'
    alias wp='cd ~/Wallpapers && ranger'
    alias j='joshuto'
    alias cb='cbonsai -l -t 1'
    alias g='glances'
    alias r='ranger'
    alias cm='cmatrix -u 10'
    alias p='pipes-rs -f 25 -p 7 -r 1.0'
    alias ac='alacrittyconf'
    alias bw='sudo bandwhich'
    alias pc='picomconf'
    alias ai='aichat -H --save-session -s'
    alias vn='vim notes.txt'
    alias ls='eza -A --color=always --group-directories-first --icons'
    alias l='eza -Al --color=always --group-directories-first --icons'
    alias lt='eza -AT --color=always --group-directories-first --icons'
    alias sls='ls | grep -i'
    alias sl='eza -Al --color=always --group-directories-first --icons | grep -i'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias ......='cd ../../../../..'
    alias grep='ugrep --color=auto'
    alias egrep='ugrep -E --color=auto'
    alias fgrep='ugrep -F --color=auto'
    alias grubup='sudo update-grub'
    alias ip='ip -color'
    alias kali='docker start unruffled_edison && sudo docker attach unruffled_edison'
    alias xrandrwide='xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar &&  polybar -q &'
    alias xrandrrestore='xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'
    alias x='startx'
    alias v='vim'
    alias h='htop'
    alias ka='killall'
    alias alacrittyconf='vim ~/dotfiles/alacritty/alacritty.toml'
    alias asusconf='vim ~/dotfiles/asus.nix'
    alias hosts='v ~/dotfiles/modules/hosts.nix'
    alias nixhosts='v ~/dotfiles/modules/hosts.nix'
    alias nu='sh ~/dotfiles/scripts/bash/nixupdate.sh'
    alias ncg='sudo nix-collect-garbage -d'
    alias nixbuild='~/dotfiles/scripts/bash/nixbuild.sh'
    alias nb='nixbuild'
    alias nixconf='v ~/dotfiles/modules/configuration.nix'
    alias pt='v ~/dotfiles/modules/pentesting.nix'
    alias nixpkgs='v ~/dotfiles/modules/packages.nix'
    alias np='nixpkgs'
    alias npp='v ~/dotfiles/modules/pentesting.nix'
    alias nixsrv='v ~/dotfiles/modules/services.nix'
    alias i3conf='v ~/dotfiles/i3/config'
    alias zathconf='v ~/dotfiles/zathura/zathurarc'
    alias picomconf='v ~/dotfiles/picom/picom.conf'
    alias polyconf='v ~/dotfiles/polybar/config.ini'
    alias poc='polyconf'
    alias fishconf='v ~/dotfiles/fish/config.fish'
    alias f='fishconf'
    alias pyserver='sudo python -m http.server 8002'
    alias rgb='openrgb --device 0 --mode static --color'
    alias w='wal -Rn'
    alias dots='cd ~/dotfiles && git status'
    alias gs='git status'
    alias ga='git add'
    alias gd='git diff'
    alias gc='git commit -m'
    alias gp='git push -uf origin main'
    alias gur='git add -A && git commit -m "updates" && git push -uf origin main'
    alias gu='git add -u && git commit -m "updates" && git push -uf origin main'
    alias gsy='git pull && sh ~/dotfiles/links.sh'
    alias links='sh ~/dotfiles/scripts/bash/links.sh'
    alias link='sudo python ~/dotfiles/scripts/python/link_file.py'
    alias tds='sudo tailscale file cp'
    alias tdr='sudo tailscale file get'
    alias cf='clear && fastfetch'
    alias nwshow='nmcli dev wifi show'
    alias nwconnect='nmcli --ask dev wifi connect'
    alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'
  '';

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
    thefuck
  ];
}
