#!/usr/bin/env bash

ICON_DIR="$HOME/.config/dunst/assets/weather/dark"
CACHE="/tmp/blacknode-location"

get_location() {
    [[ -f "$CACHE" ]] && cat "$CACHE" && return
    curl -s "http://ip-api.com/json/" | tee "$CACHE"
}

loc=$(get_location)
lat=$(echo "$loc" | jq -r '.lat')
lon=$(echo "$loc" | jq -r '.lon')

data=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&hourly=precipitation_probability&forecast_hours=3")

temp=$(echo "$data" | jq -r '.current.temperature_2m')
code=$(echo "$data" | jq -r '.current.weather_code')
rain_chance=$(echo "$data" | jq -r '.hourly.precipitation_probability | max')

icon_for_code() {
    case "$1" in
        0) echo "clear.svg" ;;
        1) echo "mostly_clear.svg" ;;
        2) echo "partly_cloudy.svg" ;;
        3) echo "cloudy.svg" ;;
        45|48) echo "mist.svg" ;;
        51|53|55) echo "drizzle.svg" ;;
        56|57) echo "sleet_hail.svg" ;;
        61) echo "showers.svg" ;;
        63|65) echo "heavy.svg" ;;
        66|67) echo "wintry_mix.svg" ;;
        71) echo "snow_showers.svg" ;;
        73|75) echo "heavy_snow.svg" ;;
        77) echo "flurries.svg" ;;
        80|81) echo "scattered_showers.svg" ;;
        82) echo "heavy.svg" ;;
        85|86) echo "scattered_snow.svg" ;;
        95) echo "isolated_tstorms.svg" ;;
        96|99) echo "strong_tstorms.svg" ;;
        *) echo "cloudy.svg" ;;
    esac
}

icon="$ICON_DIR/$(icon_for_code "$code")"

notify-send -i "$icon" "Weather" "${temp}°C"

if [[ "$rain_chance" -ge 70 ]]; then
    notify-send -i "$ICON_DIR/showers.svg" "Weather" "Rain likely soon (${rain_chance}%)"
fi
