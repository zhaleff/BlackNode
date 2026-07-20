#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
BEH="$STATE_DIR/behavior.json"
THEME="$HOME/.config/rofi/styles/submenu.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"

[[ -f "$BEH" ]] || { notify-send -a "BlackNode" "BlackNode" "No behavior data yet"; exit 0; }

python3 - "$BEH" "$THEME" "$LIST" <<'PY'
import json, sys, subprocess
b = json.load(open(sys.argv[1]))
theme, lst = sys.argv[2], sys.argv[3]
s = b["sessions"]
ah = b["active_hours"]
fb = b["focus_blocks"]
pu = b["profile_usage"]
dis = b["distraction"]["apps"]
ws = b["window_samples"]

top_hour = max(ah, key=lambda k: ah[k])
top_profile = max(pu, key=lambda k: pu[k])
top_app = max(ws, key=lambda k: ws[k]) if ws else "none"
top_dist = max(dis, key=lambda k: dis[k]) if dis else "none"

lines = []
lines.append(f"Streak: {s['streak_days']} day(s)   ·   Sessions: {s['total']}")
lines.append(f"Most active: {top_hour}")
lines.append(f"Avg focus block: {fb['avg_min']} min   ·   Longest: {fb['longest_min']} min   ·   Blocks: {fb['count']}")
lines.append(f"Top profile: {top_profile} ({pu[top_profile]} uses)")
lines.append(f"Top window: {top_app}")
lines.append(f"Top distraction: {top_dist}")

out = subprocess.run(
    ["rofi", "-dmenu", "-i", "-p", " Your Patterns", "-theme", theme],
    input="\n".join(lines), text=True, capture_output=True
).stdout.strip()

if out:
    detail = {
        "active_hours": ah,
        "focus_blocks": fb,
        "profile_usage": pu,
        "distraction_apps": dis,
        "window_samples": ws,
    }
    txt = json.dumps(detail, indent=2)
    subprocess.run(["rofi", "-dmenu", "-i", "-p", " Details", "-theme", lst, "-l", "20"], input=txt, text=True)
PY
