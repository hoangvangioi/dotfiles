#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar"

# Terminate already running bar instances
killall -q polybar 2>/dev/null || true

# Wait until the processes have been shut down (bail out after 3s, otherwise
# i3 waits forever after a crash)
timeout=3
while pgrep -u "${UID}" -x polybar >/dev/null && [ "$timeout" -gt 0 ]; do
    sleep 1
    timeout=$((timeout - 1))
done
pkill -u "${UID}" -x polybar 2>/dev/null || true

# Launch the bar (MONITOR can be overridden, otherwise let polybar pick)
if command -v polybar >/dev/null 2>&1; then
    MONITOR="${MONITOR:-$(polybar -m 2>/dev/null | cut -d: -f1 | head -1)}" \
        polybar -q main -c "${DIR}/config.ini" &
fi
