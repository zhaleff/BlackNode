#!/bin/bash

ROFI_PATH="$HOME/.config/rofi/styles"
ENABLE_THEME="$ROFI_PATH/wifi-enable.rasi"
LIST_THEME="$ROFI_PATH/wifi-list.rasi"
PASSWORD_THEME="$ROFI_PATH/wifi-password.rasi"
SSID_THEME="$ROFI_PATH/wifi-ssid.rasi"

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
    choice=$(printf '%b' "$options" | rofi -dmenu -p "󰤨" -theme "$ENABLE_THEME")

    case "$choice" in
        " ")
            scan_networks
            ;;
        " ")
            saved_connections
            ;;
        "󰤪 ")
            nmcli radio wifi off
            notify-send "WiFi" "WiFi disabled"
            main_menu
            ;;
        "󰤨 ")
            nmcli radio wifi on
            notify-send "WiFi" "WiFi enabled"
            main_menu
            ;;
        " ")
            exit 0
            ;;
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
    local selected_network
    selected_network=$(echo "$networks" | rofi -dmenu -p "Select Network" -theme "$LIST_THEME")
    if [ -n "$selected_network" ]; then
        local ssid
        ssid=$(echo "$selected_network" | cut -d':' -f1)
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
    local selected_connection
    selected_connection=$(echo "$connections" | rofi -dmenu -p "Saved Connections" -theme "$LIST_THEME")
    if [ -n "$selected_connection" ]; then
        nmcli connection up "$selected_connection" && notify-send "WiFi" "Connected to $selected_connection" || notify-send "WiFi" "Failed to connect to $selected_connection"
    fi
    main_menu
}

connect_to_network() {
    local ssid="$1"
    if nmcli connection show | grep -q "$ssid"; then
        nmcli connection up "$ssid" && notify-send "WiFi" "Connected to $ssid" || notify-send "WiFi" "Failed to connect to $ssid"
        main_menu
        return
    fi
    local password
    password=$(rofi -dmenu -p "Password for $ssid" -password -theme "$PASSWORD_THEME")
    if [ -n "$password" ]; then
        nmcli device wifi connect "$ssid" password "$password" && notify-send "WiFi" "Connected to $ssid" || notify-send "WiFi" "Failed to connect to $ssid"
    fi
    main_menu
}

add_new_ssid() {
    local ssid
    ssid=$(rofi -dmenu -p "Enter SSID" -theme "$SSID_THEME")
    if [ -n "$ssid" ]; then
        connect_to_network "$ssid"
    else
        main_menu
    fi
}

check_nm
main_menu
