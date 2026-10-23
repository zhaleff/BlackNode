#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons"

leds=(/sys/class/leds/*::capslock/brightness)
[[ -e "${leds[0]}" ]] || exit 1

caps_on() {
    local led v
    for led in "${leds[@]}"; do
        read -r v < "$led"
        [[ "$v" -gt 0 ]] && return 0
    done
    return 1
}

notify_caps() {
    local icon="lock-open.svg" body="Off"
    [[ "$1" == "on" ]] && { icon="lock.svg"; body="On"; }

    notify-send -h string:x-canonical-private-synchronous:capslock \
        -i "$ICON_DIR/$icon" "Caps Lock" -t 500 "$body"
}

caps_on && last="on" || last="off"

while true; do
    caps_on && state="on" || state="off"
    if [[ "$state" != "$last" ]]; then
        last="$state"
        notify_caps "$state"
    fi
    sleep 0.25
done
