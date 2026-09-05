#!/usr/bin/env bash
killall -q waybar
waybar 2>&1 | tee -a /tmp/waybar.log &
disown
echo "Bars launched..."