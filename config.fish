if status is-interactive
    # Commands to run in interactive sessions can go here

cat /home/traum/.cache/wal/sequences
end

# aliases
alias reboot='systemctl reboot'
alias ls='ls -A'
alias fetch='clear && nitch && cd ~/.dotfiles/nixos'


set -U fish_greeting ""
# end
