#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
INPUT_THEME="$R/styles/search-input.rasi"
LIST_THEME="$R/styles/search-list.rasi"

CHOICE=$(printf "󰇮 \n󰘥 \n󰊄 \n󰅐  " | rofi -dmenu -p "Search" -theme-str "listview { lines: 4; }" -theme "$MENU_THEME")

case "$CHOICE" in
    "󰇮 ")
        QUERY=$(rofi -dmenu -p "File name" -theme "$INPUT_THEME")
        [ -z "$QUERY" ] && exit
        local SAFE="${QUERY//[^a-zA-Z0-9 _.-]/}"
        RESULTS=$(find "$HOME" -maxdepth 4 -type f -not -path "*/.*" -iname "*$SAFE*" 2>/dev/null | head -50)
        [ -z "$RESULTS" ] && notify-send "Search" "No files found" && exit
        SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Results" -theme "$LIST_THEME")
        [ -n "$SELECTED" ] && xdg-open "$SELECTED"
        ;;
    "󰘥 ")
        QUERY=$(rofi -dmenu -p "Search web" -theme "$INPUT_THEME")
        [ -z "$QUERY" ] && exit
        local ENCODED
        ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${QUERY//\'/\\'}'))" 2>/dev/null || echo "${QUERY// /+}")
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    "󰊄 ")
        QUERY=$(rofi -dmenu -p "Text in files" -theme "$INPUT_THEME")
        [ -z "$QUERY" ] && exit
        local SAFE="${QUERY//[^a-zA-Z0-9 _.-]/}"
        RESULTS=$(grep -r -i -l "$SAFE" "$HOME" --include="*.{txt,md,conf,sh,py,js,ts,c,cpp,h,hpp,lua,json,toml,yaml,yml}" --exclude-dir=".*" 2>/dev/null | head -50)
        [ -z "$RESULTS" ] && notify-send "Search" "No matches found" && exit
        SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Results" -theme "$LIST_THEME")
        [ -n "$SELECTED" ] && xdg-open "$SELECTED"
        ;;
    "󰅐 ")
        RESULTS=$(find "$HOME" -maxdepth 4 -type f -not -path "*/.*" -mtime -7 2>/dev/null | head -50)
        [ -z "$RESULTS" ] && notify-send "Search" "No recent files" && exit
        SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Recent" -theme "$LIST_THEME")
        [ -n "$SELECTED" ] && xdg-open "$SELECTED"
        ;;
esac
