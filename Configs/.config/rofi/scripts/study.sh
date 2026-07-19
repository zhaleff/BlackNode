#!/usr/bin/env bash
# Study profile command center — hierarchical rofi.
# Top level shows GROUPS; each group opens its own submenu of actions.

THEME="$HOME/.config/rofi/styles/submenu.rasi"
INPUT="$HOME/.config/rofi/styles/search-input.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"
NOTES_DIR="$HOME/BlackNode/Notes"

notify() { notify-send "Study" "$1"; }
open_url() { xdg-open "$1" & disown; }

# ---------- action helpers ----------
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
    choice=$(printf '%s\n' \
        "󰅴  New Note" \
        "󰋼  Open Notes" \
        "󰈔  Browse Folder" \
        | rofi -dmenu -i -p " Notes" -theme "$THEME")
    case "$choice" in
        "󰅴  New Note") new_note ;;
        "󰋼  Open Notes") open_notes ;;
        "󰈔  Browse Folder") xdg-open "$NOTES_DIR" & disown ;;
    esac
}
menu_research() {
    choice=$(printf '%s\n' \
        "󰈙  Wikipedia Random" \
        "󰊄  Wikipedia Search" \
        "󰋼  Wikipedia ES" \
        "󰛩  Wiktionary" \
        "󰈔  Wikibooks" \
        "󰊄  Web Search" \
        | rofi -dmenu -i -p " Research" -theme "$THEME")
    case "$choice" in
        "󰈙  Wikipedia Random") open_url "https://en.wikipedia.org/wiki/Special:Random" ;;
        "󰊄  Wikipedia Search") wiki_search ;;
        "󰋼  Wikipedia ES") open_url "https://es.wikipedia.org/wiki/Portada" ;;
        "󰛩  Wiktionary") open_url "https://en.wiktionary.org/wiki/Main_Page" ;;
        "󰈔  Wikibooks") open_url "https://en.wikibooks.org/wiki/Main_Page" ;;
        "󰊄  Web Search") "$HOME/.config/rofi/scripts/search.sh" ;;
    esac
}
menu_science() {
    choice=$(printf '%s\n' \
        "󰛩  arXiv" \
        "󰉖  Nature" \
        "󰊭  PubMed" \
        "󰌌  Springer" \
        "󰗀  NASA Science" \
        "󰇮  Khan Academy" \
        | rofi -dmenu -i -p " Science" -theme "$THEME")
    case "$choice" in
        "󰛩  arXiv") open_url "https://arxiv.org/" ;;
        "󰉖  Nature") open_url "https://www.nature.com/" ;;
        "󰊭  PubMed") open_url "https://pubmed.ncbi.nlm.nih.gov/" ;;
        "󰌌  Springer") open_url "https://link.springer.com/" ;;
        "󰗀  NASA Science") open_url "https://science.nasa.gov/" ;;
        "󰇮  Khan Academy") open_url "https://www.khanacademy.org/" ;;
    esac
}
menu_docs() {
    choice=$(printf '%s\n' \
        "󰇮  Recent Files" \
        "󰈙  Open Documents" \
        | rofi -dmenu -i -p " Documents" -theme "$THEME")
    case "$choice" in
        "󰇮  Recent Files") recent_files ;;
        "󰈙  Open Documents") recent_docs ;;
    esac
}
menu_tools() {
    choice=$(printf '%s\n' \
        "  Pomodoro" \
        "󰅧  Calculator" \
        "󰉖  Dictionary" \
        "󰊭  Calendar" \
        | rofi -dmenu -i -p " Tools" -theme "$THEME")
    case "$choice" in
        "  Pomodoro") "$HOME/.config/rofi/scripts/pomodoro.sh" ;;
        "󰅧  Calculator") calc ;;
        "󰉖  Dictionary") open_url "https://en.wiktionary.org/wiki/Main_Page" ;;
        "󰊭  Calendar") calendar_show ;;
    esac
}
menu_env() {
    choice=$(printf '%s\n' \
        "󰸨  Browser" \
        "  Code / Terminal" \
        "󰗀  Focus Mode" \
        "󰌌  Theme" \
        | rofi -dmenu -i -p " Environment" -theme "$THEME")
    case "$choice" in
        "󰸨  Browser") firefox & disown ;;
        "  Code / Terminal") kitty & disown ;;
        "󰗀  Focus Mode") focus_mode ;;
        "󰌌  Theme") "$HOME/.config/rofi/scripts/themeselect.sh" ;;
    esac
}

# ---------- dispatcher (each waybar group calls study.sh <group>) ----------
case "${1:-}" in
    notes) menu_notes ;;
    docs) menu_docs ;;
    research) menu_research ;;
    science) menu_science ;;
    tools) menu_tools ;;
    env) menu_env ;;
    *) main_menu ;;
esac
