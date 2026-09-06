#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
REPO_URL="https://github.com/zhaleff/BlackNode"

update_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  View latest changes" \
        | rofi -dmenu -theme "$THEME" -p "Update")

    case "$choice" in
        *"Back")   exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"View"*)  xdg-open "$REPO_URL" ;;
    esac
}

update_menu
