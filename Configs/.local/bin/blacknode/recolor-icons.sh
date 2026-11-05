#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$HOME/.config/dunst/assets/src/system"
CACHE_DIR="/tmp/blacknode-icons"
MATUGEN_ICONS="$HOME/.cache/matugen/icons.json"
FALLBACK_FILL="#ffffff"
TOKEN="{{fill}}"

fill=$(jq -r '.on_surface // empty' "$MATUGEN_ICONS" 2>/dev/null || true)
[ -z "$fill" ] && fill="$FALLBACK_FILL"

# Build in a temporary tree so a failed run never leaves a half-written cache,
# and renamed/removed icons do not linger at their old paths.
tmp_dir=$(mktemp -d "${CACHE_DIR}.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT

find "$SRC_DIR" -type f -name '*.svg' -print0 | while IFS= read -r -d '' src; do
    relative="${src#"$SRC_DIR"/}"
    out="$tmp_dir/$relative"
    mkdir -p "$(dirname "$out")"
    sed "s/${TOKEN}/${fill}/g" "$src" > "$out"
done

rm -rf "$CACHE_DIR"
mv "$tmp_dir" "$CACHE_DIR"
trap - EXIT
