#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
OUT_DIR="$HOME/Videos/Recordings"
ICON="/tmp/blacknode-icons/recording/recordscreen.svg"

mkdir -p "$OUT_DIR"

notify() {
    notify-send -a "Screen Recorder" -i "$ICON" "$1" "$2"
}

menu() {
    local prompt=$1
    shift
    printf '%s\n' "$@" | rofi -dmenu -i -format i -theme "$THEME" -p "$prompt"
}

open_folder() {
    xdg-open "$OUT_DIR" &>/dev/null &
    disown
}

start() {
    local mode=$1 audio=$2
    local file="$OUT_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"
    local args=(-f "$file")
    local geometry

    if [[ $mode == region ]]; then
        geometry=$(slurp) || return
        args+=(-g "$geometry")
    fi

    [[ $audio == audio ]] && args+=(--audio)

    (
        notify "Recording started" "${file##*/}"
        wf-recorder "${args[@]}"
        if [[ -s $file ]]; then
            notify "Recording saved" "$file"
        else
            notify "Recording failed" "No output was written"
        fi
    ) &>/dev/null &
    disown
}

recording_menu() {
    local choice
    choice=$(menu "Recording" \
        "󰌍  Back" \
        "󰓛  Stop recording" \
        "󰉋  Open recordings folder") || return

    case $choice in
        0) exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        1) pkill -INT -x wf-recorder ;;
        2) open_folder ;;
    esac
}

idle_menu() {
    local choice
    choice=$(menu "Record" \
        "󰌍  Back" \
        "󰑋  Fullscreen" \
        "󰩬  Select region" \
        "󰍭  Fullscreen (no audio)" \
        "󰍭  Select region (no audio)" \
        "󰉋  Open recordings folder") || return

    case $choice in
        0) exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        1) start fullscreen audio ;;
        2) start region audio ;;
        3) start fullscreen mute ;;
        4) start region mute ;;
        5) open_folder ;;
    esac
}

if pgrep -x wf-recorder >/dev/null; then
    recording_menu
else
    idle_menu
fi
