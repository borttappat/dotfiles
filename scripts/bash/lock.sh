#!/run/current-system/sw/bin/bash

# Kill any existing instances of i3lock
killall -q i3lock

# Wait a moment for any existing instances to close
sleep 0.1

# Source wal colors
. "$HOME/.cache/wal/colors.sh"

# Convert to RGBA format
alpha='ff'
background="${color0}ff"     # Using color0 from pywal instead of pure black    
foreground="${foreground}ff"    
accent="${color1}ff"           

# Try to run i3lock with error handling
if ! i3lock \
  --color="${background:1}"                 \
  --insidever-color="${color0:1}"          \
  --insidewrong-color="${color1:1}"        \
  --inside-color="${color0:1}"             \
  --ringver-color="${color2:1}"            \
  --ringwrong-color="${color1:1}"          \
  --ring-color="${color2:1}"               \
  --line-color="${color0:1}"               \
  --keyhl-color="${color2:1}"              \
  --bshl-color="${color1:1}"               \
  --separator-color="${color0:1}"           \
  --verif-color="${color7:1}"              \
  --wrong-color="${color1:1}"              \
  --layout-color="${color7:1}"             \
  --time-color="${color7:1}"               \
  --date-color="${color7:1}"               \
  --greeter-color="${color7:1}"            \
  --time-str="%H:%M:%S"                    \
  --date-str="%A, %Y-%m-%d"                \
  --verif-text="verifying..."              \
  --wrong-text="incorrect"                 \
  --noinput-text="empty"                   \
  --lock-text="locking..."                 \
  --lockfailed-text="lock failed"          \
  --time-font="CozetteVector"              \
  --date-font="CozetteVector"              \
  --layout-font="CozetteVector"            \
  --verif-font="CozetteVector"             \
  --wrong-font="CozetteVector"             \
  --radius=25                              \
  --ring-width=3                           \
  --screen 1                               \
  --clock                                  \
  --indicator                              \
  --keylayout 2                            \
  --time-size=48                           \
  --date-size=24                           \
  --layout-size=18                         \
  --verif-size=18                          \
  --wrong-size=18                          \
  --ind-pos="x+w/2:y+h/2-40"              \
  --time-pos="ix:iy-100"                   \
  --date-pos="tx:ty+25"                    \
  --status-pos="ix:iy+60"                  \
  --layout-pos="ix:iy+80"                  \
  --verif-pos="ix:iy+60"                   \
  --wrong-pos="ix:iy+60"                   \
  --modif-pos="ix:iy+60"                   \
  --pass-media-keys                        \
  --pass-screen-keys                       \
  --ignore-empty-password; then
    
    # If i3lock fails, try a fallback with minimal options
    i3lock --color="${background:1}" --ignore-empty-password
fi
