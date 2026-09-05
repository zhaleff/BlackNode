#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
PASS_THEME="$ROFI_DIR/themes/features/wifi-password.rasi"

if ! systemctl is-active --quiet NetworkManager; then
    notify-send "WiFi" "NetworkManager is not running."
    exit 1
fi

wifi_on() { [ "$(nmcli radio wifi 2>/dev/null)" = "enabled" ]; }

signal_icon() {
    local sig=$1 sec=$2
    if [ "$sec" = "open" ]; then
        if   [ "$sig" -ge 80 ]; then echo "󰤨"
        elif [ "$sig" -ge 60 ]; then echo "󰤥"
        elif [ "$sig" -ge 40 ]; then echo "󰤢"
        elif [ "$sig" -ge 20 ]; then echo "󰤡"
        else echo "󰤟"
        fi
    else
        if   [ "$sig" -ge 80 ]; then echo "󰤧"
        elif [ "$sig" -ge 60 ]; then echo "󰤤"
        elif [ "$sig" -ge 40 ]; then echo "󰤡"
        elif [ "$sig" -ge 20 ]; then echo "󰤟"
        else echo "󰤞"
        fi
    fi
}

connect_to_network() {
    local ssid="$1"
    if nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$ssid"; then
        nmcli connection up "$ssid" >/dev/null 2>&1 \
            && notify-send "WiFi" "Connected to $ssid" \
            || notify-send "WiFi" "Connection failed"
        return
    fi
    local password
    password=$(rofi -dmenu -theme "$PASS_THEME" -p "Password for $ssid" -password)
    [ -z "$password" ] && return
    nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1 \
        && notify-send "WiFi" "Connected to $ssid" \
        || notify-send "WiFi" "Connection failed"
}

scan_networks() {
    nmcli device wifi rescan >/dev/null 2>&1
    sleep 1
    local lines
    lines=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null \
        | awk -F: '$1 != "" {print $1 "|" $2 "|" $3}' | sort -u)
    if [ -z "$lines" ]; then
        notify-send "WiFi" "No networks found."
        main_menu
        return
    fi
    local input=""
    while IFS='|' read -r ssid signal security; do
        [ -z "$ssid" ] && continue
        local icon sec="locked"
        [[ -z "$security" || "$security" == "--" ]] && sec="open"
        icon=$(signal_icon "$signal" "$sec")
        input+="${icon}  ${ssid}"$'\n'
    done <<< "$lines"
    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Select Network")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local ssid="${selected#*  }"
    ssid="${ssid#* }"
    [ -z "$ssid" ] && main_menu && return
    connect_to_network "$ssid"
    main_menu
}

saved_connections() {
    local connections
    connections=$(nmcli -f NAME -t -m tabular connection show 2>/dev/null | sort -u)
    if [ -z "$connections" ]; then
        notify-send "WiFi" "No saved connections."
        main_menu
        return
    fi
    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$connections" | rofi -dmenu -theme "$THEME" -p "Saved Networks")
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    nmcli connection up "$selected" >/dev/null 2>&1 \
        && notify-send "WiFi" "Connected to $selected" \
        || notify-send "WiFi" "Failed"
    main_menu
}

toggle_wifi() {
    if wifi_on; then
        nmcli radio wifi off 2>/dev/null && notify-send "WiFi" "WiFi off"
    else
        nmcli radio wifi on 2>/dev/null && notify-send "WiFi" "WiFi on"
    fi
}

main_menu() {
    local toggle_label="Turn On"
    wifi_on && toggle_label="Turn Off"

    local choice
    choice=$(printf '%s\n' \
        "󰌍󰌍  Back" \
        "󱛇  Scan Networks" \
        "󱚾  Saved Networks" \
        "󰖪  $toggle_label" \
        | rofi -dmenu -theme "$THEME" -p "󰤨 WiFi")

    case "$choice" in
        *"Back")            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Scan Networks")   scan_networks ;;
        *"Saved Networks")  saved_connections ;;
        *"Turn Off"*)       toggle_wifi; main_menu ;;
        *"Turn On"*)        toggle_wifi; main_menu ;;
    esac
}

main_menu
