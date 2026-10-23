#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/bluetooth"
declare -A known_names
declare -A last_state
declare -A pending_battery

mac_re='([0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5})'
device_re="Device $mac_re Connected: (yes|no)"
battery_re='Device '"$mac_re"' Battery Percentage: 0x[0-9A-Fa-f]+ \(([0-9]+)\)'

notify() {
    notify-send -h int:transient:1 -h string:x-canonical-private-synchronous:"bt-$1" \
        -i "$ICON_DIR/$2" "Bluetooth" "$3"
}

get_battery() {
    bluetoothctl info "$1" 2>/dev/null \
        | awk -F'[()]' '/Battery Percentage/{print $2; exit}'
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

notify_powered() {
    if [[ "$1" == "yes" ]]; then
        notify-send -i "$ICON_DIR/bluetooth.svg" "Bluetooth" "Bluetooth enabled"
    else
        notify-send -i "$ICON_DIR/bluetooth-off.svg" "Bluetooth" "Bluetooth disabled"
    fi
}

notify_connected() {
    local mac="$1" name battery body
    [[ "${last_state[$mac]}" == "connected" ]] && return
    last_state["$mac"]="connected"

    name=$(get_name "$mac")
    [[ -n "$name" ]] && known_names["$mac"]="$name"

    body="${name:-$mac} connected"
    battery=$(get_battery "$mac")
    if [[ -n "$battery" ]]; then
        body+=" (${battery}%)"
    else
        pending_battery["$mac"]=1
    fi

    notify "$mac" bluetooth-connected.svg "$body"
}

notify_disconnected() {
    local mac="$1" name="${known_names[$1]}"
    [[ "${last_state[$mac]}" == "disconnected" ]] && return
    last_state["$mac"]="disconnected"
    unset 'pending_battery[$mac]'

    [[ -z "$name" ]] && name=$(get_name "$mac")

    notify "$mac" bluetooth.svg "${name:-$mac} disconnected"
}

notify_battery() {
    local mac="$1" battery="$2"
    [[ -z "${pending_battery[$mac]}" ]] && return
    unset 'pending_battery[$mac]'

    notify "$mac" bluetooth-connected.svg "${known_names[$mac]:-$mac} connected (${battery}%)"
}

notify_discovering() {
    notify-send -i "$ICON_DIR/bluetooth-searching.svg" "Bluetooth" "Scanning for devices"
}

bluetoothctl < <(sleep infinity) 2>&1 | while read -r line; do
    if [[ "$line" =~ $device_re ]]; then
        if [[ "${BASH_REMATCH[3]}" == "yes" ]]; then
            notify_connected "${BASH_REMATCH[1]}"
        else
            notify_disconnected "${BASH_REMATCH[1]}"
        fi
        continue
    fi

    if [[ "$line" =~ $battery_re ]]; then
        notify_battery "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}"
        continue
    fi

    case "$line" in
        *"Controller "*" Powered: yes"*)     notify_powered yes ;;
        *"Controller "*" Powered: no"*)      notify_powered no ;;
        *"Controller "*" Discovering: yes"*) notify_discovering ;;
    esac
done
