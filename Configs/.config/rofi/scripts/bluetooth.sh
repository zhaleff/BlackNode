#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
LIST_THEME="$R/styles/bluetooth-list.rasi"

check_bt() {
    if ! systemctl is-active --quiet bluetooth; then
        notify-send "Error" "Bluetooth is not running."
        exit 1
    fi
}

main_menu() {
    local bt_status
    bt_status=$(bluetoothctl show | grep -c "Powered: yes")
    if [[ "$bt_status" -gt 0 ]]; then
        local options=" \n󰂯 \n󰅖 \n "
    else
        local options=" \n󰂯 \n󰂲 \n "
    fi
    local choice
    choice=$(printf '%b' "$options" | rofi -dmenu -p "󰂯" -theme-str "listview { lines: 4; }" -theme "$MENU_THEME")
    case "$choice" in
        " ") scan_devices ;;
        "󰂯 ") paired_devices ;;
        "󰅖 ") bluetoothctl power off && notify-send "Bluetooth" "Disabled" && main_menu ;;
        "󰂲 ") bluetoothctl power on && notify-send "Bluetooth" "Enabled" && main_menu ;;
        " ") exit 0 ;;
    esac
}

scan_devices() {
    bluetoothctl scan on &>/dev/null &
    sleep 3
    kill %1 &>/dev/null
    local devices
    devices=$(bluetoothctl devices | sort -u)
    if [ -z "$devices" ]; then
        notify-send "Bluetooth" "No devices found."
        main_menu
        return
    fi
    local selected
    selected=$(echo "$devices" | rofi -dmenu -p "Devices" -theme "$LIST_THEME")
    if [ -n "$selected" ]; then
        local mac
        mac=$(echo "$selected" | awk '{print $2}')
        connect_device "$mac"
    else
        main_menu
    fi
}

paired_devices() {
    local devices
    devices=$(bluetoothctl paired-devices | sort -u)
    if [ -z "$devices" ]; then
        notify-send "Bluetooth" "No paired devices."
        main_menu
        return
    fi
    local selected
    selected=$(echo "$devices" | rofi -dmenu -p "Paired" -theme "$LIST_THEME")
    if [ -n "$selected" ]; then
        local mac
        mac=$(echo "$selected" | awk '{print $2}')
        local connected
        connected=$(bluetoothctl info "$mac" | grep -c "Connected: yes")
        if [[ "$connected" -gt 0 ]]; then
            bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Disconnected"
        else
            bluetoothctl connect "$mac" && notify-send "Bluetooth" "Connected" || notify-send "Bluetooth" "Failed"
        fi
    fi
    main_menu
}

connect_device() {
    local mac="$1"
    local paired
    paired=$(bluetoothctl paired-devices | grep -c "$mac")
    if [[ "$paired" -gt 0 ]]; then
        bluetoothctl connect "$mac" && notify-send "Bluetooth" "Connected" || notify-send "Bluetooth" "Failed"
    else
        bluetoothctl pair "$mac" && bluetoothctl connect "$mac" && notify-send "Bluetooth" "Paired & connected" || notify-send "Bluetooth" "Failed"
    fi
    main_menu
}

check_bt
main_menu
