#!/bin/bash

PLAYER="spotify"
ART_PATH="/tmp/spotify_art.jpg"
FALLBACK_ART="/tmp/spotify_art_fallback.jpg"

status_raw=$(playerctl -p "$PLAYER" status 2>/dev/null)
if [[ "$status_raw" == "Playing" ]]; then
    icon='▷'
else
    icon=''
fi

title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
art_url=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)
position=$(playerctl -p "$PLAYER" position 2>/dev/null | cut -d. -f1)

if [[ -z "$title" ]]; then
    echo "  Nada sonando" > /tmp/spotify_text.txt
    echo "" > /tmp/spotify_lyric.txt
    if [[ -f "$FALLBACK_ART" ]]; then
        cp "$FALLBACK_ART" "$ART_PATH"
    fi
    exit 0
fi

if [[ "$art_url" == file://* ]]; then
    local_path="${art_url#file://}"
    cp "$local_path" "$ART_PATH" 2>/dev/null
elif [[ "$art_url" == http://* || "$art_url" == https://* ]]; then
    curl -s -o "$ART_PATH" "$art_url"
fi

current_lyric=""
if command -v curl >/dev/null && command -v jq >/dev/null; then
    encoded_title=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$title")
    encoded_artist=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$artist")
    lyrics_json=$(curl -s "https://lrclib.net/api/search?track_name=${encoded_title}&artist_name=${encoded_artist}")
    synced=$(echo "$lyrics_json" | jq -r '.[0].syncedLyrics // empty')

    if [[ -n "$synced" && -n "$position" ]]; then
        current_lyric=$(echo "$synced" | awk -v pos="$position" '
            match($0, /\[([0-9]+):([0-9]+)\.([0-9]+)\]/, m) {
                t = m[1]*60 + m[2] + m[3]/100
                line = substr($0, RSTART+RLENGTH)
                if (t <= pos) { last = line }
            }
            END { print last }
        ')
    fi

    if [[ -z "$current_lyric" ]]; then
        plain=$(echo "$lyrics_json" | jq -r '.[0].plainLyrics // empty')
        current_lyric=$(echo "$plain" | head -n 1)
    fi
fi

echo "${icon}  ${title}  —  ${artist}" > /tmp/spotify_text.txt
echo "${current_lyric}" > /tmp/spotify_lyric.txt
