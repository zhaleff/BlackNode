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

apply_wall() {
    local wall="$1"
    if ! pgrep -x "awww" > /dev/null; then
        awww &
        sleep 0.2
    fi
    awww img "$wall" --transition-type=random
    cp "$wall" ~/.config/hypr/hyprlock.png
    matugen image "$wall" -m dark --source-color-index 0
    killall -SIGUSR2 waybar && killall dunst && dunst &
    pkill -USR1 cava
    killall -SIGUSR1 kitty && pkill -USR1 firefox 2>/dev/null || killall -USR1 firefox 2>/dev/null
    notify "Wallpaper" "$(basename "$wall")"
}

set_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | rofi -dmenu -i -p "Wallpaper" -theme "$ROFI_SUB_THEME")
    [[ -n "$wall" ]] && apply_wall "$wall"
}

random_wall() {
    local dir="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
    [[ -d "$dir" ]] || dir="$HOME/Pictures"
    local wall
    wall=$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | shuf -n 1)
    [[ -n "$wall" ]] && apply_wall "$wall"
}

main
