#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
INPUT_THEME="$R/styles/notes-input.rasi"
LIST_THEME="$R/styles/notes-list.rasi"
DIR="$HOME/BlackNode/Notes"
mkdir -p "$DIR"

CHOICE=$(printf "󰅴 \n󰋼 \n󰋁 " | rofi -dmenu -p "Notes" -theme-str "listview { lines: 3; }" -theme "$MENU_THEME")

case "$CHOICE" in
        "󰅴 ")
        TITLE=$(rofi -dmenu -p "Note name" -theme "$INPUT_THEME")
        [ -z "$TITLE" ] && TITLE=$(date +'%Y-%m-%d-%H%M')
        kitty -e nvim "$DIR/${TITLE// /-}.md"
        notify-send "Notes" "Created: ${TITLE// /-}.md"
        ;;
    "󰋼 ")
        files=("$DIR"/*.md)
        [ ! -e "${files[0]}" ] && notify-send "Notes" "No notes yet" && exit
        LIST=""
        while IFS= read -r f; do
            NAME=$(basename "$f" .md)
            DATE=$(date -r "$f" +'%Y-%m-%d')
            LIST="${LIST}󰈔 $DATE  $NAME\n"
        done < <(ls -t "$DIR"/*.md)
        SELECTED=$(printf '%b' "$LIST" | rofi -dmenu -p "Notes" -theme "$LIST_THEME")
        [ -z "$SELECTED" ] && exit
        FILE=$(echo "$SELECTED" | sed 's/^󰈔 [0-9-]*  //' | sed 's/^[[:space:]]*//')
        TARGET=$(find "$DIR" -name "${FILE}.md" | head -1)
        [ -n "$TARGET" ] && kitty -e nvim "$TARGET"
        ;;
    "󰋁 ")
        kitty -e nvim "$DIR"
        ;;
esac
