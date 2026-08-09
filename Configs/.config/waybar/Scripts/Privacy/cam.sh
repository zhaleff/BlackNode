#!/usr/bin/env bash

cam_apps=()

for dev in /dev/video*; do
    [ -e "$dev" ] || continue

    pid=$(fuser "$dev" 2>/dev/null | awk '{print $1}')

    if [ -n "$pid" ]; then
        proc=$(ps -p "$pid" -o comm= 2>/dev/null)

        [ -n "$proc" ] && cam_apps+=("$proc")
    fi
done

cam_count="${#cam_apps[@]}"

if [ "$cam_count" -gt 0 ]; then
    text="󰄀"
    class="cam-active"
    tooltip="Camera: $(IFS=', '; echo "${cam_apps[*]}")"
else
    text="󰗟"
    class="idle"
    tooltip="Camera idle"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$tooltip"
