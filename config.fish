##################################
#          config.fish           #  
##################################

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
end

# aliases
alias reboot='systemctl reboot'
alias ls='ls -A'
alias fetch='clear && bunnyfetch && cd ~/dotfiles'
alias shutdown='shutdown now'
alias x='startx'
alias gitpush='git push -uf origin main'
alias v='sudo -E vim'
alias nixconf='v ~/dotfiles/configuration.nix'
alias nixbuild='sudo nixos-rebuild switch'
alias i3conf='v ~/dotfiles/config'
alias picomconf='v ~/dotfiles/picom.conf'
alias polyconf='v ~/dotfiles/config.ini'
alias kb0='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "0"'
alias kb1='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "1"'
alias kb5='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "5"'
alias aliases='v ~/dotfiles/config.fish'
alias w='feh --bg-fill ~/Wallpapers/BWMountain2.jpg'
alias rgb='openrgb --device 0 --mode static --color'
alias wal='~/dotfiles/walrgb.sh '
set -U fish_greeting ""

# end
