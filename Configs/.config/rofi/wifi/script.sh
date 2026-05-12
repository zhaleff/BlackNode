#!/bin/bash

# Configuration of rofi themes
ROFI_PATH="$HOME/.config/rofi/wifi"
ENABLE_THEME="$ROFI_PATH/enable.rasi"
LIST_THEME="$ROFI_PATH/list.rasi"
PASSWORD_THEME="$ROFI_PATH/password.rasi"
SSID_THEME="$ROFI_PATH/ssid.rasi"

# Function to check if NetworkManager is running
check_nm() {
    if ! systemctl is-active --quiet NetworkManager; then
        notify-send "Error" "NetworkManager is not running."
        exit 1
    fi
}

# Function to display the main menu
main_menu() {
    local wifi_status=$(nmcli radio wifi)
    local options=("Scan Networks" "Saved Connections" "WiFi Status: $wifi_status" "Exit")
    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "WiFi Menu" -theme "$ENABLE_THEME")
    
    case "$choice" in
        "Scan Networks")
            scan_networks
            ;;
        "Saved Connections")
            saved_connections
            ;;
        "WiFi Status: enabled")
            nmcli radio wifi off
            notify-send "WiFi" "WiFi disabled"
            main_menu
            ;;
        "WiFi Status: disabled")
            nmcli radio wifi on
            notify-send "WiFi" "WiFi enabled"
            main_menu
            ;;
        "Exit")
            exit 0
            ;;
    esac
}

# Function to scan available WiFi networks
scan_networks() {
    # Force network scan
    nmcli device wifi rescan 2>/dev/null
    sleep 2 # Wait for scan to complete
    
    # Get list of networks (SSID and signal strength)
    local networks
    networks=$(nmcli -f SSID,SIGNAL -t -m tabular device wifi list | sort -u)
    
    # Check if networks were found
    if [ -z "$networks" ]; then
        notify-send "WiFi" "No networks found."
        main_menu
        return
    fi
    
    # Display networks in rofi
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

# Function to display saved connections
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

# Function to connect to a network
connect_to_network() {
    local ssid="$1"
    
    # Check if the network is already saved
    if nmcli connection show | grep -q "$ssid"; then
        nmcli connection up "$ssid" && notify-send "WiFi" "Connected to $ssid" || notify-send "WiFi" "Failed to connect to $ssid"
        main_menu
        return
    fi
    
    # Prompt for password if needed
    local password
    password=$(rofi -dmenu -p "Password for $ssid" -password -theme "$PASSWORD_THEME")
    
    if [ -n "$password" ]; then
        nmcli device wifi connect "$ssid" password "$password" && notify-send "WiFi" "Connected to $ssid" || notify-send "WiFi" "Failed to connect to $ssid"
    fi
    main_menu
}

# Function to manually add a new SSID
add_new_ssid() {
    local ssid
    ssid=$(rofi -dmenu -p "Enter SSID" -theme "$SSID_THEME")
    
    if [ -n "$ssid" ]; then
        connect_to_network "$ssid"
    else
        main_menu
    fi
}

# Main execution
check_nm
main_menu
