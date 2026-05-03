#!/usr/bin/env bash

notify() { notify-send "$1" "$2"; }

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
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Packages")

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
    pkg=$(rofi -dmenu -i -p "Install")
    [[ -n "$pkg" ]] && alacritty -e sudo pacman -S "$pkg"
}

pkg_remove() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Remove")
    [[ -n "$pkg" ]] && alacritty -e sudo pacman -Rns "$pkg"
}

pkg_search() {
    local pkg
    pkg=$(rofi -dmenu -i -p "Search")
    [[ -n "$pkg" ]] && pacman -Ss "$pkg" | rofi -dmenu -i -p "Results"
}

pkg_update() {
    sudo pacman -Sy && notify "Package" "Database updated"
}

pkg_upgrade() {
    sudo pacman -Syu && notify "Package" "System upgraded"
}

pkg_info() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Info")
    [[ -n "$pkg" ]] && pacman -Qi "$pkg" | rofi -dmenu -i -p "$pkg"
}

main