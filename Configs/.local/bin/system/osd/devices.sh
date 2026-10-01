#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/usb.svg"
declare -A known_names

get_device_name() {
    udevadm info --query=property -p "$1" 2>/dev/null \
        | awk -F= '/^ID_MODEL=/{print $2; exit}' \
        | tr '_' ' '
}

notify_connected() {
    local devpath="$1" name
    name=$(get_device_name "$devpath")
    [[ -z "$name" ]] && return
    known_names["$devpath"]="$name"
    notify-send -i "$ICON" "USB" "$name connected"
}

notify_disconnected() {
    local devpath="$1" name="${known_names[$devpath]}"
    unset known_names["$devpath"]
    [[ -z "$name" ]] && return
    notify-send -i "$ICON" "USB" "$name disconnected"
}

udevadm monitor --udev --subsystem-match=usb | while read -r line; do
    case "$line" in
        *"add"*"/usb"*)
            devpath=$(awk '{print $3}' <<< "$line")
            [[ "$devpath" == *:* ]] && continue
            notify_connected "$devpath" ;;
        *"remove"*"/usb"*)
            devpath=$(awk '{print $3}' <<< "$line")
            [[ "$devpath" == *:* ]] && continue
            notify_disconnected "$devpath" ;;
    esac
done
