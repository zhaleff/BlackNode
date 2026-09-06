#!/usr/bin/env bash

status=$(pomodoro-cli status --format json --time-format digital 2>/dev/null)

if [ -z "$status" ]; then
    echo '{"text":"","tooltip":"No pomodoro running","class":"none"}'
    exit 0
fi

text=$(echo "$status" | jq -r '.text // empty')
tooltip=$(echo "$status" | jq -r '.tooltip // empty')
class=$(echo "$status" | jq -r '.class // empty')

if [ -z "$text" ]; then
    echo '{"text":"","tooltip":"No pomodoro running","class":"none"}'
    exit 0
fi

icon="󰄉"
case "$class" in
    paused)   icon="󰏤" ;;
    finished) icon="󰄲" ;;
esac

jq -nc --arg text "$icon $text" --arg tooltip "$tooltip" --arg class "$class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
