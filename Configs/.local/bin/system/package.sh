#!/usr/bin/env bash

ICON="$HOME/.config/dunst/assets/fixed/package.svg"

count=$(checkupdates 2>/dev/null | wc -l)

[[ "$count" -eq 0 ]] && exit 0

notify-send -i "$ICON" "PacMan updates" "$count packages pending"
