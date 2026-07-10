#!/usr/bin/env bash
notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Resolution"
        "Refresh Rate"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Display" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Resolution") change_res ;;
        "Refresh Rate") change_rate ;;
    esac
}

change_res() {
    local res
    res=$(printf '%s\n' "1366x768" "1920x1080" | rofi -dmenu -i -p "Resolution" -theme "$ROFI_SUB_THEME")
    if [[ -n "$res" ]]; then
        hyprctl keyword monitor ",$res,0,1"
        notify "Display" "Resolution: $res"
    fi
}

change_rate() {
    local rate
    rate=$(printf '%s\n' "60" "48" "144" | rofi -dmenu -i -p "Rate" -theme "$ROFI_SUB_THEME")
    if [[ -n "$rate" ]]; then
        hyprctl keyword monitor ",$rate"
        notify "Display" "Refresh: ${rate}Hz"
    fi
}

main