#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"
PREV=""
trap "rm -f '${XDG_RUNTIME_DIR:-/tmp}/media-art-$$.jpg'" EXIT

while true; do
    STATUS=$(playerctl status 2>/dev/null)

    if [[ "$STATUS" == "Playing" ]]; then
        TITLE=$(playerctl metadata title 2>/dev/null)
        ARTIST=$(playerctl metadata artist 2>/dev/null)
        ART=$(playerctl metadata mpris:artUrl 2>/dev/null)
        KEY="$TITLE-$ARTIST"

        if [[ "$KEY" != "$PREV" ]]; then
            if [[ "$ART" == https://* ]]; then
                ICON="${XDG_RUNTIME_DIR:-/tmp}/media-art-$$.jpg"
                curl -sf --max-time 3 -o "$ICON" "$ART"
            elif [[ "$ART" == file://* ]]; then
                ICON="${ART#file://}"
            else
                ICON="$ASSETS/music-note.svg"
            fi

            dunstify -a "media" -i "$ICON" -t 5000 -r 2596 "$TITLE" "$ARTIST"
            PREV="$KEY"
        fi
    fi

    sleep 2
done
