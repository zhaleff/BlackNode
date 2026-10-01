#!/usr/bin/env bash

COVER_PATH="/tmp/blacknode-music-cover"
MAX_TITLE=40
MAX_ARTIST=40

download_cover() {
    local url="$1"
    [[ -z "$url" ]] && return 1
    curl -s -L "$url" -o "$COVER_PATH" 2>/dev/null
}

truncate() {
    local text="$1" max="$2"
    (( ${#text} > max )) && text="${text:0:max-1}…"
    echo "$text"
}

notify_track() {
    local title artist art_url
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

    [[ -z "$title" ]] && return

    title=$(truncate "$title" "$MAX_TITLE")
    artist=$(truncate "$artist" "$MAX_ARTIST")

    if download_cover "$art_url"; then
        notify-send -i "$COVER_PATH" "$title" "$artist"
    else
        notify-send "$title" "$artist"
    fi
}

playerctl --follow metadata --format '{{title}}' 2>/dev/null | while read -r _; do
    notify_track
done
