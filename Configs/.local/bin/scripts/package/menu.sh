#!/usr/bin/env bash

notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Install"
        "Remove"
        "Search"
        "Update"
        "Upgrade"
        "Info"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Packages" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Install") pkg_install ;;
        "Remove") pkg_remove ;;
        "Search") pkg_search ;;
        "Update") pkg_update ;;
        "Upgrade") pkg_upgrade ;;
        "Info") pkg_info ;;
    esac
}

pkg_install() {
    local pkg
    pkg=$(rofi -dmenu -i -p "Install" -theme "$ROFI_SUB_THEME")
    [[ -n "$pkg" ]] && alacritty -e sudo pacman -S "$pkg"
}

pkg_remove() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Remove" -theme "$ROFI_SUB_THEME")
    [[ -n "$pkg" ]] && alacritty -e sudo pacman -Rns "$pkg"
}

pkg_search() {
    local pkg
    pkg=$(rofi -dmenu -i -p "Search" -theme "$ROFI_SUB_THEME")
    [[ -n "$pkg" ]] && pacman -Ss "$pkg" | rofi -dmenu -i -p "Results" -theme "$ROFI_SUB_THEME"
}

pkg_update() {
    sudo pacman -Sy && notify "Package" "Database updated"
}

pkg_upgrade() {
    sudo pacman -Syu && notify "Package" "System upgraded"
}

pkg_info() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Info" -theme "$ROFI_SUB_THEME")
    [[ -n "$pkg" ]] && pacman -Qi "$pkg" | rofi -dmenu -i -p "$pkg" -theme "$ROFI_SUB_THEME"
}

main