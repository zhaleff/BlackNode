#!/usr/bin/env bash
# Study profile — each waybar group calls study.sh <group> to open its own submenu/action.

THEME="$HOME/.config/rofi/styles/submenu.rasi"
INPUT="$HOME/.config/rofi/styles/search-input.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"
NOTES_DIR="$HOME/BlackNode/Notes"

notify() { notify-send "Study" "$1"; }
open_url() { xdg-open "$1" & disown; }

# ---------- actions ----------
new_note() {
    mkdir -p "$NOTES_DIR"
    TITLE=$(echo "" | rofi -dmenu -p "Note name" -theme "$INPUT")
    [[ -z "$TITLE" ]] && TITLE=$(date +'%Y-%m-%d-%H%M')
    kitty -e nvim "$NOTES_DIR/${TITLE// /-}.md" & disown
    notify "Created: ${TITLE// /-}.md"
}
open_notes() { kitty -e nvim "$NOTES_DIR" & disown; }
recent_files() {
    RESULTS=$(find "$HOME" -maxdepth 4 -type f -not -path "*/.*" -mtime -7 2>/dev/null | head -50)
    [[ -z "$RESULTS" ]] && notify "No recent files" && return
    SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Recent" -theme "$LIST")
    [[ -n "$SELECTED" ]] && xdg-open "$SELECTED" & disown
}
recent_docs() {
    RESULTS=$(find "$HOME" -maxdepth 5 -type f \( -iname "*.pdf" -o -iname "*.epub" \) -mtime -30 2>/dev/null | head -50)
    [[ -z "$RESULTS" ]] && notify "No recent documents" && return
    SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Documents" -theme "$LIST")
    [[ -n "$SELECTED" ]] && xdg-open "$SELECTED" & disown
}
wiki_search() {
    q=$(echo "" | rofi -dmenu -p "Search Wikipedia" -theme "$INPUT")
    [[ -n "$q" ]] && open_url "https://en.wikipedia.org/w/index.php?search=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")"
}
web_search() {
    q=$(echo "" | rofi -dmenu -p "Search web" -theme "$INPUT")
    [[ -n "$q" ]] && open_url "https://www.google.com/search?q=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")"
}
text_search() {
    q=$(echo "" | rofi -dmenu -p "Text in files" -theme "$INPUT")
    [[ -z "$q" ]] && return
    RESULTS=$(grep -r -i -l "$q" "$HOME" --include="*.{txt,md,conf,sh,py,js,ts,c,cpp,h,lua,json,toml,yaml,yml}" --exclude-dir=".*" 2>/dev/null | head -50)
    [[ -z "$RESULTS" ]] && notify "No matches" && return
    SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Results" -theme "$LIST")
    [[ -n "$SELECTED" ]] && xdg-open "$SELECTED" & disown
}
calc() {
    q=$(echo "" | rofi -dmenu -p "Calc" -theme "$INPUT")
    [[ -z "$q" ]] && return
    res=$(python3 -c "import sys; print(eval(sys.argv[1]))" "$q" 2>/dev/null)
    [[ -n "$res" ]] && notify "= $res" || notify "Invalid expression"
}
calendar_show() {
    if command -v khal &>/dev/null; then kitty -e khal calendar & disown
    else notify "$(date '+%A %d %B %Y')"; fi
}
focus_mode() {
    if command -v dunstctl &>/dev/null; then dunstctl set-paused true; notify "Focus mode ON — notifications paused"
    else notify "Focus mode — DND unavailable"; fi
}

# ---------- submenus (one rofi each) ----------
menu_notes() {
    choice=$(printf '%s\n' "󰅴  New Note" "󰋼  Open Notes" "󰈔  Browse Folder" | rofi -dmenu -i -p " Notes" -theme "$THEME")
    case "$choice" in
        "󰅴  New Note") new_note ;; "󰋼  Open Notes") open_notes ;; "󰈔  Browse Folder") xdg-open "$NOTES_DIR" & disown ;;
    esac
}
menu_docs() {
    choice=$(printf '%s\n' "󰇮  Recent Files" "󰈙  Open Documents" | rofi -dmenu -i -p " Documents" -theme "$THEME")
    case "$choice" in
        "󰇮  Recent Files") recent_files ;; "󰈙  Open Documents") recent_docs ;;
    esac
}
menu_wiki() {
    choice=$(printf '%s\n' "󰈙  Random article" "󰊄  Search Wikipedia" "󰋼  Wikipedia ES" | rofi -dmenu -i -p " Wikipedia" -theme "$THEME")
    case "$choice" in
        "󰈙  Random article") open_url "https://en.wikipedia.org/wiki/Special:Random" ;;
        "󰊄  Search Wikipedia") wiki_search ;;
        "󰋼  Wikipedia ES") open_url "https://es.wikipedia.org/wiki/Portada" ;;
    esac
}
menu_search() {
    choice=$(printf '%s\n' "󰇮  Recent Files" "󰊄  Web Search" "󰊄  Text in Files" | rofi -dmenu -i -p " Search" -theme "$THEME")
    case "$choice" in
        "󰇮  Recent Files") recent_files ;;
        "󰊄  Web Search") web_search ;;
        "󰊄  Text in Files") text_search ;;
    esac
}

# ---------- dispatcher ----------
case "${1:-}" in
    notes) menu_notes ;;
    docs) menu_docs ;;
    wiki) menu_wiki ;;
    search) menu_search ;;
    calc) calc ;;
    calendar) calendar_show ;;
    focus) focus_mode ;;
esac
