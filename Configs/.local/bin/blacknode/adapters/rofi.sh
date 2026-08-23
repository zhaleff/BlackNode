#!/usr/bin/env bash
# Adapter: graphical presentation (rofi + dunst).
# Visual contract: same theme, same prompt behaviour as the legacy hub menu.

BN_ROFI_THEME="${BN_ROFI_THEME:-$HOME/.config/rofi/menu.rasi}"

bn_ui_select() {
    local prompt="${1:-}"
    rofi -dmenu -i -p "$prompt" -theme "$BN_ROFI_THEME"
}

bn_notify_impl() {
    notify-send "$1" "${2:-}"
}
