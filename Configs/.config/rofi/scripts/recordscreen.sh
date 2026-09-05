#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
OUT_DIR="$HOME/Videos/Recordings"
mkdir -p "$OUT_DIR"

recorder_menu() {
    if pgrep -x "wf-recorder" > /dev/null; then
        choice=$(printf '%s\n' \
            "󰌍  Back" \
            "  Stop recording" \
            | rofi -dmenu -theme "$THEME" -p "Recording...")

        case "$choice" in
            *"Back")            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
            *"Stop recording")  pkill -INT -x wf-recorder ;;
        esac
        return
    fi

    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  Fullscreen" \
        "  Select region" \
        "  Fullscreen (no audio)" \
        "  Select region (no audio)" \
        | rofi -dmenu -theme "$THEME" -p "Record")

    local file
    file="$OUT_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"

    case "$choice" in
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Fullscreen (no audio)")
            wf-recorder -f "$file" & disown ;;
        *"Fullscreen")
            wf-recorder -f "$file" --audio & disown ;;
        *"Select region (no audio)")
            wf-recorder -g "$(slurp)" -f "$file" & disown ;;
        *"Select region")
            wf-recorder -g "$(slurp)" -f "$file" --audio & disown ;;
    esac
}

recorder_menu
