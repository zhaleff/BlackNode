#!/usr/bin/env bash
# BlackNode Brain suggestion prompt.
# The brain calls this when it has learned a routine (e.g. you always open
# Spotify around 22:00). Instead of launching blindly, it asks the user.
# Usage: brain-suggest.sh <app>
set -euo pipefail

APP="${1:-}"
[[ -z "$APP" ]] && exit 1

THEME="$HOME/.config/rofi/styles/submenu.rasi"
PROMPT="BlackNode learned you usually open '$APP' now. Open it?"

CHOICE=$(printf "Yes\nNo" | rofi -dmenu -p "$PROMPT" -theme "$THEME" -lines 2)

case "$CHOICE" in
    Yes) command -v "$APP" >/dev/null 2>&1 && "$APP" & disown ;;
    *) exit 0 ;;
esac
