#!/usr/bin/env bash


ICON="/tmp/blacknode-icons/error.svg"
declare -A notified

check_failed_units() {
    local failed_now
    failed_now=$(systemctl --user list-units --type=service --state=failed --no-legend --plain 2>/dev/null | awk '{print $1}')

    for unit in "${!notified[@]}"; do
        grep -qx "$unit" <<< "$failed_now" || unset notified["$unit"]
    done

    while read -r unit; do
        [[ -z "$unit" || -n "${notified[$unit]}" ]] && continue
        notified["$unit"]=1
        notify-send -i "$ICON" "Service failed" "$unit"
    done <<< "$failed_now"
}

# React to systemd unit state changes via D-Bus (event-driven, no polling).
dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/freedesktop/systemd1/unit'" 2>/dev/null \
    | while read -r line; do
        [[ "$line" == *"member=PropertiesChanged"* ]] && check_failed_units
    done
