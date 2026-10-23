#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/error.svg"
declare -A notified

is_transient() {
    [[ "$(systemctl --user show -p Transient --value "$1" 2>/dev/null)" == "yes" ]]
}

check_failed_units() {
    local failed_now unit
    sleep 2
    failed_now=$(systemctl --user list-units --type=service --state=failed --no-legend --plain 2>/dev/null | awk '{print $1}')

    for unit in "${!notified[@]}"; do
        grep -qx "$unit" <<< "$failed_now" || unset 'notified[$unit]'
    done

    while read -r unit; do
        [[ -z "$unit" || -n "${notified[$unit]}" ]] && continue
        notified["$unit"]=1
        is_transient "$unit" && continue
        notify-send -i "$ICON" "Service failed" "$unit"
    done <<< "$failed_now"
}

dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/freedesktop/systemd1/unit'" 2>/dev/null \
    | while read -r line; do
        if [[ "$line" == *'string "ActiveState"'* ]]; then
            watch=1
        elif [[ -n "$watch" && "$line" == *variant* ]]; then
            watch=
            [[ "$line" == *'string "failed"'* ]] && check_failed_units
        fi
    done
