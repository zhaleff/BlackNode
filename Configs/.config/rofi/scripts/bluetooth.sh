#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

if ! systemctl is-active --quiet bluetooth; then
    notify-send "Bluetooth" "Bluetooth is not running."
    exit 1
fi

bt_on() { [ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}')" = "yes" ]; }

bt_connect() {
    local mac="$1"
    local path="org/bluez/hci0/dev_$(echo "$mac" | tr ':' '_')"
    busctl call org.bluez "/$path" org.bluez.Device1 Connect &>/dev/null
}

paired_menu() {
    local devices
    devices=$(bluetoothctl devices 2>/dev/null)
    [ -z "$devices" ] && { notify-send "Bluetooth" "No paired devices"; main_menu; return; }

    local input=""
    while IFS= read -r line; do
        local name mac info connected icon
        name=$(echo "$line" | awk '{$1=""; $2=""; print substr($0,3)}')
        mac=$(echo "$line" | awk '{print $2}')
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')
        icon="󰂯"
        [ "$connected" = "yes" ] && icon="󰂱"
        input+="${icon}  ${name}"$'\n'
    done <<< "$devices"

    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Devices")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return

    local sel_name mac info connected
    sel_name=$(echo "$selected" | sed 's/.*  //')
    mac=$(bluetoothctl devices 2>/dev/null | grep -F "$sel_name" | awk '{print $2}')
    [ -z "$mac" ] && main_menu && return

    info=$(bluetoothctl info "$mac" 2>/dev/null)
    connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')

    if [ "$connected" = "yes" ]; then
        bluetoothctl disconnect "$mac" 2>/dev/null && notify-send "Bluetooth" "Disconnected: $sel_name"
    else
        bt_connect "$mac" && notify-send "Bluetooth" "Connected: $sel_name" || notify-send "Bluetooth" "Failed"
    fi
    main_menu
}

toggle_bt() {
    if bt_on; then
        bluetoothctl power off 2>/dev/null && notify-send "Bluetooth" "Off"
    else
        bluetoothctl power on 2>/dev/null && notify-send "Bluetooth" "On"
    fi
}

main_menu() {
    local toggle_icon="󰅖"
    bt_on && toggle_icon="󰁹"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰂯  Devices" \
        "$toggle_icon  Toggle" \
        | rofi -dmenu -theme "$THEME" -p "󰂯  Bluetooth")

    case "$choice" in
        *"Back")    exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Devices") paired_menu ;;
        *"Toggle")  toggle_bt; main_menu ;;
    esac
}

main_menu
