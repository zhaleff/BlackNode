#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
CONF="$HOME/.config"

main() {
    local themes
    themes=$(ls "$CONF/hypr/animations/"*.conf 2>/dev/null | xargs -n1 basename | sed 's/BlackNode-//; s/\.conf//' | sort)
    local choice
    choice=$(printf '%s\n' "$themes" | rofi -dmenu -i -p "Theme" -theme "$ROFI_SUB_THEME")
    [[ -n "$choice" ]] && sed -i "s/source = .*/source = animations\/BlackNode-$choice.conf/" "$CONF/hypr/animations.conf" && hyprctl reload && notify-send "Theme" "$choice"
}

main