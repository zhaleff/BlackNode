#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q waybar

# Launch bar1 and bar2
waybar 2>&1 | tee -a /tmp/waybar.log &
disown

echo "Bars launched..."
