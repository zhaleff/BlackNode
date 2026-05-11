#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)

if [[ "$MUTED" -gt 0 || "$VOL" -eq 0 ]]; then
    ICON="$ASSETS/volume-cross.svg"
elif [[ "$VOL" -le 50 ]]; then
    ICON="$ASSETS/volume-min.svg"
elif [[ "$VOL" -le 80 ]]; then
    ICON="$ASSETS/volume-full.svg"
else
    ICON="$ASSETS/volume-loud.svg"
fi

dunstify -a "volume" -h int:value:"$VOL" -i "$ICON" -t 2000 -r 2593 "Volume: $VOL%"
