#!/usr/bin/env bash

mic_apps=()
cam_apps=()

while IFS= read -r line; do
    mic_apps+=("$line")
done < <(pactl list source-outputs 2>/dev/null | grep "application.name" | sed -E 's/.*= "(.*)"/\1/')

for dev in /dev/video*; do
    [ -e "$dev" ] || continue
    pid=$(fuser "$dev" 2>/dev/null | awk '{print $1}')
    if [ -n "$pid" ]; then
        proc=$(ps -p "$pid" -o comm= 2>/dev/null)
        [ -n "$proc" ] && cam_apps+=("$proc")
    fi
done

mic_count="${#mic_apps[@]}"
cam_count="${#cam_apps[@]}"

if [ "$mic_count" -gt 0 ] && [ "$cam_count" -gt 0 ]; then
    text="󰍬 󰄀"
    class="active"
    tooltip="Microphone: $(IFS=', '; echo "${mic_apps[*]}")\nCamera: $(IFS=', '; echo "${cam_apps[*]}")"
elif [ "$mic_count" -gt 0 ]; then
    text="󰍬 󰄄"
    class="mic-active"
    tooltip="Microphone: $(IFS=', '; echo "${mic_apps[*]}")"
elif [ "$cam_count" -gt 0 ]; then
    text="󰍭 󰄀"
    class="cam-active"
    tooltip="Camera: $(IFS=', '; echo "${cam_apps[*]}")"
else
    text="󰍭 󰄄"
    class="idle"
    tooltip="Microphone and camera idle"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
