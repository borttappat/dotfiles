#     ___ __       __
#   .'  _|__.-----|  |--.
#   |   _|  |__ --|     |
#   |__| |__|_____|__|__|
if status is-interactive
    cat /home/traum/.cache/wal/sequences
    fish_vi_key_bindings
    
    # Auto-start recording if flag exists
    if test -f ~/.recording_active
        and not set -q RECORDING_ACTIVE
        
        set -l log_dir (cat ~/.recording_active)
        set -l timestamp (date +%Y%m%d_%H%M%S)
        set -gx RECORDING_FILE "$log_dir/session_$timestamp.cast"
        set -gx RECORDING_ACTIVE 1
        
        echo "[!] Recording to: $RECORDING_FILE"
        
        asciinema rec "$RECORDING_FILE"
        
        set -e RECORDING_ACTIVE
        set -e RECORDING_FILE
    end
end

set fish_cursor_default underscore blink
set fish_cursor_insert underscore blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual underscore blink
# Starship
starship init fish | source

# Zoxide
zoxide init fish | source

# === VIM MODE ===
function toggle_vim_mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        fish_default_key_bindings
        echo "Switched to default (emacs) key bindings"
    else
        fish_vi_key_bindings
        echo "Switched to vi key bindings"
    end
end

function sudo_last_command
    commandline -r "sudo $history[1]"
end

bind \e\e sudo_last_command
bind -M insert \e\e sudo_last_command

# === NIX SHELL ===
abbr -a nsp 'nix-shell --run fish -p'

# === SYSTEM ===
abbr -a reboot 'systemctl reboot'
abbr -a rb 'systemctl reboot'
abbr -a shutdown 'shutdown -h now'
abbr -a sd 'shutdown -h now'
abbr -a suspend 'systemctl suspend'
abbr -a ncg 'sudo nix-collect-garbage -d'

# === EDITORS ===
abbr -a v 'vim'
abbr -a nano 'vim'
abbr -a vn 'vim notes.txt'

# === NAVIGATION ===
abbr -a j 'joshuto'
abbr -a r 'ranger'
abbr -a wp 'cd ~/Wallpapers && ranger'
abbr -a dots 'cd ~/dotfiles && git status'

function c
    cd $argv && ls
end

function mkcd
    mkdir -p $argv && cd $argv
end

# === FILE LISTING ===
abbr -a ls 'eza -A --color=always --group-directories-first'
abbr -a l 'eza -Al --color=always --group-directories-first'
abbr -a lt 'eza -AT --color=always --group-directories-first'

function sls
    ls | grep -i $argv
end

function sl
    eza -Al --color=always --group-directories-first --icons | grep -i $argv
end

# === GREP ===
abbr -a grep 'ugrep --color=auto'
abbr -a egrep 'ugrep -E --color=auto'
abbr -a fgrep 'ugrep -F --color=auto'

# === GIT ===
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gd 'git diff'
abbr -a gc 'git commit -m'
abbr -a gp 'git push -uf origin main'
abbr -a gur 'git add -A && git commit -m "updates" && git push -uf origin main'
abbr -a gu 'git add -u && git commit -m "updates" && git push -uf origin main'
abbr -a gl 'git log --oneline --graph --decorate -20'

# === UTILITIES ===
abbr -a h 'htop'
abbr -a ka 'killall'
abbr -a bat 'bat --theme=ansi'
abbr -a cb 'cbonsai -l -t 1'
abbr -a g 'glances'
abbr -a cm 'cmatrix -u 10'
abbr -a p 'pipes-rs -f 25 -p 7 -r 1.0'
abbr -a bw 'sudo bandwhich'
abbr -a md 'mkdir -p'
abbr -a ip 'ip -color'
abbr -a cf 'clear && fastfetch --file ~/dotfiles/misc/grace.txt'
abbr -a reload 'source ~/.config/fish/config.fish'

# === CONFIG FILES ===
abbr -a f 'vim ~/.config/fish/config.fish'
abbr -a fishconf 'vim ~/.config/fish/config.fish'
abbr -a flake 'vim ~/dotfiles/flake.nix'
abbr -a nixconf 'vim ~/dotfiles/modules/configuration.nix'
abbr -a nixpkgs 'vim ~/dotfiles/modules/packages.nix'
abbr -a np 'vim ~/dotfiles/modules/packages.nix'
abbr -a npp 'vim ~/dotfiles/modules/pentesting.nix'
abbr -a nixsrv 'vim ~/dotfiles/modules/services.nix'
abbr -a hosts 'vim ~/dotfiles/modules/hosts.nix'
abbr -a nixhosts 'vim ~/dotfiles/modules/hosts.nix'
abbr -a armconf 'vim ~/dotfiles/modules/arm-vm.nix'
abbr -a asusconf 'vim ~/dotfiles/modules/asus.nix'
abbr -a ac 'vim ~/dotfiles/alacritty/alacritty.toml'
abbr -a alacrittyconf 'vim ~/dotfiles/alacritty/alacritty.toml'
abbr -a pc 'vim ~/dotfiles/picom/picom.conf'
abbr -a picomconf 'vim ~/dotfiles/picom/picom.conf'
abbr -a poc 'vim ~/dotfiles/polybar/config.ini'
abbr -a polyconf 'vim ~/dotfiles/polybar/config.ini'
abbr -a zathconf 'vim ~/dotfiles/zathura/zathurarc'

# === PENTESTING ===
abbr -a msf 'figlet -f cricket "msf" && sudo msfconsole -q'
abbr -a sesp 'searchsploit'
abbr -a ptime 'sudo pentest-time -r Europe/Stockholm'
abbr -a htblabs 'sudo openvpn ~/Downloads/lab_griefhoundTCP.ovpn'
abbr -a pyserver 'sudo python -m http.server 8002'

# === DEV ENVIRONMENTS ===
abbr -a bloodhound 'nix develop ~/dotfiles#bloodhound'

function pyenv
    ~/dotfiles/scripts/bash/pyenvshell.sh $argv
end

# === APPLICATIONS ===
abbr -a zath 'zathura --fork=false'
abbr -a zathura 'zathura --fork=false'
abbr -a ai 'aichat -H --save-session -s'
abbr -a x 'startx'
abbr -a nf 'nix search nixpkgs'

# === AUDIO ===
function zenaudio
    sh ~/dotfiles/scripts/bash/zenaudio.sh $argv
end

abbr -a za 'zenaudio'
abbr -a zah 'zenaudio headphones && zenaudio volume 75'
abbr -a zas 'zenaudio speakers && zenaudio volume 75'

# === VISUALS ===
abbr -a w 'wal -Rn'

function walrgb
    sh ~/dotfiles/scripts/bash/walrgb.sh $argv
end

function rgb
    openrgb --device 0 --mode static --color $argv
end

# === XRANDR ===
abbr -a xrandrwide 'xrandr --output HDMI-1 --mode 3440x1440 --output eDP-1 --off && wal -R && killall polybar && polybar -q &'
abbr -a xrandrrestore 'xrandr --output eDP-1 --mode 1920x1200 --output HDMI-1 --off && wal -R && killall polybar && polybar -q &'

# === NETWORK ===
abbr -a nwshow 'nmcli dev wifi show'
abbr -a nwconnect 'nmcli --ask dev wifi connect'

function wifirestore
    sh ~/dotfiles/scripts/bash/wifirestore.sh $argv
end

# === TAILSCALE ===
abbr -a tds 'sudo tailscale file cp'
abbr -a tdr 'sudo tailscale file get'

# === VM/ROUTER ===
abbr -a rc 'sudo virsh console router-vm-passthrough'
abbr -a tui 'sh ~/splix/scripts/router-tui.sh'

# === SCRIPTS ===
function links
    sh ~/dotfiles/scripts/bash/links.sh $argv
end

function link
    sudo python ~/dotfiles/scripts/python/link_file.py $argv
end

function nu
    sh ~/dotfiles/scripts/bash/nixupdate.sh $argv
end

function nixbuild
    sh ~/dotfiles/scripts/bash/nixbuild.sh $argv
end

abbr -a nb 'nixbuild'
