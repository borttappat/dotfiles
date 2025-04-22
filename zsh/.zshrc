#!/usr/bin/env zsh
# .zshrc - Migrated from zsh.nix

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY          
setopt EXTENDED_HISTORY       

# Remove greeting
PROMPT_EOL_MARK=""

# PATH configuration
path+=("$HOME/.local/bin")
export PATH

# Optimize compinit to run once a day
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Configure autosuggestions style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# Enhanced Vi mode
bindkey -v
export KEYTIMEOUT=1

# Better searching in vi mode
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

# Add text objects for brackets, quotes, etc.
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
    bindkey -M $km -- '-' vi-up-line-or-history
    bindkey -M $km -- '+' vi-down-line-or-history
done

# Better directory navigation
setopt AUTO_CD              
setopt AUTO_PUSHD          
setopt PUSHD_IGNORE_DUPS   
setopt PUSHD_MINUS         

# Fast completion settings
setopt COMPLETE_IN_WORD    
setopt ALWAYS_TO_END       
setopt PATH_DIRS           
setopt AUTO_LIST          
setopt AUTO_MENU          

# Path expansion and other improvements
setopt NO_CASE_GLOB       
setopt EXTENDED_GLOB      
setopt GLOB_DOTS          
setopt NUMERIC_GLOB_SORT  
setopt INTERACTIVE_COMMENTS 
setopt NO_BEEP            

# Optimized completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load pywal colors
(cat ~/.cache/wal/sequences &)

# Sudo !! functionality
sudo-command-line() {
    [[ -z $BUFFER ]] && BUFFER="$(fc -ln -1)"
    if [[ $BUFFER == sudo\ * ]]; then
        CURSOR=$(( CURSOR-5 ))
        BUFFER="${BUFFER:5}"
    else
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR+5 ))
    fi
}
zle -N sudo-command-line
bindkey "^[s" sudo-command-line

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

# Initialize zoxide only - Starship is handled by NixOS module
if [ -x "$(command -v zoxide)" ]; then
    eval "$(zoxide init zsh)"
fi

# GPG configuration
export GPG_TTY=$(tty)

# ALIASES
alias bloodhound='nix develop ~/dotfiles/modules/bloodhound.nix'
alias bh='bloodhound'

alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
alias sesp='searchsploit'

alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown -h now'
alias sd='shutdown'
alias suspend='systemctl suspend'
alias time='sudo pentest-time -r Europe/Stockholm'

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
alias ns='nix-shell'
alias nsp='nix-shell -p'

alias flake='v ~/dotfiles/flake.nix'
alias nixconf='v ~/dotfiles/modules/configuration.nix'
alias armconf='v ~/dotfiles/modules/arm-vm.nix'
alias nixpkgs='v ~/dotfiles/modules/packages.nix'
alias np='nixpkgs'
alias npp='v ~/dotfiles/modules/pentesting.nix'

alias nixsrv='v ~/dotfiles/modules/services.nix'

alias i3conf='v ~/dotfiles/i3/config'
alias zathconf='v ~/dotfiles/zathura/zathurarc'

alias zathura='zathura --fork=false'
alias zath='zathura'

alias picomconf='v ~/dotfiles/picom/picom.conf'
alias polyconf='v ~/dotfiles/polybar/config.ini'
alias poc='polyconf'
alias zshconf='v ~/dotfiles/zsh/.zshrc'
alias s='zshconf'

alias pyserver='sudo python -m http.server 8002'
alias rgb='openrgb --device 0 --mode static --color'
alias w='wal -Rn'
alias walrgb='~/dotfiles/scripts/bash/walrgb.sh'

alias dots='cd ~/dotfiles && git status'

alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gc='git commit -m'
alias gp='git push -uf origin main'
alias gur='git add -A && git commit -m "updates" && git push -uf origin main'
alias gu='git add -u && git commit -m "updates" && git push -uf origin main'

alias links='sh ~/dotfiles/scripts/bash/links.sh'
alias link='sudo python ~/dotfiles/scripts/python/link_file.py'
 
alias tds='sudo tailscale file cp'
alias tdr='sudo tailscale file get'
 
alias cf='clear && fastfetch'

alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'

# Load zsh-autosuggestions and zsh-syntax-highlighting if available
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
