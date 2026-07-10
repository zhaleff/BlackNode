#!/usr/bin/env bash

THEMES_DIR="$HOME/.local/share/blacknode/themes"
STYLE="$HOME/.config/rofi/styles/themeselect.rasi"

SELECTED=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r theme; do
    NAME=$(basename "$theme")
    PREVIEW=$(find "$theme" -maxdepth 1 -name "preview.*" | head -1)
    [[ -z "$PREVIEW" ]] && continue
    printf '%s\0icon\x1f%s\n' "$NAME" "$PREVIEW"
done | rofi -dmenu -i -show-icons -theme "$STYLE")

[[ -z "$SELECTED" ]] && exit 0

WALL=$(find "$THEMES_DIR/$SELECTED/walls" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)
[[ -z "$WALL" ]] && exit 0

pgrep -x awww > /dev/null || { awww & sleep 0.2; }
awww img "$WALL" --transition-type=random

cp "$WALL" ~/.cache/wallust/current_wallpaper.png
wallust run "$WALL"

killall -SIGUSR2 waybar
killall dunst && dunst &
pkill -USR1 cava
