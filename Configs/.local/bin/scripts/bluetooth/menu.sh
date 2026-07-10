#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
notify() { notify-send "$1" "$2"; }

main() {
    local choice
    choice=$(printf '%s\n' \
        "󰂯  Paired Devices" \
        "󰂱  Scan for Devices" \
        "󰑐  Disconnect All" \
        "󰅖  Bluetooth Toggle" \
        | rofi -dmenu -i -p "Bluetooth" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "󰂯  Paired Devices") paired_menu ;;
        "󰂱  Scan for Devices") scan_devices ;;
        "󰑐  Disconnect All") disconnect_all ;;
        "󰅖  Bluetooth Toggle") toggle_bt ;;
    esac
}

paired_menu() {
    local devices
    devices=$(bluetoothctl devices | awk '{$1=""; $2=""; print substr($0,3)}')
    [[ -z "$devices" ]] && { notify "Bluetooth" "No paired devices"; return; }

    local choice
    choice=$(printf '%s\n' "$devices" | rofi -dmenu -i -p "Devices" -theme "$ROFI_SUB_THEME")
    [[ -z "$choice" ]] && return

    local mac
    mac=$(bluetoothctl devices | grep "$choice" | awk '{print $2}')

    local info
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    local connected
    connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')

    local action
    if [[ "$connected" == "yes" ]]; then
        action=$(printf 'Disconnect\nInfo\nRemove' | rofi -dmenu -i -p "$choice" -theme "$ROFI_SUB_THEME")
    else
        action=$(printf 'Connect\nInfo\nRemove' | rofi -dmenu -i -p "$choice" -theme "$ROFI_SUB_THEME")
    fi

    case "$action" in
        "Connect") bluetoothctl connect "$mac" && notify "Bluetooth" "Connected: $choice" ;;
        "Disconnect") bluetoothctl disconnect "$mac" && notify "Bluetooth" "Disconnected: $choice" ;;
        "Info")
            local bat battery
            bat=$(echo "$info" | grep "Battery Percentage:" | awk '{print $3}')
            battery="${bat:-N/A}"
            local address=$(echo "$info" | grep "Device" | awk '{print $2}')
            rofi -dmenu -i -p "$choice" -theme "$ROFI_SUB_THEME" \
                -mesg "Name: $choice\nMAC: $address\nConnected: $connected\nBattery: $battery" -lines 6 ;;
        "Remove") bluetoothctl remove "$mac" && notify "Bluetooth" "Removed: $choice" ;;
    esac
}

scan_devices() {
    notify "Bluetooth" "Scanning..."
    bluetoothctl scan on &
    local pid=$!
    sleep 5
    kill "$pid" 2>/dev/null

    local found
    found=$(bluetoothctl devices | awk '{$1=""; $2=""; print substr($0,3)}')
    local choice
    choice=$(printf '%s\n' "$found" | rofi -dmenu -i -p "Found" -theme "$ROFI_SUB_THEME")
    if [[ -n "$choice" ]]; then
        local mac
        mac=$(bluetoothctl devices | grep "$choice" | awk '{print $2}')
        bluetoothctl pair "$mac" && bluetoothctl trust "$mac" && bluetoothctl connect "$mac" && \
            notify "Bluetooth" "Paired: $choice"
    fi
}

disconnect_all() {
    bluetoothctl devices | awk '{print $2}' | while read -r mac; do
        bluetoothctl disconnect "$mac" 2>/dev/null
    done
    notify "Bluetooth" "All disconnected"
}

toggle_bt() {
    local status
    status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    if [[ "$status" == "yes" ]]; then
        bluetoothctl power off
        notify "Bluetooth" "Off"
    else
        bluetoothctl power on
        notify "Bluetooth" "On"
    fi
}

main
