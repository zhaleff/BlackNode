#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/plug.svg"

get_capacity() {
    cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
}

is_charging() {
    [ "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)" = "Charging" ]
}

was_charging=false

while true; do
    if is_charging && [ "$was_charging" = false ]; then
        notify-send -i "$ICON" "Battery" "Charger connected - $(get_capacity)%"
        was_charging=true
    elif ! is_charging; then
        was_charging=false
    fi
    sleep 5
done
