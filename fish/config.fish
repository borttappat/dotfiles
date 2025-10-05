#     ___ __       __
#   .'  _|__.-----|  |--.
#   |   _|  |__ --|     |
#   |__| |__|_____|__|__|

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
fish_vi_key_bindings
#wal -R -q

end


# enable vim mode for fish
function toggle_vim_mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        fish_default_key_bindings
        echo "Switched to default (emacs) key bindings"
    else
        fish_vi_key_bindings
        echo "Switched to vi key bindings"
    end
end


# Starship
starship init fish | source

# Zoxide
zoxide init fish | source

# thefuck
#thefuck --alias | source

function sudo_last_command
    commandline -r "sudo $history[1]"
end

bind \e\e sudo_last_command
bind -M insert \e\e sudo_last_command

alias rc='sudo virsh console router-vm-passthrough'
alias zenaudio='sh ~/dotfiles/scripts/bash/zenaudio.sh'
alias za='zenaudio'
alias zah='zenaudio headphones && zenaudio volume 75'
alias zas='zenaudio speakers && zenaudio volume 75'

alias tui='sh ~/splix/scripts/router-tui.sh'

alias bloodhound='nix develop ~/dotfiles/modules/bloodhound.nix'
alias bh='bloodhound'

#alias burp='burpsuite --disable-auto-update'

# fuck nano
alias nano='vim'

alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
alias sesp='searchsploit'

alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown -h now'
alias sd='shutdown'
alias suspend='systemctl suspend'
alias ptime='sudo pentest-time -r Europe/Stockholm'

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

alias npp='v ~/dotfiles/modules/pentesting.nix'

alias nixsrv='v ~/dotfiles/modules/services.nix'

alias zathconf='v ~/dotfiles/zathura/zathurarc'

alias zathura='zathura --fork=false'
alias zath='zathura'

alias picomconf='v ~/dotfiles/picom/picom.conf'
alias polyconf='v ~/dotfiles/polybar/config.ini'
alias poc='polyconf'
alias fishconf='v ~/.config/fish/config.fish'
alias f='fishconf'

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

alias cf='clear && fastfetch --file ~/dotfiles/misc/grace.txt'

alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'

alias ai='aichat -H --save-session -s'

alias vn='vim notes.txt'

alias ls='eza -A --color=always --group-directories-first --icons'
alias l='eza -Al --color=always --group-directories-first --icons'
alias lt='eza -AT --color=always --group-directories-first --icons'
alias sls='ls | grep -i'
alias sl='eza -Al --color=always --group-directories-first --icons | grep -i'

alias grep='ugrep --color=auto'
alias egrep='ugrep -E --color=auto'
alias fgrep='ugrep -F --color=auto'
alias grubup='sudo update-grub'

alias ip='ip -color'
alias xrandrwide='xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar && polybar -q &'
alias xrandrrestore='xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'

alias x='startx'
alias v='vim'
alias h='htop'
alias ka='killall'

alias alacrittyconf='vim ~/dotfiles/alacritty/alacritty.toml'
alias asusconf='vim ~/dotfiles/modules/asus.nix'
alias hosts='v ~/dotfiles/modules/hosts.nix'
alias nixhosts='v ~/dotfiles/modules/hosts.nix'

alias nu='sh ~/dotfiles/scripts/bash/nixupdate.sh'
alias ncg='sudo nix-collect-garbage -d'
alias nixbuild='~/dotfiles/scripts/bash/nixbuild.sh'
alias nb='nixbuild'
alias ns='nix-shell'
alias nsp='nix-shell -p'

alias md='mkdir -p'

alias flake='v ~/dotfiles/flake.nix'
alias nixconf='v ~/dotfiles/modules/configuration.nix'
alias armconf='v ~/dotfiles/modules/arm-vm.nix'
alias nixpkgs='v ~/dotfiles/modules/packages.nix'
alias np='nixpkgs'
