#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Launch the bar
polybar -q top -c $HOME/.config/polybar/config.ini | tee -a /tmp/polybar.log & disown