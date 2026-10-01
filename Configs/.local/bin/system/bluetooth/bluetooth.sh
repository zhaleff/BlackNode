#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/bluetooth"
declare -A known_names
declare -A last_state

get_battery() {
    bluetoothctl info "$1" 2>/dev/null \
        | awk -F': ' '/Battery Percentage/{print $2; exit}' \
        | awk '{print $1}'
}

get_name() {
    local mac="$1" name tries=0
    while [[ $tries -lt 3 ]]; do
        name=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Name:/{print $2; exit}')
        [[ -n "$name" ]] && { echo "$name"; return; }
        sleep 0.3
        ((tries++))
    done
}

sync_id() {
    printf '%u' "0x$(echo -n "$1" | md5sum | cut -c1-7)"
}

notify_powered() {
    if [[ "$1" == "yes" ]]; then
        notify-send -i "$ICON_DIR/bluetooth.svg" "Bluetooth" "Bluetooth enabled"
    else
        notify-send -i "$ICON_DIR/bluetooth-off.svg" "Bluetooth" "Bluetooth disabled"
    fi
}

notify_connected() {
    local mac="$1" name battery
    [[ "${last_state[$mac]}" == "connected" ]] && return
    last_state["$mac"]="connected"

    name=$(get_name "$mac")
    [[ -z "$name" ]] && name="$mac"
    known_names["$mac"]="$name"

    battery=$(get_battery "$mac")
    if [[ -n "$battery" ]]; then
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:"bt-$(sync_id "$mac")" \
            -i "$ICON_DIR/bluetooth-connected.svg" "Bluetooth" "$name connected (${battery}%)"
    else
        notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:"bt-$(sync_id "$mac")" \
            -i "$ICON_DIR/bluetooth-connected.svg" "Bluetooth" "$name connected"
    fi
}

notify_disconnected() {
    local mac="$1" name="${known_names[$1]}"
    [[ "${last_state[$mac]}" == "disconnected" ]] && return
    last_state["$mac"]="disconnected"

    [[ -z "$name" ]] && name=$(get_name "$mac")
    [[ -z "$name" ]] && name="$mac"
    notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:"bt-$(sync_id "$mac")" \
        -i "$ICON_DIR/bluetooth.svg" "Bluetooth" "$name disconnected"
}

notify_discovering() {
    notify-send -i "$ICON_DIR/bluetooth-searching.svg" "Bluetooth" "Scanning for devices"
}

bluetoothctl < <(sleep infinity) 2>&1 | while read -r line; do
    case "$line" in
        *"Controller "*" Powered: yes"*) notify_powered yes ;;
        *"Controller "*" Powered: no"*)  notify_powered no ;;
        *"Controller "*" Discovering: yes"*) notify_discovering ;;
        *"Device "*" Connected: yes"*)
            notify_connected "$(awk '{print $3}' <<< "$line")" ;;
        *"Device "*" Connected: no"*)
            notify_disconnected "$(awk '{print $3}' <<< "$line")" ;;
    esac
done
