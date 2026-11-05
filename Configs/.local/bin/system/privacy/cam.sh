#!/usr/bin/env bash

ICON_ON="/tmp/blacknode-icons/privacy/camera.svg"
ICON_OFF="/tmp/blacknode-icons/privacy/camera-off.svg"

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/camera-watch.lock"
flock -n 9 || exit 0

prev=""

apps() {
    for pid in $(fuser /dev/video* 2>/dev/null); do
        ps -p "$pid" -o comm=
    done | grep -vE '^(wireplumber|pipewire)$' | sort -u
}

notify() {
    notify-send -a "Privacy" -i "$1" -t "$4" \
        -h "string:x-dunst-stack-tag:camera" "$2" "$3"
}

check() {
    local now
    now=$(apps)
    [[ $now == "$prev" ]] && return

    if [[ -n $now ]]; then
        notify "$ICON_ON" "Camera in use" "$now" 2500
    else
        notify "$ICON_OFF" "Camera released" "$prev" 1200
    fi
    prev=$now
}

check

while read -r _; do
    check
done < <(inotifywait -m -q -e open,close --include '/dev/video[0-9]+$' /dev)
