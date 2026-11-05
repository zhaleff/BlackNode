#!/usr/bin/env bash

ICON_ON="/tmp/blacknode-icons/privacy/mic.svg"
ICON_OFF="/tmp/blacknode-icons/privacy/mic-off.svg"

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/mic-watch.lock"
flock -n 9 || exit 0

prev=""

apps() {
    pactl -f json list source-outputs | jq -r '
        .[]
        | select(.corked == false and .properties["media.name"] != "Peak detect")
        | .properties["application.name"] // "Unknown app"' | sort -u
}

notify() {
    notify-send -a "Privacy" -i "$1" -h "string:x-dunst-stack-tag:mic" "$2" "$3"
}

check() {
    local now
    now=$(apps)
    [[ $now == "$prev" ]] && return

    if [[ -n $now ]]; then
        notify "$ICON_ON" "Microphone in use" "$now"
    else
        notify "$ICON_OFF" "Microphone released" "$prev"
    fi
    prev=$now
}

check

while read -r _; do
    check
done < <(pactl subscribe | grep --line-buffered "source-output")
