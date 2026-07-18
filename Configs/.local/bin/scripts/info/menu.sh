#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
CONF="$HOME/.config"

notify() { notify-send "$1" "$2"; }
edit() { [[ -f "$1" ]] && kitty -e nvim "$1" || notify "Config" "Not found"; }

main() {
    local pkgs=$(pacman -Qq 2>/dev/null | wc -l)
    local flatpak=$(flatpak list 2>/dev/null | wc -l)
    local uptime=$(uptime -p | sed 's/up //')
    local kernel=$(uname -r)

    local choice
    choice=$(printf '%s\n' \
        "󰋼  About BlackNode" \
        "󰣇  Project Stats" \
        "󰌌  Theme System" \
        "  Keybinds" \
        "󰄉  Waybar Modules" \
        "󱛡  View README" \
        "󰈙  Browse Dotfiles" \
        "󰏗  Package List" \
        "󰊤  Repository" \
        | rofi -dmenu -i -p "About" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "󰋼  About BlackNode")  show_about "$pkgs" "$flatpak" "$uptime" "$kernel" ;;
        "󰣇  Project Stats")    show_stats "$pkgs" "$flatpak" "$uptime" "$kernel" ;;
        "󰌌  Theme System")     show_theme ;;
        "  Keybinds")        show_keybinds ;;
        "󰄉  Waybar Modules")   show_modules ;;
        "󱛡  View README")     kitty -e nvim "$HOME/BlackNode/README.md" & ;;
        "󰈙  Browse Dotfiles")  kitty -e yazi "$HOME/BlackNode" & ;;
        "󰏗  Package List")    show_packages ;;
        "󰊤  Repository")      show_repo ;;
    esac
}

show_about() {
    local pkgs=$1 flatpak=$2 uptime=$3 kernel=$4
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local choice
    choice=$(printf '%s\n' \
        "  BlackNode — Modular Dotfiles" \
        "󰚥  Author: zhaleff" \
        "󰣇  System: Arch Linux · $kernel" \
        "  WM: Hyprland · Lua Config" \
        "󰌌  Theme: Material You · Matugen" \
        "󰏗  Packages: $pkgs pacman · $flatpak flatpak" \
        "󰅐  Uptime: $uptime" \
        "󰈙  Config: $HOME/BlackNode" \
        "󰋼  A modular, human-readable dotfile" \
        "󰋼  collection with automatic color" \
        "󰋼  generation from wallpaper via Matugen." \
        | rofi -dmenu -i -p "BlackNode" -theme "$ROFI_SUB_THEME")
    case "$choice" in
        "󰈙  Config: $HOME/BlackNode")
            kitty -e yazi "$HOME/BlackNode" & ;;
    esac
}

show_stats() {
    local pkgs=$1 flatpak=$2 uptime=$3 kernel=$4
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local cpu=$(lscpu | awk '/Model name/ {sub(/.*: */, ""); print; exit}')
    local disks=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
    local procs=$(ps aux | wc -l)
    local config_files=$(find "$HOME/BlackNode" -type f | wc -l)
    local choice
    choice=$(printf '%s\n' \
        "  Project Stats" \
        "󰏗  Packages: $pkgs pacman · $flatpak flatpak" \
        "  CPU: $cpu" \
        "󰍛  Memory: $mem" \
        "󱦟  Disk: $disks" \
        "󱖫  Processes: $procs" \
        "󰅐  Uptime: $uptime" \
        "󰈙  Config files: $config_files" \
        "󰣇  Kernel: $kernel" \
        | rofi -dmenu -i -p "Stats" -theme "$ROFI_SUB_THEME")
}

show_theme() {
    local choice
    choice=$(printf '%s\n' \
        "󰌌  Theme System — Material You" \
        "󰋼  Colors from wallpaper via Matugen" \
        "󰌌  Primary      Secondary" \
        "󰌌  Tertiary     Error" \
        "󰌌  Surface      Outline" \
        "󰄉  waybar/colors.css" \
        "󰋼  rofi/colors.rasi" \
        "󰋼  wlogout/colors.css" \
        "󰋼  hypr/themes/colors.lua" \
        "󰋼  kitty/colors.conf" \
        "󰋼  dunst/dunstrc" \
        "󰋼  cava/config" \
        "󰋼  nvim/core/wallust_colors.lua" \
        "󰋼  Change wallpaper → colors update" \
        | rofi -dmenu -i -p "Theme" -theme "$ROFI_SUB_THEME")
}

show_keybinds() {
    local choice
    choice=$(printf '%s\n' \
        "  Hyprland Keybinds" \
        "󰋼  SUPER + SPACE    → bn-menu" \
        "󰋼  SUPER + ENTER    → Terminal (kitty)" \
        "󰋼  SUPER + Q        → Kill active" \
        "󰋼  SUPER + 1-9      → Switch workspace" \
        "󰋼  SUPER + S        → Screenshot area" \
        "󰋼  SUPER + V        → Toggle float" \
        "󰋼  SUPER + F        → Fullscreen" \
        "󰋼  SUPER + L        → Lock (hyprlock)" \
        "󰋼  SUPER + E        → File manager" \
        "󰋼  SUPER + R        → Rofi launcher" \
        "󰋼  SUPER + T        → Toggle split" \
        "󰋼  SUPER + M        → Exit Hyprland" \
        "󰋼  Open KEYBINDS.md for full list" \
        | rofi -dmenu -i -p "Keybinds" -theme "$ROFI_SUB_THEME")
    case "$choice" in
        "󰋼  Open KEYBINDS.md for full list")
            kitty -e nvim "$HOME/BlackNode/KEYBINDS.md" & ;;
    esac
}

show_modules() {
    local choice
    choice=$(printf '%s\n' \
        "󰄉  Waybar — 5 Layouts" \
        "󰋼  blacknode: default layout" \
        "󰋼  minimal: clean, compact" \
        "󰋼  full: everything on screen" \
        "󰋼  dev: dev mode layout" \
        "󰋼  compact: tiny bar" \
        "󰋼  Left:    Workspaces, Window" \
        "󰋼  Center:  Clock, Media Player" \
        "󰋼  Right:   Network, Volume, Battery" \
        "󰋼  Right:   Bluetooth, Tray, CPU, RAM" \
        "󰋼  All styled with M3 dynamic colors" \
        "󰄉  Open waybar config folder" \
        | rofi -dmenu -i -p "Waybar" -theme "$ROFI_SUB_THEME")
    case "$choice" in
        "󰄉  Open waybar config folder")
            kitty -e yazi "$HOME/.config/waybar" & ;;
    esac
}

show_repo() {
    local choice
    choice=$(printf '%s\n' \
        "  zhaleff/BlackNode" \
        "  Branch: master" \
        "󰒋  License: MIT" \
        "󰈙  Config files: $(find "$HOME/BlackNode" -type f | wc -l)" \
        "󰛥  Lines of config: $(find "$HOME/BlackNode" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')" \
        "󰣇  System: Arch Linux + Hyprland" \
        "󰚥  Author: zhaleff" \
        "󱂅  Community: Discord" \
        | rofi -dmenu -i -p "Repository" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "  zhaleff/BlackNode")
            xdg-open "https://github.com/zhaleff/BlackNode" & ;;
    esac
}

show_packages() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Packages" -theme "$ROFI_SUB_THEME")
    if [[ -n "$pkg" ]]; then
        pacman -Qi "$pkg" | rofi -dmenu -i -p "$pkg" -theme "$ROFI_SUB_THEME"
    fi
}

main
