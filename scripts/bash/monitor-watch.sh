#!/run/current-system/sw/bin/bash
# Re-applies the preferred display mode (xrandr --auto) whenever the screen
# configuration changes. Mainly for VM guests: the host can resize the virtual
# display, but the guest keeps the old resolution until xrandr is run. This
# watches for that change and applies it automatically.
#
# Singleton: a second copy (e.g. after an i3 restart) exits immediately.
set -u

export DISPLAY="${DISPLAY:-:0}"

# Bail if another instance is already running.
self=$$
for pid in $(pgrep -f "monitor-watch.sh" 2>/dev/null); do
    [ "$pid" = "$self" ] && continue
    exit 0
done

last=""
while true; do
    cur=$(xrandr --query 2>/dev/null || true)
    if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
        # Apply the preferred mode to any connected virtual (VM) output.
        for out in $(printf '%s\n' "$cur" | grep -E "^(Virtual|qxl).* connected" | cut -d' ' -f1); do
            xrandr --output "$out" --auto 2>/dev/null || true
        done
        # Refresh the bars for the (possibly) new geometry.
        ~/dotfiles/scripts/bash/polybar-restart.sh >/dev/null 2>&1 || true
        last=$(xrandr --query 2>/dev/null || true)
    fi
    sleep 2
done
