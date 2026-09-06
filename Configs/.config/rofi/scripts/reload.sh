#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

reload_waybar() {
    pkill -x waybar
    sleep 0.3
    waybar >/tmp/waybar.log 2>&1 &
    disown
}

reload_hyprland() {
    hyprctl reload
}

reload_dunst() {
    pkill -x dunst
    sleep 0.3
    dunst &
    disown
}

reload_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  Reload bar (Waybar)" \
        "  Reload window manager (Hyprland)" \
        "  Reload notifications (Dunst)" \
        "  Reload everything" \
        | rofi -dmenu -theme "$THEME" -p "Reload")

    case "$choice" in
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Reload bar"*)
            reload_waybar
            notify-send "Reload" "Bar reloaded" ;;
        *"window manager"*)
            reload_hyprland
            notify-send "Reload" "Window manager reloaded" ;;
        *"notifications"*)
            reload_dunst
            notify-send "Reload" "Notifications reloaded" ;;
        *"everything")
            reload_hyprland
            reload_waybar
            reload_dunst
            notify-send "Reload" "Everything reloaded" ;;
    esac
}

reload_menu
