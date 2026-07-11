#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
LIST_THEME="$R/styles/wifi-list.rasi"
PASSWORD_THEME="$R/styles/wifi-password.rasi"
SSID_THEME="$R/styles/wifi-ssid.rasi"

check_nm() {
    if ! systemctl is-active --quiet NetworkManager; then
        notify-send "Error" "NetworkManager is not running."
        exit 1
    fi
}

main_menu() {
    local wifi_status=$(nmcli radio wifi)
    if [[ "$wifi_status" == "enabled" ]]; then
        local options=" \n \n󰤪 \n "
    else
        local options=" \n \n󰤨 \n "
    fi
    local choice
    choice=$(printf '%b' "$options" | rofi -dmenu -p "󰤨" -theme-str "listview { lines: 4; }" -theme "$MENU_THEME")
    case "$choice" in
        " ") scan_networks ;;
        " ") saved_connections ;;
        "󰤪 ") nmcli radio wifi off && notify-send "WiFi" "WiFi disabled" && main_menu ;;
        "󰤨 ") nmcli radio wifi on && notify-send "WiFi" "WiFi enabled" && main_menu ;;
        " ") exit 0 ;;
    esac
}

scan_networks() {
    nmcli device wifi rescan 2>/dev/null
    sleep 2
    local networks
    networks=$(nmcli -f SSID,SIGNAL -t -m tabular device wifi list | sort -u)
    if [ -z "$networks" ]; then
        notify-send "WiFi" "No networks found."
        main_menu
        return
    fi
    local selected
    selected=$(echo "$networks" | rofi -dmenu -p "Select Network" -theme "$LIST_THEME")
    if [ -n "$selected" ]; then
        local ssid
        ssid=$(echo "$selected" | cut -d':' -f1)
        connect_to_network "$ssid"
    else
        main_menu
    fi
}

saved_connections() {
    local connections
    connections=$(nmcli -f NAME -t -m tabular connection show | sort -u)
    if [ -z "$connections" ]; then
        notify-send "WiFi" "No saved connections found."
        main_menu
        return
    fi
    local selected
    selected=$(echo "$connections" | rofi -dmenu -p "Saved" -theme "$LIST_THEME")
    if [ -n "$selected" ]; then
        nmcli connection up "$selected" && notify-send "WiFi" "Connected to $selected" || notify-send "WiFi" "Failed"
    fi
    main_menu
}

connect_to_network() {
    local ssid="$1"
    if nmcli connection show | grep -q "$ssid"; then
        nmcli connection up "$ssid" && notify-send "WiFi" "Connected" || notify-send "WiFi" "Failed"
        main_menu
        return
    fi
    local password
    password=$(rofi -dmenu -p "Password" -password -theme "$PASSWORD_THEME")
    if [ -n "$password" ]; then
        nmcli device wifi connect "$ssid" password "$password" && notify-send "WiFi" "Connected" || notify-send "WiFi" "Failed"
    fi
    main_menu
}

check_nm
main_menu
