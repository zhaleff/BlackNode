#!/usr/bin/env bash

APP_NAME="${APP_NAME:-rofi}"

notify() {
    local msg="${1:-}" timeout="${2:-3000}" urgency="${3:-normal}"
    if command -v dunstify >/dev/null 2>&1; then
        dunstify -a "$APP_NAME" -t "$timeout" -u "$urgency" "$msg"
    else
        notify-send "$APP_NAME" "$msg"
    fi
}
