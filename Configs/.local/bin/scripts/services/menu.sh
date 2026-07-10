#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

notify() { notify-send "$1" "$2"; }

main() {
    local running
    running=$(systemctl list-units --type=service --state=running --no-legend | awk '{print $1}' | head -20)

    local choice
    choice=$(printf '%s\n' \
        "  Running Services" \
        "  Failed Services" \
        "󰑐  Restart Service" \
        "" \
        "$running" \
        | rofi -dmenu -i -p "Services" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "  Running Services")
            systemctl list-units --type=service --state=running --no-legend | \
                awk '{print $1}' | rofi -dmenu -i -p "Running" -theme "$ROFI_SUB_THEME" && \
                notify "Services" "Done" ;;
        "  Failed Services")
            local failed
            failed=$(systemctl list-units --type=service --state=failed --no-legend | awk '{print $1}')
            if [[ -n "$failed" ]]; then
                local sel
                sel=$(echo "$failed" | rofi -dmenu -i -p "Failed" -theme "$ROFI_SUB_THEME")
                [[ -n "$sel" ]] && alacritty -e journalctl -u "$sel" &
            else
                notify "Services" "No failed services"
            fi ;;
        "󰑐  Restart Service")
            local svc
            svc=$(systemctl list-units --type=service --state=running --no-legend | \
                awk '{print $1}' | rofi -dmenu -i -p "Restart" -theme "$ROFI_SUB_THEME")
            [[ -n "$svc" ]] && systemctl restart "$svc" && notify "Services" "$svc restarted" ;;
    esac
}

main
