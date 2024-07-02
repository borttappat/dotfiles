#!/run/current-system/sw/bin/bash
if ! pgrep -f "python3 -m http.server 8000" > /dev/null; then
    cd ~/dotfiles/misc
    nohup python3 -m http.server 8000 --bind 127.0.0.1 > /dev/null 2>&1 &
fi
