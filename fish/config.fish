#     ___ __       __
#   .'  _|__.-----|  |--.
#   |   _|  |__ --|     |
#   |__| |__|_____|__|__|
#
# === INTERACTIVE BLOCK ===
if status is-interactive
    # Session recording: the first interactive shell in a terminal execs into
    # asciinema, which runs the real fish session (that inner shell sees
    # HYDRIX_REC and does not re-record). On exit the cast is rendered to a
    # plain-text twin (.txt) with `asciinema convert`, which emulates a terminal,
    # so prompt and command-line redraws come out as a readable transcript.
    if test -t 1; and test "$TERM" != linux; and test "$TERM" != dumb; and not set -q HYDRIX_REC
        set -gx HYDRIX_REC 1
        set -l _dir ~/terminal_logs
        mkdir -p $_dir
        set -l _id (date +%Y%m%d-%H%M%S)-(openssl rand -hex 3)
        set -gx HYDRIX_REC_FILE "$_dir/$_id.cast"
        set -gx HYDRIX_REC_STOP "/tmp/.hydrix-rec-stop-$_id"
        set -gx HYDRIX_REC_MOVED "/tmp/.hydrix-rec-moved-$_id"
        asciinema rec --quiet -c fish "$HYDRIX_REC_FILE"
        # `rec -r` renamed the session: render the twin next to the new name.
        set -l _cast "$HYDRIX_REC_FILE"
        test -s "$HYDRIX_REC_MOVED"; and read _cast <"$HYDRIX_REC_MOVED"
        rm -f "$HYDRIX_REC_MOVED"
        asciinema convert --overwrite -f txt "$_cast" (path change-extension txt -- "$_cast") 2>/dev/null
        # stop-recording left a sentinel: continue in a plain, unrecorded shell
        # rather than closing the terminal.
        if test -e "$HYDRIX_REC_STOP"
            rm -f "$HYDRIX_REC_STOP"
            set -e HYDRIX_REC_FILE
            set -e HYDRIX_REC_STOP
            set -e HYDRIX_REC_MOVED
            exec fish
        end
        exit
    end

    cat /home/traum/.cache/wal/sequences
    fish_vi_key_bindings

    # Toggle the recorder without closing the terminal: stop ends the current
    # recording and drops to a plain shell; start begins a fresh recording.
    function stop-recording --description "Stop recording this terminal"
        if not set -q HYDRIX_REC_FILE
            echo "Not recording."
            return 1
        end
        command touch "$HYDRIX_REC_STOP"
        exit
    end
    function start-recording --description "Start recording this terminal"
        if set -q HYDRIX_REC_FILE
            echo "Already recording: $HYDRIX_REC_FILE"
            return 1
        end
        set -e HYDRIX_REC
        exec fish
    end

    # rec: inspect, name and print this terminal's recordings. A rename moves the
    # live .cast (asciinema keeps writing through its open descriptor) and leaves
    # the new path in $HYDRIX_REC_MOVED, so the outer shell renders the .txt twin
    # under the new name, and nested shells pick it up on their next `rec`.
    function __rec_find --argument-names dir arg
        if test -f "$arg"
            path resolve -- "$arg"
            return
        end
        set -l base (string replace -r '\.(cast|txt)$' "" -- (path basename -- "$arg"))
        if test -f "$dir/$base.cast"
            echo "$dir/$base.cast"
            return
        end
        set -l hits $dir/*$base*.cast
        switch (count $hits)
            case 1
                echo $hits
            case 0
                echo "rec: no session matching '$arg'" >&2
                return 1
            case '*'
                echo "rec: '$arg' matches several sessions:" >&2
                printf '  %s\n' (path change-extension "" (path basename -- $hits)) >&2
                return 1
        end
    end

    # A finished session prints its .txt twin; a live one (this or another
    # terminal) is rendered from a snapshot of its .cast.
    function __rec_show --argument-names f
        set -l txt (path change-extension txt -- "$f")
        if test "$f" != "$HYDRIX_REC_FILE"; and test -f "$txt"
            command cat -- "$txt"
        else
            command rec-text "$f"
        end
    end

    function rec --description "List, rename and print terminal recordings"
        set -l dir ~/terminal_logs
        if set -q HYDRIX_REC_MOVED; and test -s "$HYDRIX_REC_MOVED"
            read -l moved <"$HYDRIX_REC_MOVED"; and set -gx HYDRIX_REC_FILE "$moved"
        end
        set -l flag $argv[1]
        set -e argv[1]
        switch "$flag"
            case "" -c
                if not set -q HYDRIX_REC_FILE
                    echo "Not recording."
                    return 1
                end
                echo (path change-extension "" (path basename -- "$HYDRIX_REC_FILE"))"  $HYDRIX_REC_FILE"
            case -l
                set -l files $dir/*.cast
                if test (count $files) -eq 0
                    echo "No recordings in $dir"
                    return
                end
                for f in (command ls -tr -- $files)
                    set -l mark " "
                    test "$f" = "$HYDRIX_REC_FILE"; and set mark "*"
                    printf '%s %-32s %s  %5s\n' $mark (path change-extension "" (path basename -- "$f")) \
                        (date -r "$f" '+%Y-%m-%d %H:%M') (numfmt --to=iec (stat -c %s "$f"))
                end
            case -r
                if not set -q HYDRIX_REC_FILE
                    echo "Not recording." >&2
                    return 1
                end
                if not set -q HYDRIX_REC_MOVED
                    echo "rec: this recording predates rename support; open a new terminal" >&2
                    return 1
                end
                set -l name (string replace -r '\.cast$' "" -- "$argv[1]")
                if not string match -qr '^[A-Za-z0-9][A-Za-z0-9._-]*$' -- "$name"
                    echo "Usage: rec -r NAME  (letters, digits, . _ -)" >&2
                    return 1
                end
                set -l new "$dir/$name.cast"
                test "$new" = "$HYDRIX_REC_FILE"; and return
                if test -e "$new"; or test -e "$dir/$name.txt"
                    echo "rec: '$name' already exists" >&2
                    return 1
                end
                command mv -n -- "$HYDRIX_REC_FILE" "$new"; or return 1
                printf '%s\n' "$new" >"$HYDRIX_REC_MOVED"
                set -gx HYDRIX_REC_FILE "$new"
                echo "Recording renamed: $name"
            case -p
                set -l f
                if set -q argv[1]
                    set f (__rec_find $dir "$argv[1]"); or return 1
                else if set -q HYDRIX_REC_FILE
                    set f "$HYDRIX_REC_FILE"
                else
                    echo "Not recording; name a session (rec -l)." >&2
                    return 1
                end
                __rec_show "$f"
            case -a
                set -l files $dir/*.cast
                test (count $files) -eq 0; and return
                for f in (command ls -tr -- $files)
                    printf '\n==> %s <==\n' (path change-extension "" (path basename -- "$f"))
                    __rec_show "$f"
                end
            case '*'
                printf '%s\n' >&2 \
                    "Usage: rec [-c | -l | -r NAME | -p [SESSION] | -a]" \
                    "  -c            show the current session (default)" \
                    "  -l            list sessions, oldest first (* = this terminal)" \
                    "  -r NAME       rename the current session" \
                    "  -p [SESSION]  print one session as text (default: current)" \
                    "  -a            print every session as text" \
                    "SESSION is a name, a unique part of one, or a path."
                test "$flag" = -h; or return 1
        end
    end

    # `cat`-ing the live recording would feed its own output back into the
    # growing file and loop; show a clean text render instead. Every other
    # `cat` passes straight through unchanged.
    if set -q HYDRIX_REC_FILE
        function cat
            if test (count $argv) -eq 1
                set -l _rp (command realpath -- $argv[1] 2>/dev/null)
                if test "$_rp" = "$HYDRIX_REC_FILE"
                    command rec-text "$HYDRIX_REC_FILE"
                    return
                end
            end
            command cat $argv
        end
    end
end

# === CURSOR SETTINGS ===
set fish_cursor_default underscore blink
set fish_cursor_insert underscore blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual underscore blink

# === INITS ===
# Starship
starship init fish | source

# Zoxide
zoxide init fish | source

# Save current directory whenever PWD changes
function __save_last_dir --on-variable PWD
    echo $PWD > /tmp/last_fish_dir
end

# === DIRECTORY-MEMORY ===
# Restore last directory on shell startup
if status is-interactive
    and test -f /tmp/last_fish_dir
    set -l last_dir (cat /tmp/last_fish_dir)
    if test -d "$last_dir"
        cd "$last_dir"
    end
end

# === MKCD ===
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end


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
abbr -a ... 'cd ../..'
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

# === FILE SORTING ===
function filesort
    set -l target_dir $argv[1]
    
    if test -z "$target_dir"
        set target_dir .
    end
    
    if not test -d "$target_dir"
        echo "Error: $target_dir is not a directory"
        return 1
    end
    
    for file in $target_dir/*
        if not test -f "$file"
            continue
        end
        
        set -l basename (basename $file)
        set -l ext (string match -r '\.[^.]+$' $basename | string sub -s 2)
        
        if test -n "$ext"
            mkdir -p "$target_dir/$ext"
            mv "$file" "$target_dir/$ext/"
        else
            mkdir -p "$target_dir/no_extension"
            mv "$file" "$target_dir/no_extension/"
        end
    end
    
    echo "Files sorted by extension in $target_dir"
end

# === FILE LISTING ===
abbr -a ls 'eza -A --color=always --group-directories-first'
abbr -a l 'eza -Al --color=always --group-directories-first'
abbr -a lt 'eza -AT --color=always --group-directories-first'

function sls
    ls | grep -i $argv
end

function sl
    eza -Al --color=always --group-directories-first | grep -i $argv
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
abbr -a g 'glances'
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
abbr -a guestconf 'vim ~/dotfiles/modules/guest.nix'
abbr -a hostconf 'vim ~/dotfiles/modules/host.nix'
abbr -a hwconf 'vim ~/dotfiles/modules/hwconf.nix'
abbr -a guestagentsconf 'vim ~/dotfiles/modules/guest-agents.nix'
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

# On-demand pentest toolsets (modules/shells)
abbr -a AppSec 'nix develop ~/dotfiles#appsec'
abbr -a NetSec 'nix develop ~/dotfiles#netsec'
abbr -a appsec 'nix develop ~/dotfiles#appsec'
abbr -a netsec 'nix develop ~/dotfiles#netsec'
abbr -a wifisec 'nix develop ~/dotfiles#wifi'
abbr -a forensics 'nix develop ~/dotfiles#forensics'
abbr -a osint 'nix develop ~/dotfiles#osint'
abbr -a cracking 'nix develop ~/dotfiles#cracking'

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
abbr -a zab 'zenaudio bluetooth && zenaudio volume 75'

# === VISUALS ===
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
