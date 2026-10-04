#!/usr/bin/env bash

mic_apps=()

while IFS= read -r line; do
    mic_apps+=("$line")
done < <(
    pactl list source-outputs 2>/dev/null |
    grep "application.name" |
    sed -E 's/.*= "(.*)"/\1/'
)

mic_count="${#mic_apps[@]}"

if [ "$mic_count" -gt 0 ]; then
    text="󰍬"
    class="mic-active"
    tooltip="Microphone: $(IFS=', '; echo "${mic_apps[*]}")"
else
    text="󰍭"
    class="idle"
    tooltip="Microphone idle"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$tooltip"
