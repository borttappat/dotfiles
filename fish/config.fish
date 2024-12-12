#     ___ __       __
#   .'  _|__.-----|  |--.
#   |   _|  |__ --|     |
#   |__| |__|_____|__|__|

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
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

# Replicate !! functionality in fish
function sudo!!
    eval sudo $history[1]
end

abbr -a !! 'eval sudo $history[1]'


# # # # # # 
# ALIASES #
# # # # # #

alias htblabs='sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'

alias msf='figlet -f cricket "msf" && sudo msfconsole -q'
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
alias p='polyconf'
alias r='ranger'
alias cm='cmatrix -u 10'
alias p='pipes-rs -f 25 -p 7 -r 1.0'
alias ac='alacrittyconf'
alias bw='sudo bandwhich'
alias pc='picomconf'
alias ai='aichat -H --save-session -s'
alias vn='vim notes.txt'

# Replace ls with eza
alias ls='eza -A --color=always --group-directories-first --icons' # preferred listing
alias l='eza -Al --color=always --group-directories-first --icons'  # all files and dirs
alias lt='eza -AT --color=always --group-directories-first --icons' # tree listing

alias sls='ls | grep -i'
alias sl='eza -Al --color=always --group-directories-first --icons | grep -i' # preferred listing

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
alias sesp='searchsploit'


# widescreen setup
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

# maybe deprecated, only used with asus hardware
# to be replaced with non-platform specific syntax
#alias kb0='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "0"'
#alias kb1='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "1"'
#alias kb5='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "5"'


alias rgb='openrgb --device 0 --mode static --color'
#alias walrgb='~/dotfiles/scripts/bash/walrgb.sh '
#alias w='~/dotfiles/scripts/bash/walrgb.sh ~/Wallpapers/'
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


# transfer files over tailscale using taildrop.
# append with path_to_file and target machine followed with :
alias tds='sudo tailscale file cp'
# recieve files over tailscale, append with path for file to be saved
alias tdr='sudo tailscale file get'


alias cf='clear && fastfetch'


# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'


set -U fish_greeting ""
set -U fish_user_paths $HOME/.local/bin $fish_user_paths

# end
