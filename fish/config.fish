#     ___ __       __
#   .'  _|__.-----|  |--.
#   |   _|  |__ --|     |
#   |__| |__|_____|__|__|

if status is-interactive # Commands to run in interactive sessions can go here 
cat /home/traum/.cache/wal/sequences

end

if command -v zoxide > /dev/null
    zoxide init fish | source
end

set -gx GPG_TTY (tty)

cat ~/.cache/wal/sequences &

set -gx PATH $PATH ~/.local/bin

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

function sudo-command-line
    set cmd (commandline)
    if test -z "$cmd"
        set cmd (history | head -1)
    end

    if string match -q "sudo *" $cmd
        commandline -r (string sub -s 6 $cmd)
    else
        commandline -r "sudo $cmd"
    end
end

function toggle_vim_mode
    if test $fish_key_bindings = fish_vi_key_bindings
        fish_default_key_bindings
        echo "Switched to default key bindings"
    else
        fish_vi_key_bindings
        echo "Switched to vi key bindings"
    end
end

fish_vi_key_bindings

bind \es sudo-command-line

alias zenaudio='sh ~/dotfiles/scripts/bash/zenaudio.sh'
alias za='zenaudio'

alias bloodhound='nix develop ~/dotfiles/modules/bloodhound.nix'
alias bh='bloodhound'

alias burp='burpsuite --disable-auto-update'

alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
alias sesp='searchsploit'

alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown -h now'
alias sd='shutdown'
alias suspend='systemctl suspend'
alias time='sudo pentest-time -r Europe/Stockholm'
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

alias npp='v ~/dotfiles/modules/pentesting.nix'

alias nixsrv='v ~/dotfiles/modules/services.nix'

alias zathconf='v ~/dotfiles/zathura/zathurarc'

alias zathura='zathura --fork=false'
alias zath='zathura'

alias picomconf='v ~/dotfiles/picom/picom.conf'
alias polyconf='v ~/dotfiles/polybar/config.ini'
alias poc='polyconf'
alias fishconf='v ~/dotfiles/fish/config.fish'
alias s='fishconf'

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
