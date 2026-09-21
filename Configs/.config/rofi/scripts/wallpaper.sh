#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
WALL_DIR="$HOME/Pictures/Wallpapers"
THEME_FILE="$HOME/.local/share/blacknode/theme_mode"

wall_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰸉  Select Wallpaper" \
        "󰖨  Dark Mode" \
        "󰖙  Light Mode" \
        "󰉋  Open Directory" \
        | rofi -dmenu -theme "$THEME" -p "Wallpaper")

    case "$choice" in
        *"Back")             exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Select Wallpaper") exec bash "$ROFI_DIR/scripts/wallselect.sh" ;;
        *"Dark Mode")        mkdir -p "$(dirname "$THEME_FILE")"; printf '%s' "dark" > "$THEME_FILE" ;;
        *"Light Mode")       mkdir -p "$(dirname "$THEME_FILE")"; printf '%s' "light" > "$THEME_FILE" ;;
        *"Open Directory")   xdg-open "$WALL_DIR" ;;
    esac
}

wall_menu
