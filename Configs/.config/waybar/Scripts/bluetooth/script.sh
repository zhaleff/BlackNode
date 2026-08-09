#!/usr/bin/env bash

powered=$(bluetoothctl show | grep -q "Powered: yes" && echo "on" || echo "off")

if [ "$powered" = "off" ]; then
    printf '{"text":"󰂲","tooltip":"Bluetooth is off","class":"off","alt":"off"}\n'
    exit 0
fi

mapfile -t connected < <(bluetoothctl devices Connected)

if [ "${#connected[@]}" -eq 0 ]; then
    printf '{"text":"󰂯","tooltip":"Bluetooth is on\\nNo devices connected","class":"on","alt":"on"}\n'
    exit 0
fi

device_icon() {
    case "$1" in
        audio-card*|audio-headset*|audio-headphones*) printf '󰋋' ;;
        input-mouse*) printf '󰍽' ;;
        input-keyboard*) printf '󰌌' ;;
        input-gaming*) printf '󰊴' ;;
        phone*) printf '󰄜' ;;
        computer*) printf '󰇅' ;;
        *) printf '󰦢' ;;
    esac
}

tooltip=""
count="${#connected[@]}"

while read -r _ mac name; do
    [ -z "$mac" ] && continue
    info=$(bluetoothctl info "$mac")
    battery=$(echo "$info" | grep "Battery Percentage" | grep -oP '\(\K[0-9]+')
    icon_type=$(echo "$info" | grep "Icon:" | awk '{print $2}')
    icon=$(device_icon "$icon_type")

    label="${icon} ${name}"
    if [ -n "$battery" ]; then
        label="${label} — ${battery}%"
    fi

    if [ -n "$tooltip" ]; then
        tooltip="${tooltip}\n${label}"
    else
        tooltip="${label}"
    fi
done < <(bluetoothctl devices Connected)

text="󰂱"
if [ "$count" -gt 1 ]; then
    text="${text} ${count}"
fi

tooltip="Connected\n${tooltip}"

printf '{"text":"%s","tooltip":"%s","class":"connected","alt":"connected"}\n' "$text" "$tooltip"
