###############################
# Configuration file for bash #
###############################


# Aliases

# Move to the parent folder.
alias ..='cd ..;pwd'

# Move up two parent folders.
alias ...='cd ../..;pwd'

# Move up three parent folders.
alias ....='cd ../../..;pwd'

alias reboot='systemctl reboot'
alias shutdown='shutdown now'
alias suspend='systemctl suspend'

# alias ls='ls -A'
alias ls='eza -a'
alias l='eza -a -l'


alias x='startx'
alias v='sudo -E vim'


alias nixp='~/dotfiles/nixp.sh '
alias nixbuild='sudo nixos-rebuild switch --flake /etc/nixos#traum'
alias flakebuild='sudo rm /etc/nixos/flake.nix && sudo ln ~/dotfiles/flake.nix /etc/nixos && nixbuild'
alias nixconf='v ~/dotfiles/configuration.nix'
alias nixpkgs='v ~/dotfiles/packages.nix'
alias nixsrv='v ~/dotfiles/services.nix'
alias nixclean='sudo nix-collect-garbage -d && nixbuild'
alias i3conf='v ~/dotfiles/config'
alias picomconf='v ~/dotfiles/picom.conf'
alias polyconf='v ~/dotfiles/config.ini'
alias aliases='v ~/dotfiles/config.fish'


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


alias cf='clear && neofetch'


# network-related
alias nwshow='nmcli dev wifi show'
alias nwconnect='nmcli --ask dev wifi connect'
alias wifirestore='~/dotfiles/wifirestore.sh'


cat /home/traum/.cache/wal/sequences
