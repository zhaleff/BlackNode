#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/usb.svg"

get_device_name() {
    local devpath="$1"
    udevadm info --query=property -p "$devpath" 2>/dev/null \
        | awk -F= '/^ID_MODEL=/{print $2; exit}' \
        | tr '_' ' '
}

notify_connected() {
    local devpath="$1"
    local name
    name=$(get_device_name "$devpath")
    [[ -z "$name" ]] && name="Unknown device"
    notify-send -i "$ICON" "USB" "$name connected"
}

notify_disconnected() {
    notify-send -i "$ICON" "USB" "Device disconnected"
}

udevadm monitor --udev --subsystem-match=usb | while read -r line; do
    case "$line" in
        *"add"*"/usb"*)
            devpath=$(echo "$line" | awk '{print $3}')
            [[ "$devpath" == *:* ]] && continue
            notify_connected "$devpath" ;;
        *"remove"*"/usb"*)
            devpath=$(echo "$line" | awk '{print $3}')
            [[ "$devpath" == *:* ]] && continue
            notify_disconnected ;;
    esac
done
