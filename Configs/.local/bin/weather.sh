#!/usr/bin/env bash
# BlackNode Weather - OpenMeteo + GitHub messages + empathetic UX
# UTC time, detects incoming conditions, companion-style notifications

set -euo pipefail

ASSETS="$HOME/.config/dunst/assets"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/blacknode"
MSG_CACHE="$CACHE_DIR/weather-messages.json"
LOCATION_CACHE="$CACHE_DIR/location.json"

mkdir -p "$CACHE_DIR"

get_location() {
    if [[ -f "$LOCATION_CACHE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$LOCATION_CACHE"))) -lt 86400 ]]; then
        cat "$LOCATION_CACHE"
        return
    fi
    local loc
    loc=$(curl -sf "https://ipapi.co/json/" | python3 -c "
import sys, json
d=json.load(sys.stdin)
print(f'{d.get(\"latitude\",0):.2f},{d.get(\"longitude\",0):.2f}')
") || loc="40.41,-3.70"
    echo "$loc" > "$LOCATION_CACHE"
    echo "$loc"
}

fetch_messages() {
    if [[ -f "$MSG_CACHE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$MSG_CACHE"))) -lt 3600 ]]; then
        cat "$MSG_CACHE"
        return
    fi
    local msgs
    msgs=$(curl -sf "https://raw.githubusercontent.com/zhaleff/blacknode/main/weather-messages.json" 2>/dev/null) || msgs='{}'
    echo "$msgs" > "$MSG_CACHE"
    echo "$msgs"
}

get_weather() {
    local loc="$1"
    local lat="${loc%,*}"
    local lon="${loc#*,}"
    curl -sf "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=weathercode,temperature_2m,precipitation_probability,precipitation&timezone=UTC&forecast_hours=12"
}

wmo_to_condition() {
    case "$1" in
        0) echo "clear" ;;
        1|2|3) echo "cloudy" ;;
        45|48) echo "fog" ;;
        51|53|55|56|57|61|63|65|66|67|80|81|82) echo "rain" ;;
        71|73|75|77|85|86) echo "snow" ;;
        95|96|99) echo "storm" ;;
        *) echo "unknown" ;;
    esac
}

wmo_to_icon() {
    local cond=$(wmo_to_condition "$1")
    echo "$ASSETS/weather-$cond.svg"
}

wmo_to_desc() {
    case "$1" in
        0) echo "Clear sky" ;;
        1) echo "Mainly clear" ;;
        2) echo "Partly cloudy" ;;
        3) echo "Overcast" ;;
        45|48) echo "Fog" ;;
        51) echo "Light drizzle" ;;
        53) echo "Moderate drizzle" ;;
        55) echo "Dense drizzle" ;;
        56|57) echo "Freezing drizzle" ;;
        61) echo "Slight rain" ;;
        63) echo "Moderate rain" ;;
        65) echo "Heavy rain" ;;
        66|67) echo "Freezing rain" ;;
        71) echo "Slight snow" ;;
        73) echo "Moderate snow" ;;
        75) echo "Heavy snow" ;;
        77) echo "Snow grains" ;;
        80) echo "Slight rain showers" ;;
        81) echo "Moderate rain showers" ;;
        82) echo "Violent rain showers" ;;
        85) echo "Slight snow showers" ;;
        86) echo "Heavy snow showers" ;;
        95) echo "Thunderstorm" ;;
        96|99) echo "Thunderstorm with hail" ;;
        *) echo "Unknown" ;;
    esac
}

get_message() {
    local msgs_json="$1"
    local key="$2"
    local subkey="${3:-default}"
    echo "$msgs_json" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    msg = d.get('$key', {}).get('$subkey', '')
    print(msg)
except:
    print('')
"
}

format_msg() {
    local msg="$1"
    shift
    while [[ $# -gt 0 ]]; do
        local k="$1" v="$2"
        msg="${msg//\{$k\}/$v}"
        shift 2
    done
    echo "$msg"
}

float_ge() { python3 -c "print(int(float('$1') >= float('$2')))"; }
float_lt() { python3 -c "print(int(float('$1') < float('$2')))"; }

main() {
    local loc msgs_json weather current temp code desc cond icon
    local now_hour rain_hours=() storm_coming=false heat_wave=false freeze_warning=false

    loc=$(get_location)
    msgs_json=$(fetch_messages)
    weather=$(get_weather "$loc")

    current=$(echo "$weather" | python3 -c "
import sys, json
d = json.load(sys.stdin)
cw = d['current_weather']
print(f\"{cw['temperature']} {cw['weathercode']} {cw['time']}\")
")

    temp="${current%% *}"
    rest="${current#* }"
    code="${rest%% *}"
    now_hour=$(date -u +%H)
    now_hour=$((10#$now_hour))

    desc=$(wmo_to_desc "$code")
    cond=$(wmo_to_condition "$code")
    icon=$(wmo_to_icon "$code")

    local hourly
    hourly=$(echo "$weather" | python3 -c "
import sys, json
d = json.load(sys.stdin)
h = d['hourly']
for i in range(len(h['time'])):
    t = h['time'][i][11:13]
    wc = h['weathercode'][i]
    tp = h['temperature_2m'][i]
    pp = h['precipitation_probability'][i]
    pr = h['precipitation'][i]
    print(f'{t} {wc} {tp} {pp} {pr}')
")

    while read -r h wc tp pp pr; do
        [[ -z "$h" ]] && continue
        local h_int=$((10#$h))
        if (( h_int > now_hour && h_int <= now_hour + 6 )); then
            local c=$(wmo_to_condition "$wc")
            if [[ "$c" == "rain" ]] && (( pp > 50 )); then
                rain_hours+=("$h:00")
            fi
            if [[ "$c" == "storm" ]]; then
                storm_coming=true
            fi
        fi
        if [[ $(float_ge "$tp" "32") -eq 1 ]]; then
            heat_wave=true
        fi
        if [[ $(float_lt "$tp" "2") -eq 1 ]]; then
            freeze_warning=true
        fi
    done <<< "$hourly"

    local title body urgency="normal" timeout=8000

    if [[ "$storm_coming" == true ]]; then
        title="⛈️ Storm Approaching"
        body=$(get_message "$msgs_json" "storm")
        urgency="critical"
        timeout=15000
    elif [[ ${#rain_hours[@]} -gt 0 ]]; then
        local hours_str
        hours_str=$(IFS=,; echo "${rain_hours[*]}")
        title="🌧️ Rain Coming"
        body=$(get_message "$msgs_json" "rain" "default")
        body=$(format_msg "$body" hours "$hours_str" temp "$temp")
        urgency="normal"
        timeout=10000
    elif [[ "$heat_wave" == true ]]; then
        title="☀️ Heat Wave"
        body=$(get_message "$msgs_json" "heat")
        urgency="normal"
        timeout=10000
        icon="$ASSETS/weather-heat.svg"
    elif [[ "$freeze_warning" == true ]]; then
        title="🧊 Freezing Soon"
        body=$(get_message "$msgs_json" "freeze")
        urgency="low"
        timeout=8000
    else
        title="$desc — ${temp}°C"
        body=$(get_message "$msgs_json" "default" "current")
        body=$(format_msg "$body" desc "$desc" temp "$temp" hour "$now_hour")
        urgency="low"
        timeout=6000
    fi

    [[ -z "$body" ]] && body="$title"
    dunstify -a "weather" -i "$icon" -u "$urgency" -t "$timeout" "$title" "$body"
}

main "$@"