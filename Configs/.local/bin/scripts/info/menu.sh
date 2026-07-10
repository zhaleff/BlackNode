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
    esac
}

show_about() {
    local pkgs=$1 flatpak=$2 uptime=$3 kernel=$4
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local info
    info=$(cat <<EOF
  BlackNode
󰚥  by Zhaleff · HollowSec
󰣇  Arch Linux · $kernel
  Hyprland · Lua Config
󰌌  Material You — Matugen
󰄉  Waybar · Rofi · Kitty
󰏗  $pkgs pacman · $flatpak flatpak
󰅐  $uptime ·   All services running

A modular, human-readable dotfile
collection. Material You theming
with automatic color generation
from your wallpaper via Matugen.
EOF
)
    rofi -dmenu -i -p "BlackNode" -theme "$ROFI_SUB_THEME" \
        -mesg "$info" -lines 14
}

show_stats() {
    local pkgs=$1 flatpak=$2 uptime=$3 kernel=$4
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local cpu=$(lscpu | awk '/Model name/ {sub(/.*: */, ""); print; exit}')
    local disks=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
    local procs=$(ps aux | wc -l)
    local config_files=$(find "$HOME/BlackNode" -type f | wc -l)

    local info
    info=$(cat <<EOF
  Project Stats

󰏗  Packages: $pkgs (pacman) · $flatpak (flatpak)
  CPU: $cpu
󰍛  Memory: $mem
󱦟  Disk: $disks
󱖫  Processes: $procs
󰅐  Uptime: $uptime
󰈙  Config files: $config_files
󰣇  Kernel: $kernel
EOF
)
    rofi -dmenu -i -p "Stats" -theme "$ROFI_SUB_THEME" \
        -mesg "$info" -lines 13
}

show_theme() {
    local info
    info=$(cat <<'EOF'
󰌌  Theme System — Material You

Colors are generated automatically
from your wallpaper using Matugen.

┌────────────────────────────────┐
│  ● Primary   ● Secondary       │
│  ● Tertiary  ● Error           │
│  ● Surface   ● Outline         │
└────────────────────────────────┘

Every component uses M3 tokens:
  waybar/colors.css
  rofi/colors.rasi
  wlogout/colors.css
  hypr/themes/colors.lua
  kitty/colors.conf
  dunst/dunstrc
  cava/config
  nvim/generated.lua

Change wallpaper → colors update.
EOF
)
    rofi -dmenu -i -p "Theme" -theme "$ROFI_SUB_THEME" \
        -mesg "$info" -lines 19
}

show_keybinds() {
    local binds
    binds=$(cat <<'EOF'
  Hyprland Keybinds (main)

SUPER + SPACE    → bn-menu
SUPER + ENTER    → Terminal (kitty)
SUPER + Q        → Kill active
SUPER + 1-9      → Switch workspace
SUPER + S        → Screenshot area
SUPER + V        → Toggle float
SUPER + F        → Fullscreen
SUPER + L        → Lock (hyprlock)
SUPER + E        → File manager
SUPER + R        → Rofi launcher
SUPER + T        → Toggle split
SUPER + M        → Exit Hyprland

Full list: KEYBINDS.md
EOF
)
    rofi -dmenu -i -p "Keybinds" -theme "$ROFI_SUB_THEME" \
        -mesg "$binds" -lines 17
}

show_modules() {
    local mods
    mods=$(cat <<'EOF'
󰄉  Waybar — 3 Styles

Classic:    workspace layout
Hacking:    compact, minimal
Modern:     floating modules

Modules:
  Left:   Workspaces, Window
  Center: Clock, Media Player
  Right:  Network, Volume, Battery,
          Bluetooth, Tray, CPU, RAM

All styled with M3 dynamic colors.
EOF
)
    rofi -dmenu -i -p "Waybar" -theme "$ROFI_SUB_THEME" \
        -mesg "$mods" -lines 16
}

show_packages() {
    local pkg
    pkg=$(pacman -Qq | rofi -dmenu -i -p "Packages" -theme "$ROFI_SUB_THEME")
    if [[ -n "$pkg" ]]; then
        pacman -Qi "$pkg" | rofi -dmenu -i -p "$pkg" -theme "$ROFI_SUB_THEME"
    fi
}

main
