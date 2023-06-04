if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
end

# aliases
alias reboot='systemctl reboot'
alias ls='ls -A'
alias fetch='clear && nitch && cd ~/.dotfiles/nixos'
alias shutdown='shutdown now'
alias x='startx'
alias gitpush='git push -uf origin main'
alias v='sudo -E vim'
alias nixconf='v ~/.dotfiles/nixos/configuration.nix'
alias nixbuild='sudo nixos-rebuild switch'



set -U fish_greeting ""
# end
