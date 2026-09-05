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
        local name
        name=$(echo "$line" | awk '{$1=""; $2=""; print substr($0,3)}')
        local mac
        mac=$(echo "$line" | awk '{print $2}')
        local info connected
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')
        local icon="󰂯"
        [ "$connected" = "yes" ] && icon="󰂱"
        input+="${icon}  ${name}"$'\n'
    done <<< "$devices"

    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Paired Devices")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return

    local sel_name
    sel_name=$(echo "$selected" | sed 's/.*  //')
    local mac
    mac=$(bluetoothctl devices 2>/dev/null | grep "$sel_name" | awk '{print $2}')
    [ -z "$mac" ] && main_menu && return

    local info connected
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')

    local action
    if [ "$connected" = "yes" ]; then
        action=$(printf '%s\n' "󰌍  Back" "󰅖  Disconnect" "󰋑  Info" "󰍴  Remove" | rofi -dmenu -theme "$THEME" -p "$sel_name")
    else
        action=$(printf '%s\n' "󰌍  Back" "󰂰  Connect" "󰋑  Info" "󰍴  Remove" | rofi -dmenu -theme "$THEME" -p "$sel_name")
    fi

    case "$action" in
        *"Back")        paired_menu ;;
        *"Connect")     bt_connect "$mac" && notify-send "Bluetooth" "Connected: $sel_name" ;;
        *"Disconnect")  bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Disconnected: $sel_name" ;;
        *"Info")
            local bat battery address
            bat=$(echo "$info" | grep "Battery Percentage:" | awk '{print $3}')
            battery="${bat:-N/A}"
            address=$(echo "$info" | grep "Device" | awk '{print $2}')
            rofi -dmenu -theme "$THEME" -p "$sel_name" \
                -mesg "Name: $sel_name\nMAC: $address\nConnected: $connected\nBattery: $battery" -l 6 ;;
        *"Remove")      bluetoothctl remove "$mac" && notify-send "Bluetooth" "Removed: $sel_name" ;;
    esac
    main_menu
}

scan_devices() {
    notify-send "Bluetooth" "Scanning..."
    bluetoothctl scan on &
    local pid=$!
    sleep 5
    kill "$pid" 2>/dev/null

    local found
    found=$(bluetoothctl devices 2>/dev/null)
    [ -z "$found" ] && { notify-send "Bluetooth" "No devices found"; main_menu; return; }

    local input=""
    while IFS= read -r line; do
        local name
        name=$(echo "$line" | awk '{$1=""; $2=""; print substr($0,3)}')
        local mac
        mac=$(echo "$line" | awk '{print $2}')
        local info paired
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        paired=$(echo "$info" | grep "Paired:" | awk '{print $2}')
        local icon="󰂯"
        [ "$paired" = "yes" ] && icon="󰂱"
        input+="${icon}  ${name}"$'\n'
    done <<< "$found"

    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Scan Devices")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return

    local sel_name
    sel_name=$(echo "$selected" | sed 's/.*  //')
    local mac
    mac=$(bluetoothctl devices 2>/dev/null | grep "$sel_name" | awk '{print $2}')
    [ -z "$mac" ] && main_menu && return

    local info paired
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    paired=$(echo "$info" | grep "Paired:" | awk '{print $2}')

    if [ "$paired" != "yes" ]; then
        bluetoothctl pair "$mac" 2>/dev/null || { notify-send "Bluetooth" "Failed to pair"; main_menu; return; }
    fi
    bluetoothctl trust "$mac" 2>/dev/null
    bt_connect "$mac" && notify-send "Bluetooth" "Connected: $sel_name" || notify-send "Bluetooth" "Failed to connect"
    main_menu
}

disconnect_all() {
    bluetoothctl devices 2>/dev/null | awk '{print $2}' | while read -r mac; do
        bluetoothctl disconnect "$mac" 2>/dev/null
    done
    notify-send "Bluetooth" "All disconnected"
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
        "󰂯  Paired Devices" \
        "󰂱  Scan Devices" \
        "󰑐  Disconnect All" \
        "$toggle_icon  Toggle" \
        | rofi -dmenu -theme "$THEME" -p "󰂯  Bluetooth")

    case "$choice" in
        *"Back")            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Paired Devices")  paired_menu ;;
        *"Scan Devices")    scan_devices ;;
        *"Disconnect All")  disconnect_all ;;
        *"Toggle")          toggle_bt; main_menu ;;
    esac
}

main_menu
