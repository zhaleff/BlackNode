#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
CONF="$HOME/.config"

notify() { notify-send "$1" "$2"; }

main() {
    local choice
    choice=$(printf '%s\n' \
        "  Applications" \
        "󰈙  Config Files" \
        | rofi -dmenu -i -p "Apps" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "  Applications") apps_menu ;;
        "󰈙  Config Files") config_menu ;;
    esac
}
apps_menu() {
    local choice
    choice=$(printf '%s\n' \
        "  Terminals" \
        "󰉋  File Managers" \
        "󰈹  Browsers" \
        "󰏈  Text Editors" \
        "  Media" \
        "󰭻  Social" \
        "󰚥  Development" \
        "󰓅  System Tools" \
        | rofi -dmenu -i -p "Launch" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "  Terminals")     pick "Kitty" "Alacritty" "Ghostty" term_launch ;;
        "󰉋  File Managers") pick "Thunar" "Yazi" "Nautilus" file_launch ;;
        "󰈹  Browsers")      pick "Firefox" "Brave" "LibreWolf" browser_launch ;;
        "󰏈  Text Editors")  pick "Nvim" "Vscode" "Zed" "Helix" editor_launch ;;
        "  Media")         pick "Spotify" "OBS" "Vlc" media_launch ;;
        "󰭻  Social")        pick "Discord" "Telegram" "Signal" social_launch ;;
        "󰚥  Development")  pick "Github" "Docker" "Postman" dev_launch ;;
        "󰓅  System Tools")  pick "HTop" "Nwg-look" "Pavucontrol" sys_launch ;;
    esac
}

pick() {
    local opts=("$@")
    local label="${opts[-1]}"
    unset 'opts[${#opts[@]}-1]'
    local choice
    choice=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -i -p "$label" -theme "$ROFI_SUB_THEME")
    [[ -n "$choice" ]] && launch "$choice"
}

launch() {
    case "$1" in
        "Kitty") kitty & ;;
        "Alacritty") alacritty & ;;
        "Ghostty") ghostty & ;;
        "Thunar") thunar & ;;
        "Yazi") kitty -e yazi & ;;
        "Nautilus") nautilus & ;;
        "Firefox") firefox & ;;
        "Brave") brave & ;;
        "LibreWolf") librewolf & ;;
        "Nvim") kitty -e nvim & ;;
        "Vscode") code & ;;
        "Zed") zed & ;;
        "Helix") kitty -e hx & ;;
        "Spotify") spotify & ;;
        "OBS") obs & ;;
        "Vlc") vlc & ;;
        "Discord") discord & ;;
        "Telegram") telegram-desktop & ;;
        "Signal") signal-desktop & ;;
        "Github") firefox "https://github.com" & ;;
        "Docker") kitty -e docker ps & ;;
        "Postman") postman & ;;
        "HTop") kitty -e htop & ;;
        "Nwg-look") nwg-look & ;;
        "Pavucontrol") pavucontrol & ;;
    esac
}
config_menu() {
    local choice
    choice=$(printf '%s\n' \
        "  Hyprland — Window Manager" \
        "󰄉  Waybar — Status Bar" \
        "󰀻  Rofi — App Launcher" \
        "󰄛  Kitty — Terminal" \
        "󰂛  Dunst — Notifications" \
        "󰣇  Fastfetch — System Info" \
        "  Neovim — Text Editor" \
        "󰍃  Wlogout — Logout Screen" \
        "󰸉  Wallpapers — Images" \
        | rofi -dmenu -i -p "Config" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "  Hyprland — Window Manager")   edit "$CONF/hypr/hyprland.lua" ;;
        "󰄉  Waybar — Status Bar")         pick_config "Waybar" "$CONF/waybar/style.css" "$CONF/waybar/config.jsonc" "$CONF/waybar/colors.css" ;;
        "󰀻  Rofi — App Launcher")         pick_config "Rofi" "$CONF/rofi/menu.rasi" "$CONF/rofi/submenu.rasi" "$CONF/rofi/colors.rasi" ;;
        "󰄛  Kitty — Terminal")            edit "$CONF/kitty/kitty.conf" ;;
        "󰂛  Dunst — Notifications")       edit "$CONF/dunst/dunstrc" ;;
        "󰣇  Fastfetch — System Info")     edit "$CONF/fastfetch/config.jsonc" ;;
        "  Neovim — Text Editor")        pick_config "Neovim" "$CONF/nvim/init.lua" "$CONF/nvim/lazyvim.json" ;;
        "󰍃  Wlogout — Logout Screen")     pick_config "Wlogout" "$CONF/wlogout/style.css" "$CONF/wlogout/layout" ;;
        "󰸉  Wallpapers — Images")         kitty -e yazi "$HOME/Pictures/Wallpapers" & ;;
    esac
}

pick_config() {
    local label="$1"
    shift
    local files=("$@")
    if [[ ${#files[@]} -eq 1 ]]; then
        edit "${files[0]}"
        return
    fi
    local choice
    choice=$(printf '%s\n' "${files[@]}" | sed 's|.*/||' | rofi -dmenu -i -p "$label" -theme "$ROFI_SUB_THEME")
    for f in "${files[@]}"; do
        [[ "$(basename "$f")" == "$choice" ]] && edit "$f" && return
    done
}

edit() {
    [[ -f "$1" ]] && kitty -e nvim "$1" || notify "Config" "File not found: $1"
}

main
