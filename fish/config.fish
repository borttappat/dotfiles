#      _______      __
#     / ____(_)____/ /_
#    / /_  / / ___/ __ \
#   / __/ / (__  ) / / /
#  /_/   /_/____/_/ /_/

if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
#wal -R -q

end

# Zoxide
zoxide init fish | source

# Binds

#bind \§ bind_sect_to_tilde
#bind \§ 'echo "~"'




# aliases
alias reboot='systemctl reboot'
alias rb='reboot'
alias shutdown='shutdown now'
alias sd='shutdown'
alias suspend='systemctl suspend'

alias wp='cd ~/Wallpapers && ranger'
alias j='joshuto'
alias cb='cbonsai -l -t 1'
alias g='glances'
alias p='polyconf'
alias r='ranger'
alias cm='cmatrix -u 10'
alias p='pipes-rs -f 25 -p 7 -r 1.0'
alias a='alacrittyconf'
alias bw='sudo bandwhich'
alias pc='picomconf'

alias ls='eza -a'
alias l='eza -a -l'


# widescreen setup
alias xrandrwide='xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar &&  polybar -q &'

alias xrandrrestore='xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'


alias x='startx'
alias v='sudo -E vim'
alias h='htop'
alias ka='killall'

alias alacrittyconf='v ~/dotfiles/alacritty/alacritty.toml'
alias nixp='sudo ~/dotfiles/scripts/bash/nixp.sh'
alias nixpsort='sudo python ~/dotfiles/scripts/python/nixpsort.py'
alias nu='sh ~/dotfiles/scripts/bash/nixupdate.sh'
#alias nu='sudo sh ~/dotfiles/scripts/bash/nixupdate.sh'
alias nixbuild='~/dotfiles/scripts/bash/nixbuild.sh'
alias nb='nixbuild'
alias nixconf='v /etc/nixos/configuration.nix'
alias nixpkgs='v /etc/nixos/packages.nix'
alias np='nixpkgs'
alias nixhosts='v /etc/nixos/hosts.nix'
alias n='nixpkgs'
alias nixhosts='v /etc/nixos/hosts.nix'
alias nixsrv='v /etc/nixos/services.nix'
alias nixclean='sudo nix-collect-garbage -d && nixbuild'
alias i3conf='v ~/dotfiles/i3/config'
alias i='i3conf'
alias picomconf='v ~/dotfiles/picom/picom.conf'
alias polyconf='v ~/dotfiles/polybar/config.ini'
alias poc='polyconf'
alias fishconf='v ~/dotfiles/fish/config.fish'
alias f='fishconf'


# maybe deprecated, only used with asus hardware
# to be replaced with non-platform specific syntax
#alias kb0='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "0"'
#alias kb1='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "1"'
#alias kb5='sudo light -Srs "sysfs/leds/asus::kbd_backlight" "5"'


alias rgb='openrgb --device 0 --mode static --color'
alias walrgb='~/dotfiles/scripts/bash/walrgb.sh '
alias w='~/dotfiles/scripts/bash/walrgb.sh ~/Wallpapers/'


alias dots='figlet -f slant Git && echo && cd ~/dotfiles && git status'
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


alias cf='clear && neofetch'


# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/scripts/bash/wifirestore.sh'


set -U fish_greeting ""

# end
