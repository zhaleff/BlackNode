#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu-bottom.rasi"

choice=$(printf '%s\n' \
    "  Lock" \
    "  Suspend" \
    "  Hibernate" \
    "󰍃  Logout" \
    "  Reboot" \
    "⏻  Shutdown" \
    | rofi -dmenu -theme "$THEME" -p "Session" -l 6 -theme-str 'window {width: 64%;}')


[ -z "$choice" ] && exit 0
[[ "$choice" == *"Back" ]] && exec bash "$ROFI_DIR/scripts/launcher.sh"

confirm() {
    local result
    result=$(printf '%s\n' "󰄬  Yes" "󰅖  No" | rofi -dmenu -theme "$THEME" -p "Are you sure?"  -theme-str 'window {width: 16%;}')
    [[ "$result" == *"Yes"* ]]
}

case "$choice" in
    *"Lock")
        if [[ -x '/usr/bin/betterlockscreen' ]]; then
            betterlockscreen -l
        elif [[ -x '/usr/bin/hyprlock' ]]; then
            hyprlock
        fi
        ;;
    *"Suspend")
        confirm && { mpc -q pause; amixer set Master mute; systemctl suspend; }
        ;;
    *"Hibernate")
        confirm && systemctl hibernate
        ;;
    *"Logout")
        confirm && hyprctl dispatch exit
        ;;
    *"Reboot")
        confirm && systemctl reboot
        ;;
    *"Shutdown")
        confirm && systemctl poweroff
        ;;
esac
