#      _______      __
#     / ____(_)____/ /_
#    / /_  / / ___/ __ \
#   / __/ / (__  ) / / /
#  /_/   /_/____/_/ /_/

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
end

# aliases
alias reboot='systemctl reboot'
alias shutdown='shutdown now'
alias suspend='systemctl suspend'

# alias ls='ls -A'
alias ls='eza -a'
alias l='eza -a -l'


alias x='startx'
alias v='sudo -E vim'
alias h='htop'


alias nixp='~/dotfiles/nixp.sh '
alias nixbuild='sudo nixos-rebuild switch --flake /etc/nixos#traum'
alias flakebuild='sudo rm /etc/nixos/flake.nix && sudo ln ~/dotfiles/flake.nix /etc/nixos && nixbuild'
alias nixconf='v /etc/nixos/configuration.nix'
alias nixpkgs='v /etc/nixos/packages.nix'
alias nixhosts='v /etc/nixos/hosts.nix'
alias nixsrv='v /etc/nixos/services.nix'
alias nixclean='sudo nix-collect-garbage -d && nixbuild'
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


alias gd='clear && figlet -f slant Git && echo && cd ~/dotfiles && git status'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push -uf origin main'
alias gur='git add -A && git commit -m "updates" && git push -uf origin main' 
alias gu='git add -u && git commit -m "updates" && git push -uf origin main' 
alias gsy='git pull && sh ~/dotfiles/links.sh'


alias links='sh ~/dotfiles/links.sh'


# transfer files over tailscale using taildrop.
# append with path_to_file and target machine followed with :
alias tds='sudo tailscale file cp'
# recieve files over tailscale, append with path for file to be saved
alias tdr='sudo tailscale file get'


alias iknowkungfu='walrgb ~/Wallpapers/Wallpaper.jpeg && feh --bg-fill ~/Wallpapers/Black.jpg && cmatrix -a'


alias cf='clear && neofetch'


# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/wifirestore.sh'


set -U fish_greeting ""

# end
