#!/usr/bin/env bash

STYLE="$HOME/.config/rofi/search/style.rasi"

CHOICE=$(fd . "$HOME" --type f --hidden --exclude .git 2>/dev/null | \
    rofi -dmenu -i -p "󰍉" -theme "$STYLE")

[[ -z "$CHOICE" ]] && exit 0

MIME=$(file --mime-type -b "$CHOICE")

case "$MIME" in
    image/*)         swayimg "$CHOICE" ;;
    video/*)         mpv "$CHOICE" ;;
    audio/*)         mpv "$CHOICE" ;;
    application/pdf) zathura "$CHOICE" ;;
    text/*)          kitty -e nvim "$CHOICE" ;;
    *)               xdg-open "$CHOICE" ;;
esac
