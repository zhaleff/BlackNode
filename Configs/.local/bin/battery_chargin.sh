#!/bin/bash

# Path to battery information
POWER_SUPPLY="/sys/class/power_supply/BAT0"

# Initial status to detect changes
PREV_STATUS=$(cat "$POWER_SUPPLY/status")

while true; do
    # Read current battery status and percentage
    CURRENT_STATUS=$(cat "$POWER_SUPPLY/status")
    BATTERY_PERCENT=$(cat "$POWER_SUPPLY/capacity")

    # Check if status has changed
    if [ "$CURRENT_STATUS" != "$PREV_STATUS" ]; then
        if [ "$CURRENT_STATUS" = "Charging" ]; then
            dunstify -i ~/.config/dunst/assets/battery-charging..svg -t 1000 -r 2594 "Connected to charger"
        elif [ "$CURRENT_STATUS" = "Discharging" ]; then
            dunstify -i ~/.config/dunst/assets/battery-charging.svg -t 1000 -r 2594 "Disconnected $BATTERY_PERCENT%"
        fi
        PREV_STATUS="$CURRENT_STATUS"
    fi

    # Sleep briefly to avoid excessive CPU usage
    sleep 5
done
