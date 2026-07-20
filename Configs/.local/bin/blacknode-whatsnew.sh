#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
SEEN="$STATE_DIR/seen_changelog.json"
CACHE="$STATE_DIR/changelog.cached.json"
RAW_URL="https://raw.githubusercontent.com/zhaleff/BlackNode/main/Configs/.local/share/blacknode/changelog.json"
REPO_LOCAL="$HOME/BlackNode/Configs/.local/share/blacknode/changelog.json"
THEME="$HOME/.config/rofi/styles/submenu.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"

SRC="$CACHE"
if curl -fsSL --max-time 8 "$RAW_URL" -o "$CACHE" 2>/dev/null && [[ -s "$CACHE" ]]; then
    SRC="$CACHE"
elif [[ -s "$REPO_LOCAL" ]]; then
    SRC="$REPO_LOCAL"
elif [[ -s "$CACHE" ]]; then
    SRC="$CACHE"
else
    notify-send -a "BlackNode" -u low "BlackNode" "No changelog available"
    exit 0
fi

mkdir -p "$STATE_DIR"
[[ -f "$SEEN" ]] || echo '{"seen":[]}' > "$SEEN"

if [[ "${1:-}" == "--ping" ]]; then
    unseen=$(python3 - "$SRC" "$SEEN" <<'PY'
import json, sys
src, seen = sys.argv[1], sys.argv[2]
entries = json.load(open(src)).get("entries", [])
seen_ids = set(json.load(open(seen)).get("seen", []))
print(len([e for e in entries if e["id"] not in seen_ids]))
PY
)
    if [[ "$unseen" -gt 0 ]]; then
        notify-send -a "BlackNode" -u low -i "dialog-information" "BlackNode" "You have $unseen update(s). Open What's New from the system menu."
    fi
    exit 0
fi

python3 - "$SRC" "$SEEN" "$THEME" <<'PY'
import json, sys, subprocess
src, seen, theme = sys.argv[1], sys.argv[2], sys.argv[3]
data = json.load(open(src))
entries = data.get("entries", [])
seen_ids = set(json.load(open(seen)).get("seen", []))

lines = []
for e in entries:
    mark = "  " if e["id"] in seen_ids else "● "
    sev = e.get("severity", "info").upper()
    lines.append(f"{mark}[{sev}] {e['title']}")

choice = subprocess.run(
    ["rofi", "-dmenu", "-i", "-p", " What's New", "-theme", theme],
    input="\n".join(lines), text=True, capture_output=True
).stdout.strip()

if not choice:
    sys.exit(0)

title = choice.split("] ", 1)[-1].strip()
entry = next((e for e in entries if e["title"] == title), None)
if not entry:
    sys.exit(0)

body = entry.get("body", "")
date = entry.get("date", "")
subprocess.run(["notify-send", "-a", "BlackNode", "-i", "dialog-information", f"BlackNode · {date}", f"{entry['title']}\n\n{body}"])

seen_ids.add(entry["id"])
json.dump({"seen": list(seen_ids)}, open(seen, "w"), indent=2)
PY
