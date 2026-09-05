#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.config/rofi/lib/init.sh"

MODE_FILE="$HOME/.local/share/blacknode/theme_mode"
mkdir -p "$(dirname "$MODE_FILE")"

OPTIONS="<span color='red'>󰅖</span>\nDark\nLight"
choice=$(echo -e "$OPTIONS" | rmenu "$(t wallselect-mode)" -i -markup-rows)

[[ "$choice" == *"Dark"* ]] && echo "dark" > "$MODE_FILE"
[[ "$choice" == *"Light"* ]] && echo "light" > "$MODE_FILE"
