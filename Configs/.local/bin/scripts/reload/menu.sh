#!/usr/bin/env bash
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Hyprland"
        "Waybar"
        "Dunst"
        "Restart All"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Reload" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Hyprland") reload_hypr ;;
        "Waybar") reload_waybar ;;
        "Dunst") reload_dunst ;;
        "Restart All") restart_all ;;
    esac
}

reload_hypr() {
    hyprctl reload
    notify-send "Hyprland" "Reloaded"
}

reload_waybar() {
    pkill -x waybar
    sleep 0.3
    waybar &
    notify-send "Waybar" "Reloaded"
}

reload_dunst() {
    pkill -x dunst
    sleep 0.3
    dunst &
    notify-send "Dunst" "Reloaded"
}

restart_all() {
    hyprctl reload
    pkill -x waybar dunst
    waybar &
    dunst &
    notify-send "Compositor" "Restarted"
}

main