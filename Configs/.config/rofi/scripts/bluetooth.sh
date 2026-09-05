#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

if ! systemctl is-active --quiet bluetooth; then
    notify-send "Bluetooth" "Bluetooth is not running."
    exit 1
fi

bt_on() {
    [ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}')" = "yes" ]
}

scan_devices() {
    bluetoothctl scan on &>/dev/null &
    local pid=$!; sleep 3; kill "$pid" &>/dev/null
    local devices
    devices=$(bluetoothctl devices 2>/dev/null | sort -u)
    if [ -z "$devices" ]; then
        notify-send "Bluetooth" "No devices found."
        main_menu
        return
    fi
    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$devices" | rofi -dmenu -theme "$THEME" -p "Scan Devices")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local mac
    mac=$(echo "$selected" | awk '{print $2}')
    [ -z "$mac" ] && main_menu && return
    connect_device "$mac"
    main_menu
}

paired_devices() {
    local devices
    devices=$(bluetoothctl paired-devices 2>/dev/null | sort -u)
    if [ -z "$devices" ]; then
        notify-send "Bluetooth" "No paired devices."
        main_menu
        return
    fi
    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$devices" | rofi -dmenu -theme "$THEME" -p "Paired Devices")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local mac
    mac=$(echo "$selected" | awk '{print $2}')
    [ -z "$mac" ] && main_menu && return
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$mac" >/dev/null 2>&1 && notify-send "Bluetooth" "Disconnected"
    else
        bluetoothctl connect "$mac" >/dev/null 2>&1 && notify-send "Bluetooth" "Connected" || notify-send "Bluetooth" "Failed"
    fi
    main_menu
}

connect_device() {
    local mac="$1"
    if bluetoothctl paired-devices 2>/dev/null | grep -q "$mac"; then
        bluetoothctl connect "$mac" >/dev/null 2>&1 && notify-send "Bluetooth" "Connected" || notify-send "Bluetooth" "Failed"
    else
        bluetoothctl pair "$mac" >/dev/null 2>&1 \
            && bluetoothctl connect "$mac" >/dev/null 2>&1 \
            && notify-send "Bluetooth" "Paired & connected" || notify-send "Bluetooth" "Failed"
    fi
}

toggle_bluetooth() {
    if bt_on; then
        bluetoothctl power off >/dev/null 2>&1 && notify-send "Bluetooth" "Bluetooth off"
    else
        bluetoothctl power on >/dev/null 2>&1 && notify-send "Bluetooth" "Bluetooth on"
    fi
}

main_menu() {
    local toggle_label="Turn On"
    bt_on && toggle_label="Turn Off"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  Scan Devices" \
        "  Paired Devices" \
        "󰅖  $toggle_label" \
        | rofi -dmenu -theme "$THEME" -p "󰂯 Bluetooth")

    case "$choice" in
        *"Back")            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Scan Devices")   scan_devices ;;
        *"Paired Devices") paired_devices ;;
        *"Turn Off"*)      toggle_bluetooth; main_menu ;;
        *"Turn On"*)       toggle_bluetooth; main_menu ;;
    esac
}

main_menu
