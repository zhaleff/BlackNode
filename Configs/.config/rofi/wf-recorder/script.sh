#!/bin/bash

SAVE_DIR="$HOME/Videos"
FILE="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"

CHOICE=$(printf " \n \n󰹑 " | rofi -dmenu -i -p "" -theme "$HOME/.config/rofi/wf-recorder/style.rasi")

PID=$(pgrep wf-recorder)

case "$CHOICE" in
    " ")
        [[ -n "$PID" ]] && exit 1
        wf-recorder -f "$FILE" &
        dunstify -a "recorder" -t 3000 "Recording" "$(basename "$FILE")"
        ;;
    " ")
        [[ -n "$PID" ]] && exit 1
        REGION=$(slurp) || exit 1
        wf-recorder -g "$REGION" -f "$FILE" &
        dunstify -a "recorder" -t 3000 "Recording" "$(basename "$FILE")"
        ;;
    "󰹑 ")
        [[ -z "$PID" ]] && exit 1
        kill -SIGINT "$PID"
        dunstify -a "recorder" -t 3000 "Saved" "$SAVE_DIR"
        ;;
esac
