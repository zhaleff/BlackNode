#!/usr/bin/env bash

notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Set Wallpaper"
        "Random"
        "Matugen Generate"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Wallpapers" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Set Wallpaper") set_wall ;;
        "Random") random_wall ;;
        "Matugen Generate") matugen_gen ;;
    esac
}

set_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | rofi -dmenu -i -p "Wallpaper" -theme "$ROFI_SUB_THEME")
    if [[ -n "$wall" ]]; then
        swww img "$wall" --transition-fps 60 --transition-type wipe
        matugen image "$wall"
        notify "Wallpaper" "$(basename "$wall")"
    fi
}

random_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | shuf -n 1)
    if [[ -n "$wall" ]]; then
        swww img "$wall" --transition-fps 60 --transition-type wipe
        matugen image "$wall"
        notify "Wallpaper" "Random: $(basename "$wall")"
    fi
}

matugen_gen() {
    local wall
    wall=$(swww query | head -1 | grep -oP 'image: \K.*' || echo "")
    if [[ -n "$wall" ]]; then
        matugen image "$wall"
        notify "Matugen" "Colors regenerated"
    else
        notify "Matugen" "No wallpaper found"
    fi
}

main
