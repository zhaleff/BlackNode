#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

if ! systemctl is-active --quiet bluetooth; then
    exit 1
fi

bt_on() {
    [[ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2}')" == "yes" ]]
}

toggle_bt() {
    if bt_on; then
        bluetoothctl power off &>/dev/null
    else
        bluetoothctl power on &>/dev/null
    fi
    main_menu
}

paired_menu() {
    local menu_input selected_line mac
    declare -a macs

    menu_input="󰌍  Back"$'\n'"󱉶  Scan"$'\n'

    while IFS=$'\t' read -r mac_addr name connected; do
        [[ -z "$mac_addr" ]] && continue
        macs+=("$mac_addr")
        local icon="󰂯"
        [[ "$connected" == "yes" ]] && icon="󰂱"
        menu_input+="${icon}  ${name}"$'\n'
    done < <(bluetoothctl devices 2>/dev/null | while read -r _ addr name; do
        connected=$(bluetoothctl info "$addr" 2>/dev/null | awk -F': ' '/Connected:/{print $2}')
        printf '%s\t%s\t%s\n' "$addr" "$name" "$connected"
    done)

    selected_line=$(printf '%s' "$menu_input" | rofi -dmenu -theme "$THEME" -p "Devices" -format i)

    [[ -z "$selected_line" || "$selected_line" -eq 0 ]] && { main_menu; return; }
    [[ "$selected_line" -eq 1 ]] && { scan_menu; return; }

    mac="${macs[$((selected_line - 2))]}"
    [[ -z "$mac" ]] && { paired_menu; return; }

    local connected
    connected=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Connected:/{print $2}')

    if [[ "$connected" == "yes" ]]; then
        bluetoothctl disconnect "$mac" &>/dev/null
    else
        bluetoothctl connect "$mac" &>/dev/null
    fi
    paired_menu
}

scan_menu() {
    bluetoothctl --timeout 8 scan on &>/dev/null
    paired_menu
}

main_menu() {
    local toggle_label="Turn On"
    bt_on && toggle_label="Turn Off"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰂯  Devices" \
        "  ${toggle_label}" \
        | rofi -dmenu -theme "$THEME" -p "Bluetooth")

    case "$choice" in
        *"Back")    exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Devices") paired_menu ;;
        *"On"|*"Off") toggle_bt ;;
    esac
}

main_menu
