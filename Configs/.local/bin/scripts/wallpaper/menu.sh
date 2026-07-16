#!/usr/bin/env bash

notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Select Wallpaper"
        "Random Wallpaper"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Wallpapers" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Select Wallpaper") set_wall ;;
        "Random Wallpaper") random_wall ;;
    esac
}

set_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | rofi -dmenu -i -p "Wallpaper" -theme "$ROFI_SUB_THEME")
    if [[ -n "$wall" ]]; then
        awww img "$wall" --transition-type=random
        matugen image "$wall"
        notify "Wallpaper" "$(basename "$wall")"
    fi
}

random_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | shuf -n 1)
    if [[ -n "$wall" ]]; then
        awww img "$wall" --transition-type=random
        matugen image "$wall"
        notify "Wallpaper" "Random: $(basename "$wall")"
    fi
}

main
