#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/battery"
STATE_FILE="/tmp/blacknode-battery-low-state"
THRESHOLDS=(20 15 10 5)

get_capacity() {
    cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
}

is_discharging() {
    [ "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)" = "Discharging" ]
}

already_notified() {
    grep -qx "$1" "$STATE_FILE" 2>/dev/null
}

mark_notified() {
    echo "$1" >> "$STATE_FILE"
}

while true; do
    if ! is_discharging; then
        : > "$STATE_FILE"
        sleep 30
        continue
    fi

    capacity=$(get_capacity)

    for threshold in "${THRESHOLDS[@]}"; do
        if [ "$capacity" -le "$threshold" ] && ! already_notified "$threshold"; then
            icon="$ICON_DIR/battery-low.svg"
            [ "$threshold" -gt 10 ] && icon="$ICON_DIR/battery-medium.svg"
            urgency="normal"
            [ "$threshold" -le 10 ] && urgency="critical"
            notify-send -u "$urgency" -i "$icon" "Battery" "Battery at ${threshold}%"
            mark_notified "$threshold"
        fi
    done

    sleep 30
done
