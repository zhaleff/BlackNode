#!/bin/bash

STYLE="$HOME/.config/rofi/bluetooth/style.rasi"

notify() { dunstify -a "bluetooth" -t 3000 "$1" "$2"; }

scan_devices() {
    bluetoothctl scan on &>/dev/null &
    sleep 4
    kill %1 &>/dev/null
}

list_devices() {
    bluetoothctl devices | while read -r _ mac name; do
        connected=$(bluetoothctl info "$mac" | grep -c "Connected: yes")
        paired=$(bluetoothctl info "$mac" | grep -c "Paired: yes")
        if [[ "$connected" -gt 0 ]]; then
            echo "󰂱  $name ($mac)"
        elif [[ "$paired" -gt 0 ]]; then
            echo "󰂯  $name ($mac)"
        else
            echo "󰂲  $name ($mac)"
        fi
    done
}

POWER=$(bluetoothctl show | grep -c "Powered: yes")

if [[ "$POWER" -eq 0 ]]; then
    MENU="󰂯  Enable Bluetooth"
else
    MENU="󰂲  Disable Bluetooth\n󰂱  Scan devices\n$(list_devices)"
fi

CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "󰂯" -theme "$STYLE")
[[ -z "$CHOICE" ]] && exit 0

MAC=$(echo "$CHOICE" | grep -o '[A-F0-9:]\{17\}')

case "$CHOICE" in
    *"Enable Bluetooth"*)
        bluetoothctl power on
        notify "Bluetooth on" ""
        ;;
    *"Disable Bluetooth"*)
        bluetoothctl power off
        notify "Bluetooth off" ""
        ;;
    *"Scan devices"*)
        notify "Scanning..." "Looking for devices"
        scan_devices
        exec "$0"
        ;;
    *"󰂱"*)
        bluetoothctl disconnect "$MAC"
        notify "Disconnected" "$(echo "$CHOICE" | sed 's/󰂱  //;s/ (.*//')"
        ;;
    *"󰂯"*)
        bluetoothctl connect "$MAC" && \
            notify "Connected" "$(echo "$CHOICE" | sed 's/󰂯  //;s/ (.*//')" || \
            notify "Failed" "Could not connect"
        ;;
    *"󰂲"*)
        bluetoothctl pair "$MAC" && bluetoothctl connect "$MAC" && \
            notify "Paired & connected" "$(echo "$CHOICE" | sed 's/󰂲  //;s/ (.*//')" || \
            notify "Failed" "Could not pair"
        ;;
esac
