#!/usr/bin/env bash

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo '{"text":"󰂲","tooltip":"Bluetooth off","class":"off"}'
    exit 0
fi

devices=$(bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-)

if [ -z "$devices" ]; then
    echo '{"text":"󰂯","tooltip":"Bluetooth on, no devices","class":"on"}'
    exit 0
fi

tooltip=$(printf "Bluetooth devices:\n%s" "$devices")

jq -nc --arg tooltip "$tooltip" '{text: "󰂱", tooltip: $tooltip, class: "connected"}'
