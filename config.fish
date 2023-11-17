#      _______      __
#     / ____(_)____/ /_
#    / /_  / / ___/ __ \
#   / __/ / (__  ) / / /
#  /_/   /_/____/_/ /_/

if status is-interactive
    # Commands to run in interactive sessions can go here

#cat /home/traum/.cache/wal/sequences
wal -R -q

end

# Binds

#bind \§ bind_sect_to_tilde


# aliases
alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown now'
alias sd='shutdown'
alias suspend='systemctl suspend'

alias j='joshuto'
alias r='ranger'
alias ranger='joshuto'
alias cm='cmatrix -u 10'
alias p='pipes-rs -f 25 -p 7 -r 1.0'


alias ls='eza -a'
alias l='eza -a -l'


# widescreen setup
alias xrandrwide='xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar &&  polybar -q &'

alias xrandrrestore='xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'


alias x='startx'
alias v='sudo -E vim'
alias h='htop'
alias ka='killall'


alias nixp='~/dotfiles/nixp.sh '
alias nixbuild='sudo nixos-rebuild switch --flake /etc/nixos#traum'
alias nb='nixbuild'
alias flakebuild='sudo rm /etc/nixos/flake.nix && sudo ln ~/dotfiles/flake.nix /etc/nixos && nixbuild'
alias nixconf='v /etc/nixos/configuration.nix'
alias nixpkgs='v /etc/nixos/packages.nix'
alias n='nixpkgs'
alias nixhosts='v /etc/nixos/hosts.nix'
alias nixsrv='v /etc/nixos/services.nix'
alias nixclean='sudo nix-collect-garbage -d && nixbuild'
alias i3conf='v ~/dotfiles/config'
alias i='i3conf'
alias picomconf='v ~/dotfiles/picom.conf'
alias pic='picomconf'
alias polyconf='v ~/dotfiles/config.ini'
alias poc='polyconf'
alias aliases='v ~/dotfiles/config.fish'
alias a='aliases'
alias f='a'


# maybe deprecated, only used with asus hardware
# to be replaced with non-platform specific syntax
#alias kb0='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "0"'
#alias kb1='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "1"'
#alias kb5='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "5"'


alias rgb='openrgb --device 0 --mode static --color'
alias walrgb='~/dotfiles/walrgb.sh '
alias w='walrgb'


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


alias cf='clear && neofetch'


# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/wifirestore.sh'


set -U fish_greeting ""

# end
