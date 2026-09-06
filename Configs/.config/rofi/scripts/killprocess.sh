#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

list_windows() {
    hyprctl clients -j | jq -r '.[] | select(.pid != null) | "\(.title // .class)  →  \(.class)|\(.pid)"'
}

kill_by_pid() {
    local pid="$1"
    kill -TERM "$pid" 2>/dev/null
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid" 2>/dev/null
        notify-send "Kill process" "Process didn't respond, force killed"
    else
        notify-send "Kill process" "Process closed"
    fi
}

killprocess_menu() {
    local entries
    entries=$(list_windows)

    if [ -z "$entries" ]; then
        notify-send "Kill process" "No windows open"
        exec bash "$ROFI_DIR/scripts/launcher.sh"
    fi

    local labels
    labels=$(echo "$entries" | cut -d'|' -f1)

    local choice
    choice=$(printf '%s\n%s\n' "󰌍  Back" "$labels" | rofi -dmenu -theme "$THEME" -p "Kill process")

    case "$choice" in
        "" )
            exit 0 ;;
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *)
            local pid
            pid=$(echo "$entries" | grep -F "$choice" | cut -d'|' -f2)
            [ -n "$pid" ] && kill_by_pid "$pid"
            ;;
    esac
}

killprocess_menu
