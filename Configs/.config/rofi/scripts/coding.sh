#!/usr/bin/env bash
# Coding profile — each waybar group calls coding.sh <group> to open its own submenu/action.

THEME="$HOME/.config/rofi/styles/submenu.rasi"
INPUT="$HOME/.config/rofi/styles/search-input.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"
NOTES_DIR="$HOME/BlackNode/Notes"

notify() { notify-send "Coding" "$1"; }
open_url() { xdg-open "$1" & disown; }
urlq() { python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$1"; }

# ---------- documentation hub ----------
menu_docs() {
    choice=$(printf '%s\n' \
        "󰛳  DevDocs (all-in-one)" \
        "󰛳  MDN Web Docs" \
        "󰛳  Rust Docs" \
        "󰛳  Python Docs" \
        "󰛳  Go Docs" \
        "󰛳  TypeScript Docs" \
        "󰛳  DevHints (cheat sheets)" \
        "󰛳  Cite HR (man pages)" | rofi -dmenu -i -p " Docs" -theme "$THEME")
    case "$choice" in
        "󰛳  DevDocs (all-in-one)") open_url "https://devdocs.io/" ;;
        "󰛳  MDN Web Docs") open_url "https://developer.mozilla.org/" ;;
        "󰛳  Rust Docs") open_url "https://doc.rust-lang.org/std/" ;;
        "󰛳  Python Docs") open_url "https://docs.python.org/3/" ;;
        "󰛳  Go Docs") open_url "https://go.dev/doc/" ;;
        "󰛳  TypeScript Docs") open_url "https://www.typescriptlang.org/docs/" ;;
        "󰛳  DevHints (cheat sheets)") open_url "https://devhints.io/" ;;
        "󰛳  Cite HR (man pages)") kitty -e man bash & disown ;;
    esac
}

# ---------- roadmap.sh ----------
menu_roadmap() {
    choice=$(printf '%s\n' \
        "󰹇  Frontend Developer" \
        "󰹇  Backend Developer" \
        "󰹇  Fullstack Engineer" \
        "󰹇  DevOps Engineer" \
        "󰹇  React" \
        "󰹇  Node.js" \
        "󰹇  Python" \
        "󰹇  Go" \
        "󰹇  Rust" \
        "󰹇  Blockchain" \
        "󰹇  Cyber Security" \
        "󰹇  All roadmaps" | rofi -dmenu -i -p " Roadmap" -theme "$THEME")
    case "$choice" in
        "󰹇  Frontend Developer") open_url "https://roadmap.sh/frontend" ;;
        "󰹇  Backend Developer") open_url "https://roadmap.sh/backend" ;;
        "󰹇  Fullstack Engineer") open_url "https://roadmap.sh/full-stack" ;;
        "󰹇  DevOps Engineer") open_url "https://roadmap.sh/devops" ;;
        "󰹇  React") open_url "https://roadmap.sh/react" ;;
        "󰹇  Node.js") open_url "https://roadmap.sh/nodejs" ;;
        "󰹇  Python") open_url "https://roadmap.sh/python" ;;
        "󰹇  Go") open_url "https://roadmap.sh/golang" ;;
        "󰹇  Rust") open_url "https://roadmap.sh/rust" ;;
        "󰹇  Blockchain") open_url "https://roadmap.sh/blockchain" ;;
        "󰹇  Cyber Security") open_url "https://roadmap.sh/cyber-security" ;;
        "󰹇  All roadmaps") open_url "https://roadmap.sh/" ;;
    esac
}

# ---------- language references ----------
menu_lang() {
    choice=$(printf '%s\n' \
        "󰆧  Python — docs + REPL" \
        "󰆧  Rust — book + std" \
        "󰆧  Go — tour + pkg" \
        "󰆧  JavaScript / TS" \
        "󰆧  C / C++ — cppreference" \
        "󰆧  Bash — guide" | rofi -dmenu -i -p " Lang" -theme "$THEME")
    case "$choice" in
        "󰆧  Python — docs + REPL") open_url "https://docs.python.org/3/" ;;
        "󰆧  Rust — book + std") open_url "https://doc.rust-lang.org/book/" ;;
        "󰆧  Go — tour + pkg") open_url "https://go.dev/tour/" ;;
        "󰆧  JavaScript / TS") open_url "https://developer.mozilla.org/en-US/docs/Web/JavaScript" ;;
        "󰆧  C / C++ — cppreference") open_url "https://en.cppreference.com/" ;;
        "󰆧  Bash — guide") open_url "https://mywiki.wooledge.org/BashGuide" ;;
    esac
}

# ---------- version control ----------
menu_git() {
    choice=$(printf '%s\n' \
        "󰊢  lazygit (TUI)" \
        "󰊢  Git status" \
        "󰊢  Git log (graph)" \
        "󰊢  GitHub" \
        "󰊢  GitLab" \
        "󰊢  Cheat sheet" | rofi -dmenu -i -p " Git" -theme "$THEME")
    case "$choice" in
        "󰊢  lazygit (TUI)") kitty -e lazygit & disown ;;
        "󰊢  Git status") kitty -e bash -c "git -C \$HOME/BlackNode status; exec bash" & disown ;;
        "󰊢  Git log (graph)") kitty -e bash -c "git -C \$HOME/BlackNode log --oneline --graph --decorate -15; exec bash" & disown ;;
        "󰊢  GitHub") open_url "https://github.com/" ;;
        "󰊢  GitLab") open_url "https://gitlab.com/" ;;
        "󰊢  Cheat sheet") open_url "https://training.github.com/downloads/github-git-cheat-sheet/" ;;
    esac
}

# ---------- dev tools ----------
menu_tools() {
    choice=$(printf '%s\n' \
        "󰓲  Docker Desktop" \
        "󰓲  Docker Hub" \
        "󰓲  Postman (API)" \
        "󰓲  regex101" \
        "󰓲  JSON Formatter" \
        "󰓲  Can I Use (web features)" \
        "󰓲  Excalidraw (diagrams)" \
        "󰓲  localhost.run (tunnel)" | rofi -dmenu -i -p " Tools" -theme "$THEME")
    case "$choice" in
        "󰓲  Docker Desktop") (command -v docker-desktop >/dev/null && docker-desktop || open_url "https://www.docker.com/products/docker-desktop/") & disown ;;
        "󰓲  Docker Hub") open_url "https://hub.docker.com/" ;;
        "󰓲  Postman (API)") open_url "https://www.postman.com/" ;;
        "󰓲  regex101") open_url "https://regex101.com/" ;;
        "󰓲  JSON Formatter") open_url "https://jsonformatter.org/" ;;
        "󰓲  Can I Use (web features)") open_url "https://caniuse.com/" ;;
        "󰓲  Excalidraw (diagrams)") open_url "https://excalidraw.com/" ;;
        "󰓲  localhost.run (tunnel)") open_url "https://localhost.run/" ;;
    esac
}

# ---------- AI assistants ----------
menu_ai() {
    choice=$(printf '%s\n' \
        "󰤭  Claude" \
        "󰤭  ChatGPT" \
        "󰤭  GitHub Copilot" \
        "󰤭  Perplexity" \
        "󰤭  Phind (dev search)" | rofi -dmenu -i -p " AI" -theme "$THEME")
    case "$choice" in
        "󰤭  Claude") open_url "https://claude.ai/" ;;
        "󰤭  ChatGPT") open_url "https://chat.openai.com/" ;;
        "󰤭  GitHub Copilot") open_url "https://github.com/features/copilot" ;;
        "󰤭  Perplexity") open_url "https://www.perplexity.ai/" ;;
        "󰤭  Phind (dev search)") open_url "https://www.phind.com/" ;;
    esac
}

# ---------- Q&A / search ----------
menu_stack() {
    choice=$(printf '%s\n' \
        "󰆄  Stack Overflow" \
        "󰆄  Dev.to" \
        "󰆄  Reddit r/programming" \
        "󰆄  Search the web" \
        "󰆄  Search code (GitHub)" | rofi -dmenu -i -p " Q&A" -theme "$THEME")
    case "$choice" in
        "󰆄  Stack Overflow") open_url "https://stackoverflow.com/" ;;
        "󰆄  Dev.to") open_url "https://dev.to/" ;;
        "󰆄  Reddit r/programming") open_url "https://www.reddit.com/r/programming/" ;;
        "󰆄  Search the web") { q=$(echo "" | rofi -dmenu -p " Search" -theme "$INPUT"); [[ -n "$q" ]] && open_url "https://www.google.com/search?q=$(urlq "$q")"; } ;;
        "󰆄  Search code (GitHub)") { q=$(echo "" | rofi -dmenu -p " GitHub code" -theme "$INPUT"); [[ -n "$q" ]] && open_url "https://github.com/search?q=$(urlq "$q")&type=code"; } ;;
    esac
}

calendar_show() {
    if command -v khal &>/dev/null; then kitty -e khal calendar & disown
    else notify "$(date '+%A %d %B %Y')"; fi
}

# ---------- dispatcher ----------
case "${1:-}" in
    docs) menu_docs ;;
    roadmap) menu_roadmap ;;
    lang) menu_lang ;;
    git) menu_git ;;
    tools) menu_tools ;;
    ai) menu_ai ;;
    stack) menu_stack ;;
    calendar) calendar_show ;;
esac
