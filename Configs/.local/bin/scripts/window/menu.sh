#!/usr/bin/env bash
notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Float"
        "Fullscreen"
        "Center"
        "Minimize"
        "Group"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Window" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Float") hyprctl dispatch togglefloating && notify "Window" "Float" ;;
        "Fullscreen") hyprctl dispatch fullscreen && notify "Window" "Fullscreen" ;;
        "Center") hyprctl dispatch center && notify "Window" "Centered" ;;
        "Minimize") hyprctl dispatch minimize && notify "Window" "Minimized" ;;
        "Group") hyprctl dispatch togglegroup && notify "Window" "Group" ;;
    esac
}

main