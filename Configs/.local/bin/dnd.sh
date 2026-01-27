#!/usr/bin/env bash

state=$(dunstctl is-paused)

if [ "$state" = "false" ]; then
    dunstctl set-paused true
else
    dunstctl set-paused false
    notify-send "Do not disturb disabled"
fi

