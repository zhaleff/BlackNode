#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/network"

notify_connected() {
    local ssid="$1"
    notify-send -i "$ICON_DIR/wifi-strong.svg" "WiFi" "$ssid connected"
}

notify_disconnected() {
    notify-send -i "$ICON_DIR/wifi-disconnected.svg" "WiFi" "Disconnected"
}

notify_no_network() {
    notify-send -i "$ICON_DIR/wifi-no-network.svg" "WiFi" "No network available"
}

LC_ALL=C nmcli monitor | while read -r line; do
    case "$line" in
        *"unavailable"*)
            notify_no_network ;;
        *"using connection"*)
            ssid=$(echo "$line" | sed -n "s/.*'\(.*\)'.*/\1/p")
            notify_connected "$ssid" ;;
        *"wlan0: disconnected"*)
            notify_disconnected ;;
    esac
done
