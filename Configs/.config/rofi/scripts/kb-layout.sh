#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

DEVICE=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name')

layout_menu() {
    local current
    current=$(hyprctl devices -j | jq -r --arg dev "$DEVICE" '.keyboards[] | select(.name == $dev) | .active_keymap')

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  English" \
        "  Español" \
        | rofi -dmenu -theme "$THEME" -p "Layout ($current)")

    case "$choice" in
        *"Back")     exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"English")  hyprctl switchxkblayout "$DEVICE" 0 ;;
        *"Español")  hyprctl switchxkblayout "$DEVICE" 1 ;;
    esac
}

layout_menu
