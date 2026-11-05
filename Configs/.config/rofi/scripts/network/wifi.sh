#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

if ! systemctl is-active --quiet NetworkManager; then
    exit 1
fi

wifi_on() {
    [[ "$(nmcli radio wifi 2>/dev/null)" == "enabled" ]]
}

signal_icon() {
    local sig="$1" sec="$2"
    if [[ "$sec" == "open" ]]; then
        if   [[ "$sig" -ge 80 ]]; then echo "󰤨"
        elif [[ "$sig" -ge 60 ]]; then echo "󰤥"
        elif [[ "$sig" -ge 40 ]]; then echo "󰤢"
        elif [[ "$sig" -ge 20 ]]; then echo "󰤡"
        else echo "󰤟"
        fi
    else
        if   [[ "$sig" -ge 80 ]]; then echo "󰤩"
        elif [[ "$sig" -ge 60 ]]; then echo "󰤢"
        elif [[ "$sig" -ge 40 ]]; then echo "󰤡"
        elif [[ "$sig" -ge 20 ]]; then echo "󰤟"
        else echo "󰤞"
        fi
    fi
}

connect_to_network() {
    local ssid="$1"

    if nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$ssid"; then
        nmcli connection up "$ssid" &>/dev/null
        return
    fi

    local password
    password=$(rofi -dmenu -theme "$THEME" -p "Password for $ssid" -password)
    [[ -z "$password" ]] && return

    nmcli device wifi connect "$ssid" password "$password" &>/dev/null
}

scan_networks() {
    nmcli device wifi rescan &>/dev/null
    sleep 1

    local menu_input selected_line ssid
    declare -a ssids

    menu_input="󰌍  Back"$'\n'

    while IFS='|' read -r ssid_entry signal security; do
        [[ -z "$ssid_entry" ]] && continue
        ssids+=("$ssid_entry")
        local sec="locked"
        [[ -z "$security" || "$security" == "--" ]] && sec="open"
        menu_input+="$(signal_icon "$signal" "$sec")  ${ssid_entry}"$'\n'
    done < <(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null \
        | awk -F: '$1 != "" {print $1 "|" $2 "|" $3}' | sort -u)

    if [[ ${#ssids[@]} -eq 0 ]]; then
        main_menu
        return
    fi

    selected_line=$(printf '%s' "$menu_input" | rofi -dmenu -theme "$THEME" -p "Select Network" -format i)

    [[ -z "$selected_line" || "$selected_line" -eq 0 ]] && { main_menu; return; }

    ssid="${ssids[$((selected_line - 1))]}"
    [[ -z "$ssid" ]] && { main_menu; return; }

    connect_to_network "$ssid"
    main_menu
}

saved_connections() {
    local menu_input selected_line
    declare -a names

    menu_input="󰌍  Back"$'\n'

    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        names+=("$name")
        menu_input+="${name}"$'\n'
    done < <(nmcli -f NAME -t -m tabular connection show 2>/dev/null | sort -u)

    if [[ ${#names[@]} -eq 0 ]]; then
        main_menu
        return
    fi

    selected_line=$(printf '%s' "$menu_input" | rofi -dmenu -theme "$THEME" -p "Saved Networks" -format i)

    [[ -z "$selected_line" || "$selected_line" -eq 0 ]] && { main_menu; return; }

    local name="${names[$((selected_line - 1))]}"
    [[ -z "$name" ]] && { main_menu; return; }

    nmcli connection up "$name" &>/dev/null
    main_menu
}

toggle_wifi() {
    if wifi_on; then
        nmcli radio wifi off &>/dev/null
    else
        nmcli radio wifi on &>/dev/null
    fi
    main_menu
}

main_menu() {
    local toggle_label="Turn On"
    wifi_on && toggle_label="Turn Off"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󱛇  Scan Networks" \
        "󱚾  Saved Networks" \
        "󰖪  ${toggle_label}" \
        | rofi -dmenu -theme "$THEME" -p "WiFi")

    case "$choice" in
        *"Back")           exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Scan Networks")  scan_networks ;;
        *"Saved Networks") saved_connections ;;
        *"On"|*"Off")      toggle_wifi ;;
    esac
}

main_menu
