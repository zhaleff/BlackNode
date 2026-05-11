#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"
BL="/sys/class/backlight"
LEVEL=$(( ($(cat "$BL"/*/brightness) * 100) / $(cat "$BL"/*/max_brightness) ))

dunstify -h int:value:"$LEVEL" -i "$ASSETS/brightness.svg" -t 500 -r 2593 "Brightness: $LEVEL%"
