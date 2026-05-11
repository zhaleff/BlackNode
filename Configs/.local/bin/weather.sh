#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"

DATA=$(curl -sf "wttr.in/?format=j1") || exit 1

TEMP=$(echo "$DATA" | grep -o '"temp_C": *"[^"]*"' | head -1 | grep -o '[0-9-]*')
CODE=$(echo "$DATA" | grep -o '"weatherCode": *"[^"]*"' | head -1 | grep -o '[0-9]*')

[[ -z "$TEMP" || -z "$CODE" ]] && exit 1

if [[ "$CODE" -eq 113 ]]; then
    ICON="$ASSETS/weather-sun.svg"
    DESC="Clear"
elif [[ "$CODE" -le 260 ]]; then
    ICON="$ASSETS/weather-cloud.svg"
    DESC="Cloudy"
elif [[ "$CODE" -le 531 ]]; then
    ICON="$ASSETS/weather-rain.svg"
    DESC="Rain"
else
    ICON="$ASSETS/weather-storm.svg"
    DESC="Storm"
fi

dunstify -a "weather" -i "$ICON" -t 6000 "$DESC — ${TEMP}°C"
