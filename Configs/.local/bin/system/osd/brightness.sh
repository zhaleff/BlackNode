#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/brightness.svg"

current=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( current * 100 / max ))

notify-send -h int:value:"$pct" -h string:x-canonical-private-synchronous:brightness \
    -i "$ICON" "Brightness" "${pct}%"
