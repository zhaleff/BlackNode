#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

choice=$(printf '%s\n' \
    "  Lock" \
    "  Suspend" \
    "  Hibernate" \
    "󰍃  Logout" \
    "⟳  Reboot" \
    "⏻  Shutdown" \
    | rofi -dmenu -theme "$THEME" -p "Session")

[ -z "$choice" ] && exit 0

confirm() {
    local result
    result=$(printf '%s\n' "󰄬  Yes" "󰅖  No" | rofi -dmenu -theme "$THEME" -p "Are you sure?")
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
