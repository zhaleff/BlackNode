#!/usr/bin/env bash
notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
SCR_DIR="$HOME/.local/share/screenshots"

main() {
    local options=(
        "Fullscreen"
        "Area"
        "Clipboard"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Screenshot" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Fullscreen") scrot_full ;;
        "Area") scrot_area ;;
        "Clipboard") scrot_clip ;;
    esac
}

scrot_full() {
    local file="$SCR_DIR/$(date +%Y-%m-%d_%H%M%S).png"
    grim -g "$(swww get)" "$file"
    notify "Screenshot" "$(basename "$file")"
}

scrot_area() {
    local file="$SCR_DIR/area_$(date +%Y-%m-%d_%H%M%S).png"
    grim -g "$(slurp)" "$file"
    notify "Screenshot" "$(basename "$file")"
}

scrot_clip() {
    grim -g "$(swww get)" - | wl-copy
    notify "Screenshot" "Clipboard"
}

main