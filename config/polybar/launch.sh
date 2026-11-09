#!/usr/bin/env bash
set -euo pipefail

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar"

# Terminate already running bar instances
pkill -x polybar 2>/dev/null || true

# Wait until the processes have been shut down
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

# Launch one bar per connected monitor.
mapfile -t monitors < <(polybar --list-monitors | cut -d: -f1)

if [[ ${#monitors[@]} -eq 0 ]]; then
    # Fallback: let Polybar pick the default monitor.
    polybar -q main -c "$DIR/config.ini" &
else
    for monitor in "${monitors[@]}"; do
        MONITOR="$monitor" polybar -q main -c "$DIR/config.ini" &
    done
fi
