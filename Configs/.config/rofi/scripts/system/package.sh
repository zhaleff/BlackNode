#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
TERM="kitty"

packages_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰦒  Full Upgrade" \
        "󰏗  Install Package" \
        "󰍷  Remove Package" \
        " cleans  Clean Cache" \
        | rofi -dmenu -theme "$THEME" -p "Packages")

    case "$choice" in
        *"Back")          exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Full Upgrade")  $TERM -e bash -c "yay -Syu; read -p 'Press Enter to close'" ;;
        *"Install Package") install_menu ;;
        *"Remove Package")  remove_menu ;;
        *"Clean Cache")     $TERM -e bash -c "yay -Yc; read -p 'Press Enter to close'" ;;
    esac
}

install_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰏗  Pacman" \
        "󰏗  Yay (AUR)" \
        | rofi -dmenu -theme "$THEME" -p "Install from")

    case "$choice" in
        *"Back")       exec bash "$0" ;;
        *"Pacman")
            pkg=$(rofi -dmenu -theme "$THEME" -p "Package name")
            [[ -n "$pkg" ]] && $TERM -e bash -c "sudo pacman -S $pkg; read -p 'Press Enter to close'"
            ;;
        *"Yay")
            pkg=$(rofi -dmenu -theme "$THEME" -p "Package name")
            [[ -n "$pkg" ]] && $TERM -e bash -c "yay -S $pkg; read -p 'Press Enter to close'"
            ;;
    esac
}

remove_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰍷  Pacman" \
        "󰍷  Yay (AUR)" \
        | rofi -dmenu -theme "$THEME" -p "Remove from")

    case "$choice" in
        *"Back")       exec bash "$0" ;;
        *"Pacman")
            pkg=$(pacman -Qq | rofi -dmenu -theme "$THEME" -p "Remove package")
            [[ -n "$pkg" ]] && $TERM -e bash -c "sudo pacman -Rns $pkg; read -p 'Press Enter to close'"
            ;;
        *"Yay")
            pkg=$(yay -Qm | rofi -dmenu -theme "$THEME" -p "Remove package")
            [[ -n "$pkg" ]] && $TERM -e bash -c "yay -Rns $pkg; read -p 'Press Enter to close'"
            ;;
    esac
}

packages_menu
