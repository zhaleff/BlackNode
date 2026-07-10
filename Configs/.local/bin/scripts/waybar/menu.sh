#!/usr/bin/env bash
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
CONF="$HOME/.config"

main() {
    local options=(
        "Reload"
        "Edit Style"
        "Edit Config"
        "Layout"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Waybar" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Reload") reload ;;
        "Edit Style") edit "$CONF/waybar/style.css" ;;
        "Edit Config") edit "$CONF/waybar/config.jsonc" ;;
        "Layout") change_layout ;;
    esac
}

reload() {
    pkill -x waybar
    sleep 0.3
    waybar &
    notify-send "Waybar" "Reloaded"
}

change_layout() {
    local layouts
    layouts=$(ls "$CONF/waybar/Layouts/"*.jsonc 2>/dev/null | xargs -n1 basename | sort)
    local sel
    sel=$(printf '%s\n' "$layouts" | rofi -dmenu -i -p "Layout" -theme "$ROFI_SUB_THEME")
    if [[ -n "$sel" ]]; then
        cp "$CONF/waybar/Layouts/$sel" "$CONF/waybar/config.jsonc"
        pkill -x waybar
        waybar &
        notify-send "Waybar" "$sel"
    fi
}

edit() {
    [[ -f "$1" ]] && alacritty -e nvim "$1"
}

main