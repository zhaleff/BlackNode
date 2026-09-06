#!/usr/bin/env bash

ICON="/tmp/blacknode-icons/whatnews.svg"
REMOTE_URL="https://raw.githubusercontent.com/zhaleff/BlackNode/main/whatnews.json"
SEEN_FILE="$HOME/.local/share/blacknode/whatsnew_seen"

mkdir -p "$(dirname "$SEEN_FILE")"
touch "$SEEN_FILE"

entries=$(curl -s "$REMOTE_URL")
[[ -z "$entries" ]] && exit 0

echo "$entries" | jq -c '.entries[]' | while read -r entry; do
    id=$(echo "$entry" | jq -r '.id')
    grep -qx "$id" "$SEEN_FILE" && continue

    title=$(echo "$entry" | jq -r '.title')
    body=$(echo "$entry" | jq -r '.body')

    notify-send -i "$ICON" "$title" "$body"
    echo "$id" >> "$SEEN_FILE"
done
