#!/bin/bash

WALL_DIR="$HOME/.local/share/wallpapers"

SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
    | while read -r img; do
        printf '%s\0icon\x1f%s\n' "$img" "$img"
      done \
    | rofi -dmenu -i -show-icons -theme "$HOME/.config/rofi/wallselect/style.rasi"
)

[ -z "$SELECTED" ] && exit 0

if ! pgrep -x "awww" > /dev/null; then
    awww &
    sleep 0.2
fi

awww img "$SELECTED" --transition-type=random
