#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

declare -A bookmarks=(
    ["  YouTube"]="https://youtube.com"
    ["  GitHub"]="https://github.com"
    ["  Instagram"]="https://www.instagram.com"
    ["  WhatsApp"]="https://web.whatsapp.com"
    ["  LinkedIn"]="https://www.linkedin.com"
    ["󰑍  Reddit"]="https://www.reddit.com"
    ["󰊫  Gmail"]="https://mail.google.com"
    ["  Discord"]="https://discord.com"
    ["  Amazon"]="https://www.amazon.com"
    ["  Stack Overflow"]="https://stackoverflow.com"

    ["  Claude"]="https://claude.ai"
    ["  ChatGPT"]="https://chatgpt.com"
    ["  Telegram"]="https://web.telegram.org"
    ["  Spotify"]="https://open.spotify.com"
    ["  Firefox"]="https://www.mozilla.org/en-US/firefox/new/"
    ["  Google"]="https://www.google.com"
    ["󰕄  X (Twitter)"]="https://x.com"
)

bookmarks_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "${!bookmarks[@]}" \
        | rofi -dmenu -theme "$THEME" -p "Bookmarks")

    case "$choice" in
        *"Back") exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        "")      exit 0 ;;
        *)       xdg-open "${bookmarks[$choice]}" ;;
    esac
}

bookmarks_menu
