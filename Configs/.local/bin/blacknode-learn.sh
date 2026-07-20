#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
BEH="$STATE_DIR/behavior.json"
SCHEMA="$STATE_DIR/behavior.schema.json"
REPO_SCHEMA="$HOME/BlackNode/Configs/.local/share/blacknode/behavior.schema.json"
ACTIVE_FILE="$STATE_DIR/active_profile"

hour_franja() {
    local h="$1"
    if [[ "$h" -ge 0 && "$h" -le 4 ]]; then echo late
    elif [[ "$h" -le 7 ]]; then echo dawn
    elif [[ "$h" -le 11 ]]; then echo morning
    elif [[ "$h" -le 13 ]]; then echo noon
    elif [[ "$h" -le 17 ]]; then echo afternoon
    elif [[ "$h" -le 21 ]]; then echo evening
    else echo night
    fi
}

ensure() {
    mkdir -p "$STATE_DIR"
    if [[ ! -f "$BEH" ]]; then
        if [[ -f "$SCHEMA" ]]; then
            cp "$SCHEMA" "$BEH"
        elif [[ -f "$REPO_SCHEMA" ]]; then
            cp "$REPO_SCHEMA" "$BEH"
        else
            cp /dev/stdin "$BEH" <<'JSON'
{
  "version": 1,
  "updated_at": "",
  "sessions": {"total": 0, "streak_days": 0, "last_session_date": "", "avg_length_min": 0},
  "active_hours": {"late": 0, "dawn": 0, "morning": 0, "noon": 0, "afternoon": 0, "evening": 0, "night": 0},
  "focus_blocks": {"count": 0, "total_min": 0, "avg_min": 0, "longest_min": 0},
  "distraction": {"apps": {}, "after_focus_count": 0},
  "profile_usage": {"study": 0, "coding": 0, "music": 0, "astronomy": 0, "default": 0},
  "window_samples": {}
}
JSON
        fi
    fi
}

session_start() {
    ensure
    local f
    f="$(hour_franja "$(date +%H)")"
    python3 - "$BEH" "$f" <<'PY'
import json, sys, datetime
p, f = sys.argv[1], sys.argv[2]
b = json.load(open(p))
today = datetime.date.today().isoformat()
last = b["sessions"]["last_session_date"]
if last != today:
    yest = (datetime.date.today() - datetime.timedelta(days=1)).isoformat()
    b["sessions"]["streak_days"] = (b["sessions"]["streak_days"] + 1) if last == yest else 1
b["sessions"]["total"] += 1
b["sessions"]["last_session_date"] = today
b["active_hours"][f] = b["active_hours"].get(f, 0) + 1
b["sessions"]["updated_at"] = datetime.datetime.now().isoformat(timespec="seconds")
json.dump(b, open(p, "w"), indent=2)
PY
}

profile_use() {
    ensure
    local prof="${1:-default}"
    python3 - "$BEH" "$prof" <<'PY'
import json, sys, datetime
p, prof = sys.argv[1], sys.argv[2]
b = json.load(open(p))
b["profile_usage"][prof] = b["profile_usage"].get(prof, 0) + 1
b["sessions"]["updated_at"] = datetime.datetime.now().isoformat(timespec="seconds")
json.dump(b, open(p, "w"), indent=2)
PY
}

focus_block() {
    ensure
    local min="${1:-0}"
    python3 - "$BEH" "$min" <<'PY'
import json, sys, datetime
p, m = sys.argv[1], int(sys.argv[2])
b = json.load(open(p))
fb = b["focus_blocks"]
fb["count"] += 1
fb["total_min"] += m
fb["avg_min"] = fb["total_min"] // fb["count"]
fb["longest_min"] = max(fb["longest_min"], m)
b["sessions"]["updated_at"] = datetime.datetime.now().isoformat(timespec="seconds")
json.dump(b, open(p, "w"), indent=2)
PY
}

distraction() {
    ensure
    local app="${1:-unknown}"
    python3 - "$BEH" "$app" <<'PY'
import json, sys, datetime
p, app = sys.argv[1], sys.argv[2]
b = json.load(open(p))
b["distraction"]["apps"][app] = b["distraction"]["apps"].get(app, 0) + 1
b["sessions"]["updated_at"] = datetime.datetime.now().isoformat(timespec="seconds")
json.dump(b, open(p, "w"), indent=2)
PY
}

sample_window() {
    ensure
    local cls="${1:-unknown}"
    python3 - "$BEH" "$cls" <<'PY'
import json, sys, datetime
p, cls = sys.argv[1], sys.argv[2]
b = json.load(open(p))
b["window_samples"][cls] = b["window_samples"].get(cls, 0) + 1
b["sessions"]["updated_at"] = datetime.datetime.now().isoformat(timespec="seconds")
json.dump(b, open(p, "w"), indent=2)
PY
}

case "${1:-}" in
    session)   session_start ;;
    profile)   profile_use "${2:-default}" ;;
    focus)     focus_block "${2:-0}" ;;
    distract)  distraction "${2:-unknown}" ;;
    sample)    sample_window "${2:-unknown}" ;;
    sample-loop)
        while true; do
            cls="$(hyprctl activewindow -j 2>/dev/null | python3 -c "import json,sys;print(json.load(sys.stdin).get('class','unknown'))" 2>/dev/null || echo unknown)"
            ~/.local/bin/blacknode-learn.sh sample "$cls"
            sleep 60
        done
        ;;
esac
