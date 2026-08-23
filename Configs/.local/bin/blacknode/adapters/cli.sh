#!/usr/bin/env bash
# Adapter: text presentation (fzf interactive / numbered fallback).
# Same ports as rofi.sh — proves the UI is swappable without touching core.
# Used for debugging, SSH sessions and automated tests (see BN_CLI_CHOICE).

bn_ui_select() {
    local -a opts=()
    mapfile -t opts
    ((${#opts[@]} > 0)) || return 0

    if [[ -n "${BN_CLI_CHOICE:-}" ]]; then          # deterministic mode (tests)
        printf '%s\n' "$BN_CLI_CHOICE"
        return 0
    fi

    if command -v fzf >/dev/null 2>&1 && [[ -t 2 ]]; then
        printf '%s\n' "${opts[@]}" | \
            fzf --height=~40% --reverse --prompt="blacknode ❯ "
        return 0
    fi

    local i=1 line reply=""
    for line in "${opts[@]}"; do printf '%3d) %s\n' "$i" "$line"; i=$((i+1)); done
    printf 'blacknode ❯ ' >&2
    { read -r reply </dev/tty 2>/dev/null; } || read -r reply || true
    if [[ "$reply" =~ ^[0-9]+$ ]] && (( reply >= 1 && reply <= ${#opts[@]} )); then
        printf '%s\n' "${opts[reply-1]}"
        return 0
    fi
    for line in "${opts[@]}"; do
        [[ "$line" == "$reply" ]] && { printf '%s\n' "$line"; return 0; }
    done
    return 0
}

bn_notify_impl() {
    printf '[%s] %s\n' "$1" "${2:-}" >&2
}
