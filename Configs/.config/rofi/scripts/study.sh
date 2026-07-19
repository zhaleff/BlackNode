#!/usr/bin/env bash
# Study profile command center — opens from the waybar rofi button while in Study profile.
# Provides quick access to research, notes, focus tools and knowledge sources.

THEME="$HOME/.config/rofi/styles/submenu.rasi"
NOTES_DIR="$HOME/BlackNode/Notes"

notify() { notify-send "Study" "$1"; }

open_url() { xdg-open "$1" & disown; }

new_note() {
    mkdir -p "$NOTES_DIR"
    TITLE=$(echo "" | rofi -dmenu -p "Note name" -theme "$HOME/.config/rofi/styles/notes-input.rasi")
    [[ -z "$TITLE" ]] && TITLE=$(date +'%Y-%m-%d-%H%M')
    kitty -e nvim "$NOTES_DIR/${TITLE// /-}.md" & disown
    notify "Created: ${TITLE// /-}.md"
}

open_notes() {
    kitty -e nvim "$NOTES_DIR" & disown
}

recent_files() {
    RESULTS=$(find "$HOME" -maxdepth 4 -type f -not -path "*/.*" -mtime -7 2>/dev/null | head -50)
    [[ -z "$RESULTS" ]] && notify "No recent files" && return
    SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Recent" -theme "$HOME/.config/rofi/styles/search-list.rasi")
    [[ -n "$SELECTED" ]] && xdg-open "$SELECTED" & disown
}

recent_docs() {
    RESULTS=$(find "$HOME" -maxdepth 5 -type f \( -iname "*.pdf" -o -iname "*.epub" \) -mtime -30 2>/dev/null | head -50)
    [[ -z "$RESULTS" ]] && notify "No recent documents" && return
    SELECTED=$(echo "$RESULTS" | rofi -dmenu -p "Documents" -theme "$HOME/.config/rofi/styles/search-list.rasi")
    [[ -n "$SELECTED" ]] && xdg-open "$SELECTED" & disown
}

wiki_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰈙  Random article" \
        "󰊄  Search Wikipedia" \
        "󰋼  Wikipedia ES" \
        "󰛩  Wiktionary" \
        "󰈔  Wikibooks" \
        | rofi -dmenu -i -p "Wikipedia" -theme "$THEME")
    case "$choice" in
        "󰈙  Random article") open_url "https://en.wikipedia.org/wiki/Special:Random" ;;
        "󰊄  Search Wikipedia")
            q=$(echo "" | rofi -dmenu -p "Search Wikipedia" -theme "$HOME/.config/rofi/styles/search-input.rasi")
            [[ -n "$q" ]] && open_url "https://en.wikipedia.org/w/index.php?search=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$q")" ;;
        "󰋼  Wikipedia ES") open_url "https://es.wikipedia.org/wiki/Portada" ;;
        "󰛩  Wiktionary") open_url "https://en.wiktionary.org/wiki/Main_Page" ;;
        "󰈔  Wikibooks") open_url "https://en.wikibooks.org/wiki/Main_Page" ;;
    esac
}

science_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰛩  arXiv" \
        "󰉖  Nature" \
        "󰊭  PubMed" \
        "󰌌  Springer" \
        "󰗀  NASA Science" \
        "󰇮  Khan Academy" \
        | rofi -dmenu -i -p "Direct Science" -theme "$THEME")
    case "$choice" in
        "󰛩  arXiv") open_url "https://arxiv.org/" ;;
        "󰉖  Nature") open_url "https://www.nature.com/" ;;
        "󰊭  PubMed") open_url "https://pubmed.ncbi.nlm.nih.gov/" ;;
        "󰌌  Springer") open_url "https://link.springer.com/" ;;
        "󰗀  NASA Science") open_url "https://science.nasa.gov/" ;;
        "󰇮  Khan Academy") open_url "https://www.khanacademy.org/" ;;
    esac
}

focus_mode() {
    if command -v dunstctl &>/dev/null; then
        dunstctl set-paused true
        notify "Focus mode ON — notifications paused"
    else
        notify "Focus mode — DND unavailable"
    fi
}

calendar_show() {
    if command -v khal &>/dev/null; then
        kitty -e khal calendar & disown
    else
        notify "$(date '+%A %d %B %Y')"
    fi
}

calculator() {
    local q
    q=$(echo "" | rofi -dmenu -p "Calc" -theme "$HOME/.config/rofi/styles/search-input.rasi")
    [[ -z "$q" ]] && return
    local res
    res=$(python3 -c "import sys; print(eval(sys.argv[1]))" "$q" 2>/dev/null)
    [[ -n "$res" ]] && notify "= $res" || notify "Invalid expression"
}

main_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰅴  New Note" \
        "󰋼  Open Notes" \
        "󰊄  Search" \
        "󰇮  Recent Files" \
        "󰈙  Open Documents" \
        "󰈙  Wikipedia" \
        "󰛩  Direct Science" \
        "  Pomodoro" \
        "󰸨  Browser" \
        "  Code / Terminal" \
        "󰊭  Calendar" \
        "󰉖  Dictionary" \
        "󰅧  Calculator" \
        "󰗀  Focus Mode" \
        "󰌌  Theme" \
        "󰋼  Help" \
        | rofi -dmenu -i -p " Study" -theme "$THEME")

    case "$choice" in
        "󰅴  New Note") new_note ;;
        "󰋼  Open Notes") open_notes ;;
        "󰊄  Search") "$HOME/.config/rofi/scripts/search.sh" ;;
        "󰇮  Recent Files") recent_files ;;
        "󰈙  Open Documents") recent_docs ;;
        "󰈙  Wikipedia") wiki_menu ;;
        "󰛩  Direct Science") science_menu ;;
        "  Pomodoro") "$HOME/.config/rofi/scripts/pomodoro.sh" ;;
        "󰸨  Browser") firefox & disown ;;
        "  Code / Terminal") kitty & disown ;;
        "󰊭  Calendar") calendar_show ;;
        "󰉖  Dictionary") open_url "https://en.wiktionary.org/wiki/Main_Page" ;;
        "󰅧  Calculator") calculator ;;
        "󰗀  Focus Mode") focus_mode ;;
        "󰌌  Theme") "$HOME/.config/rofi/scripts/themeselect.sh" ;;
        "󰋼  Help") notify "Study profile: notes, research, focus. Click modules in the bar for quick actions." ;;
    esac
}

main_menu
