#!/bin/bash

function check_status() {
    is_paused=$(dunstctl is-paused)
    if [[ $is_paused == true ]]; then
        echo " "
    else
        echo " "
    fi
}

case "$1" in
    toggle)
        dunstctl set-paused toggle
        ;;
    show)
        dunstctl history-pop
        ;;
    output)
        check_status
        ;;
esac
