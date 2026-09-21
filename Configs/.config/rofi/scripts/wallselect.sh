#!/usr/bin/env bash

PROFILES_BASE="$HOME/.local/share/blacknode"
ACTIVE_FILE="$PROFILES_BASE/active_profile"
MODE_FILE="$PROFILES_BASE/theme_mode"
WALL_DIR="$HOME/Pictures/Wallpapers/"
WALLPAPER_NAME=$(basename "$SELECTED")
ICON="/tmp/blacknode-icons/wallpaper.svg"

if [[ -f "$ACTIVE_FILE" ]]; then
    active=$(cat "$ACTIVE_FILE")
    profile_walls="$PROFILES_BASE/profiles/$active/walls"
    [[ -d "$profile_walls" ]] && WALL_DIR="$profile_walls"
fi

SELECTED=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) \
    | while read -r img; do
        printf '%s\0icon\x1f%s\n' "$img" "$img"
      done \
    | rofi -dmenu -i -show-icons -theme "$HOME/.config/rofi/themes/presets/wallselect.rasi")

[[ -z "$SELECTED" ]] && exit 0

pgrep -x "awww" > /dev/null || awww &

if ! awww img "$SELECTED" --transition-type=random; then
    notify-send "Wallpaper" "Failed to set wallpaper" -i "$ICON"
    exit 1
fi

cp "$SELECTED" ~/.config/hypr/hyprlock.png

THEME_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "dark")

if ! matugen image "$SELECTED" -m "$THEME_MODE" --source-color-index 0; then
    notify-send "Wallpaper" "Theme generation failed, wallpaper still applied" -i "$ICON"
    exit 1
fi

killall dunst 2>/dev/null
dunst &
pkill -USR1 cava 2>/dev/null
killall -USR1 kitty 2>/dev/null

notify-send "Wallpaper" "Correctly applied $SELECTED" -i "$ICON"
