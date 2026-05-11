#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"
IFACE=$(ip route | awk '/default/{print $5; exit}')
PREV=""

while true; do
    STATE=$(cat "/sys/class/net/$IFACE/operstate" 2>/dev/null)

    if [[ "$STATE" != "$PREV" ]]; then
        if [[ "$STATE" == "up" ]]; then
            SSID=$(iw dev "$IFACE" link | awk '/SSID/{print $2}')
            dunstify -a "wifi" -i "$ASSETS/wifi-online.svg" -t 5000 -r 2595 "WiFi — $SSID"
        else
            dunstify -a "wifi" -i "$ASSETS/wifi-offline.svg" -t 5000 -r 2595 "WiFi disconnected"
        fi
        PREV="$STATE"
    fi

    sleep 5
done
