#!/usr/bin/env bash

PROFILE_DIR="$HOME/.config/hypr/profiles"
ACTIVE_FILE="$PROFILE_DIR/.active"

get_active() {
    [[ -f "$ACTIVE_FILE" ]] && cat "$ACTIVE_FILE" || echo "default"
}

set_active() {
    echo "$1" > "$ACTIVE_FILE"
    notify-send "Profile" "Switched to: $1"
    hyprctl reload 2>/dev/null
}

ACTIVE=$(get_active)

CHOICE=$(printf '%s\n' \
    "  default" \
    "  gaming" \
    "  programming" \
    "󰏓  presentation" \
    "󱨇  Current: $ACTIVE" \
    | rofi -dmenu -p "Profile" -theme "$HOME/.config/rofi/submenu.rasi")

case "$CHOICE" in
    "  default")      set_active "default" ;;
    "  gaming")       set_active "gaming" ;;
    "  programming")  set_active "programming" ;;
    "󰏓  presentation") set_active "presentation" ;;
esac
