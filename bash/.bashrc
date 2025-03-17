###############################
# Configuration file for bash #
###############################

# Aliases

# Pentesting
alias bloodhound='nix develop ~/dotfiles/modules/bloodhound.nix'
alias bh='bloodhound'
alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
alias sesp='searchsploit'

# System control
alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown -h now'
alias sd='shutdown'
alias suspend='systemctl suspend'

# Applications
alias bat='bat --theme=ansi'
alias wp='cd ~/Wallpapers && ranger'
alias j='joshuto'
alias cb='cbonsai -l -t 1'
alias g='glances'
alias r='ranger'
alias cm='cmatrix -u 10'
alias p='pipes-rs -f 25 -p 7 -r 1.0'
alias bw='sudo bandwhich'
alias ac='alacrittyconf'
alias pc='picomconf'
alias ai='aichat -H --save-session -s'
alias vn='vim notes.txt'

# File management
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

# Utilities
alias grep='ugrep --color=auto'
alias egrep='ugrep -E --color=auto'
alias fgrep='ugrep -F --color=auto'
alias grubup='sudo update-grub'
alias ip='ip -color'
alias x='startx'
alias v='vim'
alias h='htop'
alias ka='killall'

# Display management
alias xrandrwide='xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar &&  polybar -q &'
alias xrandrrestore='xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'

# Configuration editing
alias alacrittyconf='vim ~/dotfiles/alacritty/alacritty.toml'
alias asusconf='vim ~/dotfiles/modules/asus.nix'
alias hosts='v ~/dotfiles/modules/hosts.nix'
alias nixhosts='v ~/dotfiles/modules/hosts.nix'
alias i3conf='v ~/dotfiles/i3/config'
alias zathconf='v ~/dotfiles/zathura/zathurarc'
alias picomconf='v ~/dotfiles/picom/picom.conf'
alias polyconf='v ~/dotfiles/polybar/config.ini'
alias poc='polyconf'
alias bashconf='v ~/dotfiles/bash/.bashrc'
alias b='bashconf'

# NixOS operations
alias nu='sh ~/dotfiles/scripts/bash/nixupdate.sh'
alias ncg='sudo nix-collect-garbage -d'
alias nixbuild='~/dotfiles/scripts/bash/nixbuild.sh'
alias nb='nixbuild'
alias nixconf='v ~/dotfiles/modules/configuration.nix'
alias nixpkgs='v ~/dotfiles/modules/packages.nix'
alias np='nixpkgs'
alias npp='v ~/dotfiles/modules/pentesting.nix'
alias nixsrv='v ~/dotfiles/modules/services.nix'

# Utility scripts
alias pyserver='sudo python -m http.server 8002'
alias rgb='openrgb --device 0 --mode static --color'
alias w='wal -Rn'

# Git operations
alias dots='cd ~/dotfiles && git status'
alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gc='git commit -m'
alias gp='git push -uf origin main'
alias gur='git add -A && git commit -m "updates" && git push -uf origin main'
alias gu='git add -u && git commit -m "updates" && git push -uf origin main'
alias gsy='git pull && sh ~/dotfiles/scripts/bash/links.sh'

# File and script management
alias links='sh ~/dotfiles/scripts/bash/links.sh'
alias link='sudo python ~/dotfiles/scripts/python/link.py'

# Tailscale operations
alias tds='sudo tailscale file cp'
alias tdr='sudo tailscale file get'

# System information
alias cf='clear && fastfetch'

# Network related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'

# Load pywal colors
#cat ~/.cache/wal/sequences
#cat /home/traum/.cache/wal/sequences
