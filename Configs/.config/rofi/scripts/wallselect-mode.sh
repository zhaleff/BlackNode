#!/usr/bin/env bash
set -euo pipefail

MODE_FILE="$HOME/.local/share/blacknode/theme_mode"
mkdir -p "$(dirname "$MODE_FILE")"

OPTIONS="<span color='red'>󰅖</span>\nDark\nLight"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -markup-rows -theme "$HOME/.config/rofi/styles/wallselect-mode.rasi")

if [[ "$CHOICE" == *"Dark"* ]]; then
    echo "dark" > "$MODE_FILE"
elif [[ "$CHOICE" == *"Light"* ]]; then
    echo "light" > "$MODE_FILE"
fi
