#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/battery"
STATE_FILE="/tmp/blacknode-battery-full-state"
THRESHOLDS=(80 90 95 100)

get_capacity() {
    cat /sys/class/power_supply/BAT0/capacity 2>/dev/null
}

is_charging() {
    [ "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)" = "Charging" ]
}

already_notified() {
    grep -qx "$1" "$STATE_FILE" 2>/dev/null
}

mark_notified() {
    echo "$1" >> "$STATE_FILE"
}

while true; do
    if ! is_charging; then
        : > "$STATE_FILE"
        sleep 30
        continue
    fi

    capacity=$(get_capacity)

    for threshold in "${THRESHOLDS[@]}"; do
        if [ "$capacity" -ge "$threshold" ] && ! already_notified "$threshold"; then
            icon="$ICON_DIR/battery-full.svg"
            message="Fully charged"
            if [ "$threshold" -lt 100 ]; then
                icon="$ICON_DIR/battery-plus.svg"
                message="At ${threshold}% - consider unplugging soon"
            fi
            notify-send -h string:x-canonical-private-synchronous:battery \
                -i "$icon" "Battery" "$message"
            mark_notified "$threshold"
        fi
    done

    sleep 30
done
