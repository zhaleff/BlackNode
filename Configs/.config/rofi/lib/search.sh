#!/usr/bin/env bash

find_recent() {
    find "$HOME" -maxdepth 4 -type f -not -path "*/.*" -mtime "${1:--7}" 2>/dev/null | head -50
}

grep_text() {
    local q="$1"
    shift
    local inc=()
    for ext in txt md conf sh py js ts c cpp h hpp lua json toml yaml yml; do
        inc+=(--include="*.$ext")
    done
    grep -r -i -l "$q" "$HOME" "${inc[@]}" --exclude-dir=".*" "$@" 2>/dev/null | head -50
}
