#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

if ! systemctl is-active --quiet bluetooth; then
    exit 1
fi

bt_on() {
    [[ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}')" == "yes" ]]
}

is_connected() { bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"; }
is_trusted()   { bluetoothctl info "$1" 2>/dev/null | grep -q "Trusted: yes"; }

toggle_bt() {
    if bt_on; then
        bluetoothctl power off &>/dev/null
    else
        bluetoothctl power on &>/dev/null
    fi
    main_menu
}

load_devices() {
    local mac name
    macs=()
    names=()
    while read -r _ mac name; do
        macs+=("$mac")
        names+=("$name")
    done
}

device_menu() {
    local mac="$1" name="$2" choice
    local conn="󰂱  Connect" trust="󰄬  Trust"
    is_connected "$mac" && conn="󰂲  Disconnect"
    is_trusted "$mac" && trust="󰅖  Untrust"

    choice=$(printf '%s\n' "󰌍  Back" "$conn" "$trust" "󰆴  Forget" \
        | rofi -dmenu -theme "$THEME" -p "$name")

    case "$choice" in
        *"Back")       devices_menu; return ;;
        *"Disconnect") bluetoothctl disconnect "$mac" &>/dev/null ;;
        *"Connect")    bluetoothctl connect "$mac" &>/dev/null ;;
        *"Untrust")    bluetoothctl untrust "$mac" &>/dev/null ;;
        *"Trust")      bluetoothctl trust "$mac" &>/dev/null ;;
        *"Forget")     bluetoothctl remove "$mac" &>/dev/null; devices_menu; return ;;
        *)             return ;;
    esac
    device_menu "$mac" "$name"
}

devices_menu() {
    local input="󰌍  Back"$'\n' choice icon i
    load_devices < <(bluetoothctl devices Paired 2>/dev/null)

    for i in "${!macs[@]}"; do
        icon="󰂯"
        is_connected "${macs[i]}" && icon="󰂱"
        input+="${icon}  ${names[i]}"$'\n'
    done

    choice=$(printf '%s' "$input" | rofi -dmenu -theme "$THEME" -p "Devices" -format i)
    [[ -z "$choice" || "$choice" -eq 0 ]] && { main_menu; return; }

    device_menu "${macs[$((choice - 1))]}" "${names[$((choice - 1))]}"
}

scan_menu() {
    local input="󰌍  Back"$'\n' choice name mac

    bluetoothctl --timeout 8 scan on &>/dev/null
    # lo que no está en Paired es nuevo
    load_devices < <(bluetoothctl devices | grep -vFf <(bluetoothctl devices Paired))

    for name in "${names[@]}"; do
        input+="󰂯  ${name}"$'\n'
    done

    choice=$(printf '%s' "$input" | rofi -dmenu -theme "$THEME" -p "Scan" -format i)
    [[ -z "$choice" || "$choice" -eq 0 ]] && { main_menu; return; }

    mac="${macs[$((choice - 1))]}"
    bluetoothctl --timeout 20 pair "$mac" &>/dev/null
    bluetoothctl trust "$mac" &>/dev/null
    bluetoothctl connect "$mac" &>/dev/null
    devices_menu
}

main_menu() {
    local toggle_label="󰂲  Turn On"
    bt_on && toggle_label="󰂲  Turn Off"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰂯  Devices" \
        "󱉶  Scan" \
        "${toggle_label}" \
        | rofi -dmenu -theme "$THEME" -p "Bluetooth")

    case "$choice" in
        *"Back")      exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Devices")   devices_menu ;;
        *"Scan")      scan_menu ;;
        *"On"|*"Off") toggle_bt ;;
    esac
}

main_menu
