#!/usr/bin/env bash

# ============================================
# BLACKNODE APPS
# ============================================

ROFI_THEME="$HOME/.config/rofi/menu.rasi"

main() {
    local options=(
        "Terminals"
        "Files"
        "Browsers"
        "Editors"
        "Media"
        "Social"
        "Development"
        "System"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Apps" -theme "$ROFI_THEME")

    case "$choice" in
        "Terminals") terminals ;;
        "Files") files ;;
        "Browsers") browsers ;;
        "Editors") editors ;;
        "Media") media ;;
        "Social") social ;;
        "Development") development ;;
        "System") system ;;
    esac
}

# --------------------------------------------
terminals() {
    local opts=("Alacritty" "Kitty" "Ghostty")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Terminals" -theme "$ROFI_THEME")
    case "$choice" in
        "Alacritty") alacritty & ;;
        "Kitty") kitty & ;;
        "Ghostty") ghostty & ;;
    esac
}

files() {
    local opts=("Thunar" "Yazi" "Nautilus")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Files" -theme "$ROFI_THEME")
    case "$choice" in
        "Thunar") thunar & ;;
        "Yazi") alacritty -e yazi & ;;
        "Nautilus") nautilus & ;;
    esac
}

browsers() {
    local opts=("Firefox" "Brave" "LibreWolf")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Browsers" -theme "$ROFI_THEME")
    case "$choice" in
        "Firefox") firefox & ;;
        "Brave") brave & ;;
        "LibreWolf") librewolf & ;;
    esac
}

editors() {
    local opts=("Nvim" "Vscode" "Zed" "Helix")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Editors" -theme "$ROFI_THEME")
    case "$choice" in
        "Nvim") alacritty -e nvim & ;;
        "Vscode") code & ;;
        "Zed") zed & ;;
        "Helix") alacritty -e hx & ;;
    esac
}

media() {
    local opts=("Spotify" "OBS" "Vlc")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Media" -theme "$ROFI_THEME")
    case "$choice" in
        "Spotify") spotify & ;;
        "OBS") obs & ;;
        "Vlc") vlc & ;;
    esac
}

social() {
    local opts=("Discord" "Telegram" "Signal")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Social" -theme "$ROFI_THEME")
    case "$choice" in
        "Discord") discord & ;;
        "Telegram") telegram-desktop & ;;
        "Signal") signal & ;;
    esac
}

development() {
    local opts=("Github" "Docker" "Postman")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "Dev" -theme "$ROFI_THEME")
    case "$choice" in
        "Github") alacritty -e gh auth login & ;;
        "Docker") alacritty -e docker ps & ;;
        "Postman") postman & ;;
    esac
}

system() {
    local opts=("HTop" "Nwg-look" "Pavucontrol")
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "System" -theme "$ROFI_THEME")
    case "$choice" in
        "HTop") alacritty -e htop & ;;
        "Nwg-look") nwg-look & ;;
        "Pavucontrol") pavucontrol & ;;
    esac
}

main