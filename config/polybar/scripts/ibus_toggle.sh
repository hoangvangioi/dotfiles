#!/bin/bash
engine=$(ibus engine)

# Set your engine here
ENGLISH="xkb:us::eng"
VIETNAM="Bamboo"

if [[ "$engine" == "$ENGLISH" ]]; then
    ibus engine $VIETNAM
    polybar-msg hook ibus 1 &>/dev/null || true
    #  Disable line below if you dont want to recive notifocation
    dunstify -h string:x-dunst-stack-tag:ibus -A 'ibus,default' -a "IBUS" -i "~/.config/polybar/scripts/flags/vietnam.svg" "VI"
else
    ibus engine $ENGLISH
    polybar-msg hook ibus 1 &>/dev/null || true
    #  Disable line below if you dont want to recive notifocation
    dunstify -h string:x-dunst-stack-tag:ibus -A 'ibus,default' -a "IBUS" -i "~/.config/polybar/flags/united-states.svg" "US"
fi
