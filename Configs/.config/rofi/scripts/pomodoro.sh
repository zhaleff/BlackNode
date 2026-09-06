#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
ICON_DIR="$HOME/.config/dunst/assets/src/system/pomodoro"

pomodoro_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰅶  Work (25m)" \
        "  Study (45m)" \
        "󰃨  Short Break (5m)" \
        "󰒲  Long Break (15m)" \
        "  Custom time" \
        "  Pause/Resume" \
        "  Stop" \
        | rofi -dmenu -theme "$THEME" -p "Pomodoro")

    case "$choice" in
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Work"*)
            pomodoro-cli start --duration 25m --message "Work"
            notify-send -i "$ICON_DIR/timer.svg" "Pomodoro" "Work session started - 25m" ;;
        *"Study"*)
            pomodoro-cli start --duration 45m --message "Study"
            notify-send -i "$ICON_DIR/timer.svg" "Pomodoro" "Study session started - 45m" ;;
        *"Short Break"*)
            pomodoro-cli start --duration 5m --message "Short Break"
            notify-send -i "$ICON_DIR/timer.svg" "Pomodoro" "Short break started - 5m" ;;
        *"Long Break"*)
            pomodoro-cli start --duration 15m --message "Long Break"
            notify-send -i "$ICON_DIR/timer.svg" "Pomodoro" "Long break started - 15m" ;;
        *"Custom time")
            local minutes
            minutes=$(rofi -dmenu -theme "$THEME" -p "Minutes")
            [ -z "$minutes" ] && { pomodoro_menu; return; }
            pomodoro-cli start --duration "${minutes}m"
            notify-send -i "$ICON_DIR/timer.svg" "Pomodoro" "Timer started - ${minutes}m" ;;
        *"Pause/Resume")
            pomodoro-cli pause
            notify-send -i "$ICON_DIR/timer-reset.svg" "Pomodoro" "Toggled pause/resume" ;;
        *"Stop")
            pomodoro-cli stop
            notify-send -i "$ICON_DIR/timer-off.svg" "Pomodoro" "Timer stopped" ;;
    esac
}

pomodoro_menu
