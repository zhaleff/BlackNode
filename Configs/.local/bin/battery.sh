#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"
BAT="/sys/class/power_supply"
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/battery_notify.lock"

if [ -f "$LOCKFILE" ] && kill -0 $(cat "$LOCKFILE") 2>/dev/null; then
    exit 1
fi
echo $$ > "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

PREV_STATUS=""
NOTIFIED_LOW=false
NOTIFIED_CRITICAL=false
NOTIFIED_FULL=false

get_capacity() { cat "$BAT"/*/capacity 2>/dev/null | head -1; }
get_status()   { cat "$BAT"/*/status   2>/dev/null | head -1; }

while true; do
    CAP=$(get_capacity)
    STATUS=$(get_status)

    if [[ "$STATUS" != "$PREV_STATUS" ]]; then
        if [[ "$STATUS" == "Charging" ]]; then
            dunstify -i "$ASSETS/battery-charging.svg" -t 4000 -r 2594 "Charger connected — ${CAP}%"
            NOTIFIED_FULL=false
        elif [[ "$STATUS" == "Discharging" ]]; then
            dunstify -i "$ASSETS/battery-charging.svg" -t 4000 -r 2594 "Charger disconnected — ${CAP}%"
            NOTIFIED_LOW=false
            NOTIFIED_CRITICAL=false
        fi
        PREV_STATUS="$STATUS"
    fi

    if [[ "$STATUS" == "Discharging" ]]; then
        if [[ "$CAP" -le 5 && "$NOTIFIED_CRITICAL" == false ]]; then
            dunstify -u critical -i "$ASSETS/battery-low.svg" -t 0 -r 2594 "Critical battery — ${CAP}%"
            NOTIFIED_CRITICAL=true
            NOTIFIED_LOW=true
        elif [[ "$CAP" -le 15 && "$NOTIFIED_LOW" == false ]]; then
            dunstify -u critical -i "$ASSETS/battery-low.svg" -t 8000 -r 2594 "Low battery — ${CAP}%"
            NOTIFIED_LOW=true
        fi
    fi

    if [[ "$STATUS" == "Charging" && "$CAP" -ge 80 && "$NOTIFIED_FULL" == false ]]; then
        dunstify -i "$ASSETS/battery-full.svg" -t 8000 -r 2594 "Battery full — ${CAP}%"
        NOTIFIED_FULL=true
    fi

    sleep 30
done
