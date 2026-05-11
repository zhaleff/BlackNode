#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"

udevadm monitor --subsystem-match=input --subsystem-match=usb --udev 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "add"; then
        sleep 0.5
        NAME=$(udevadm info --query=property --path="$(echo "$line" | awk '{print $NF}')" 2>/dev/null \
            | grep -E "^ID_MODEL=|^NAME=" | head -1 | cut -d= -f2 | tr -d '"' | tr '_' ' ')
        [[ -z "$NAME" ]] && NAME="Unknown device"
        dunstify -a "device" -i "$ASSETS/usb.svg" -t 5000 -r 2597 "Device connected" "$NAME"
    fi
done
