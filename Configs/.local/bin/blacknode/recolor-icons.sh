#!/usr/bin/env bash

SRC_DIR="$HOME/.config/dunst/assets/src/system"
CACHE_DIR="/tmp/blacknode-icons"
MATUGEN_ICONS="$HOME/.cache/matugen/icons.json"
FALLBACK_FILL="#ffffff"
TOKEN="{{fill}}"

fill=$(jq -r '.on_surface // empty' "$MATUGEN_ICONS" 2>/dev/null)
[ -z "$fill" ] && fill="$FALLBACK_FILL"

find "$SRC_DIR" -type f -name '*.svg' | while read -r src; do
    relative="${src#"$SRC_DIR"/}"
    out="$CACHE_DIR/$relative"
    mkdir -p "$(dirname "$out")"
    sed "s/${TOKEN}/${fill}/g" "$src" > "$out"
done
