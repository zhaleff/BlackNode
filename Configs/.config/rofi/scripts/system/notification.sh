#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
LIMIT=15

for bin in dunstctl jq; do
    command -v "$bin" >/dev/null 2>&1 || { notify-send "Notifications" "Missing: $bin"; exit 1; }
done

dnd_label() {
    if [[ "$(dunstctl is-paused)" == "true" ]]; then
        echo "󰂛  Do Not Disturb: On"
    else
        echo "󰂚  Do Not Disturb: Off"
    fi
}

show_history() {
    local json selected
    local -a ids
    json=$(dunstctl history | jq -c --argjson n "$LIMIT" '.data[0][:$n]')

    if [[ -z "$json" || "$json" == "[]" ]]; then
        notify-send "Notifications" "History is empty"
        main_menu
        return
    fi

    mapfile -t ids < <(jq -r '.[].id.data' <<< "$json")

    selected=$({
        echo "󰌍  Back"
        jq -r '.[] | (if .urgency.data == "CRITICAL" then "󰀦" else "󰂚" end)
            + "  " + (.appname.data // "?")
            + " · " + ((.summary.data // "") | gsub("\n"; " ") | .[0:45])' <<< "$json"
    } | rofi -dmenu -theme "$THEME" -p "History" -l 10 -format i)

    if [[ -z "$selected" || "$selected" -eq 0 ]]; then
        main_menu
        return
    fi

    dunstctl history-pop "${ids[$((selected - 1))]}"
}

main_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰂚  History" \
        "$(dnd_label)" \
        "󰎟  Dismiss All" \
        "󰆴  Clear History" \
        | rofi -dmenu -theme "$THEME" -p "Notifications")

    case "$choice" in
        *"Back")          exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"History")       show_history ;;
        *"Do Not Disturb"*) dunstctl set-paused toggle; main_menu ;;
        *"Dismiss All")   dunstctl close-all ;;
        *"Clear History") dunstctl history-clear; notify-send "Notifications" "History cleared" ;;
    esac
}

main_menu
