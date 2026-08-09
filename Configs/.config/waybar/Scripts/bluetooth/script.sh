#!/usr/bin/env bash

powered=$(bluetoothctl show | grep -q "Powered: yes" && echo "on" || echo "off")

if [ "$powered" = "off" ]; then
    printf '{"text":"\u f6b2","tooltip":"Bluetooth is off","class":"off","alt":"off"}\n'
    exit 0
fi

mapfile -t connected < <(bluetoothctl devices Connected)

if [ "${#connected[@]}" -eq 0 ]; then
    printf '{"text":"\uf294","tooltip":"Bluetooth is on\\nNo devices connected","class":"on","alt":"on"}\n'
    exit 0
fi

tooltip=""
count="${#connected[@]}"

while read -r _ mac name; do
    [ -z "$mac" ] && continue
    info=$(bluetoothctl info "$mac")
    battery=$(echo "$info" | grep "Battery Percentage" | grep -oP '\(\K[0-9]+')
    label="$name"
    if [ -n "$battery" ]; then
        label="$label ${battery}%"
    fi
    if [ -n "$tooltip" ]; then
        tooltip="${tooltip}\n${label}"
    else
        tooltip="${label}"
    fi
done < <(bluetoothctl devices Connected)

text="\uf294"
if [ "$count" -gt 1 ]; then
    text="${text} ${count}"
fi

tooltip="Connected\n${tooltip}"

printf '{"text":"%s","tooltip":"%s","class":"connected","alt":"connected"}\n' "$text" "$tooltip"
