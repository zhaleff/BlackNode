#!/usr/bin/env bash
source "$HOME/.config/rofi/lib/init.sh"
APP_NAME="Recorder"

SAVE_DIR="$HOME/Videos"
FILE="$SAVE_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"

choice=$(printf " \n \n󰹑 " | rmenu "$(t wf-recorder)" -i -p "")
PID=$(pgrep wf-recorder)

case "$choice" in
    " ")
        [ -n "$PID" ] && exit 1
        wf-recorder -f "$FILE" &
        notify "Recording: $(basename "$FILE")" 3000
        ;;
    " ")
        [ -n "$PID" ] && exit 1
        REGION=$(slurp) || exit 1
        wf-recorder -g "$REGION" -f "$FILE" &
        notify "Recording: $(basename "$FILE")" 3000
        ;;
    "󰹑 ")
        [ -z "$PID" ] && exit 1
        kill -SIGINT "$PID"
        notify "Saved: $SAVE_DIR" 3000
        ;;
esac
