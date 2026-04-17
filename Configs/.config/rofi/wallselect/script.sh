#!/usr/bin/env bash

WALL_DIR="$HOME/.local/share/wallpapers"

SELECTED=$(find "$WALL_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.gif" \) \
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

# Solo copia a wallust si NO es gif (porque wallust no maneja bien gifs)
if [[ "$SELECTED" != *.gif ]]; then
    cp "$SELECTED" ~/.cache/wallust/current_wallpaper.png
    wallust run ~/.cache/wallust/current_wallpaper.png
    wallust run "$SELECTED"
fi

killall -SIGUSR2 waybar && killall dunst && dunst &
pkill -USR1 cava
