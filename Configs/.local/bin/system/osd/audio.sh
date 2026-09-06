#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/volume"

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(echo "$status" | awk '{printf "%d", $2 * 100}')
muted=$(echo "$status" | grep -c MUTED)

if [[ "$muted" -gt 0 ]]; then
    icon="$ICON_DIR/volume-mute.svg"
    notify-send -h string:x-canonical-private-synchronous:volume \
        -i "$icon" "Volume" "Muted"
    exit 0
fi

if   [[ "$vol" -eq 0 ]];  then icon="$ICON_DIR/volume-off.svg"
elif [[ "$vol" -le 33 ]]; then icon="$ICON_DIR/volume-min.svg"
elif [[ "$vol" -le 66 ]]; then icon="$ICON_DIR/volume-cross.svg"
else                            icon="$ICON_DIR/volume-loud.svg"
fi

notify-send -h int:value:"$vol" -h string:x-canonical-private-synchronous:volume \
    -i "$icon" "Volume" "${vol}%"
