#!/usr/bin/env bash

COVER_PATH="/tmp/blacknode-music-cover"

download_cover() {
    local url="$1"
    [[ -z "$url" ]] && return 1
    curl -s -L "$url" -o "$COVER_PATH" 2>/dev/null
}

notify_track() {
    local title artist art_url
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

    [[ -z "$title" ]] && return

    if download_cover "$art_url"; then
        notify-send -i "$COVER_PATH" "$title" "$artist"
    else
        notify-send "$title" "$artist"
    fi
}

playerctl --follow metadata --format '{{title}}' 2>/dev/null | while read -r _; do
    notify_track
done
