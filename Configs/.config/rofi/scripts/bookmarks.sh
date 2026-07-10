#!/usr/bin/env bash

STYLE="$HOME/.config/rofi/styles/bookmarks.rasi"

declare -A BOOKMARKS=(
    ["󰊤 "]="https://github.com"
    ["󰑍 "]="https://reddit.com"
    [" "]="https://stackoverflow.com"
    [" "]="https://youtube.com"
    ["󰣇 "]="https://wiki.archlinux.org"
    [" "]="https://wiki.hyprland.org"
    [" "]="https://search.nixos.org"
    ["󰈹 "]="https://developer.mozilla.org"
    [" "]="https://news.ycombinator.com"
    [" "]="https://kernel.org"
    [" "]="https://instagram.com"
    [" "]="https://x.com"

)

CHOICE=$(printf '%s\n' "${!BOOKMARKS[@]}" | sort | rofi -dmenu -i -p "󰃃" -theme "$STYLE") || exit 0
[[ -z "$CHOICE" ]] && exit 0

xdg-open "${BOOKMARKS[$CHOICE]}"
