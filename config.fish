##################################
#          config.fish           #  
##################################

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
end

# aliases
alias reboot='systemctl reboot'
alias shutdown='shutdown now'

alias ls='ls -A'

alias fetch='clear && bunnyfetch && cd ~/dotfiles && git status'

alias x='startx'
alias v='sudo -E vim'

alias nixbuild='sudo nixos-rebuild switch'
alias nixconf='v ~/dotfiles/configuration.nix'

alias i3conf='v ~/dotfiles/config'
alias picomconf='v ~/dotfiles/picom.conf'
alias polyconf='v ~/dotfiles/config.ini'
alias aliases='v ~/dotfiles/config.fish'

# maybe deprecated, only used with asus hardware
# to be replaced with non-platform specific syntax
alias kb0='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "0"'
alias kb1='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "1"'
alias kb5='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "5"'

alias w='feh --bg-fill ~/Wallpapers/Dark.jpg'
alias rgb='openrgb --device 0 --mode static --color'
alias walrgb='~/dotfiles/walrgb.sh '

alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push -uf origin main'
alias gur='git add -A && git commit -m "updates" && git push -uf origin main' 
alias gu='git add -u && git commit -m "updates" && git push -uf origin main' 
alias gsy='git pull && sh ~/dotfiles/links.sh'

# transfer files over tailscale using taildrop.
# append with path_to_file and target machine followed with :
alias tds='sudo tailscale file cp'
# recieve files over tailscale, append with path for file to be saved
alias tdr='sudo tailscale file get'

alias iknowkungfu='walrgb ~/Wallpapers/Wallpaper.jpeg && feh --bg-fill ~/Wallpapers/Dark.jpg && cmatrix -a'

alias cf='clear && neofetch'

# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'

set -U fish_greeting ""

# end
