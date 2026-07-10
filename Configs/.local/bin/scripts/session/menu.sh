#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Lock Screen"
        "Logout"
        "Suspend"
        "Reboot"
        "Shutdown"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Session" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Lock Screen") hyprlock ;;
        "Logout") wlogout ;;
        "Suspend") systemctl suspend ;;
        "Reboot") systemctl reboot ;;
        "Shutdown") systemctl poweroff ;;
    esac
}

main