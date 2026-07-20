#!/usr/bin/env python3
import json
import sys
import os
import subprocess
import datetime as dt

STATE_DIR = os.path.expanduser("~/.local/share/blacknode")
BEH = os.path.join(STATE_DIR, "behavior.json")
SCHEMA = os.path.join(STATE_DIR, "behavior.schema.json")
REPO_SCHEMA = os.path.expanduser(
    "~/BlackNode/Configs/.local/share/blacknode/behavior.schema.json"
)

NOISE_FLOOR = 0.02


def load():
    if not os.path.exists(BEH):
        src = SCHEMA if os.path.exists(SCHEMA) else (
            REPO_SCHEMA if os.path.exists(REPO_SCHEMA) else None)
        if src:
            import shutil
            shutil.copy(src, BEH)
        else:
            BEH_default = {
                "version": 1,
                "updated_at": "",
                "sessions": {"total": 0, "streak_days": 0,
                             "last_session_date": "", "avg_length_min": 0},
                "active_hours": {"late": 0, "dawn": 0, "morning": 0,
                                 "noon": 0, "afternoon": 0, "evening": 0, "night": 0},
                "focus_blocks": {"count": 0, "total_min": 0,
                                 "avg_min": 0, "longest_min": 0},
                "distraction": {"apps": {}, "after_focus_count": 0},
                "profile_usage": {"study": 0, "coding": 0, "music": 0,
                                  "astronomy": 0, "default": 0},
                "window_samples": {},
            }
            json.dump(BEH_default, open(BEH, "w"), indent=2)
    return json.load(open(BEH))


def save(b):
    b["sessions"]["updated_at"] = dt.datetime.now().isoformat(timespec="seconds")
    json.dump(b, open(BEH, "w"), indent=2)


def franja(h):
    h = int(h)
    if h <= 4:
        return "late"
    if h <= 7:
        return "dawn"
    if h <= 11:
        return "morning"
    if h <= 13:
        return "noon"
    if h <= 17:
        return "afternoon"
    if h <= 21:
        return "evening"
    return "night"


def session_start(b):
    today = dt.date.today().isoformat()
    last = b["sessions"]["last_session_date"]
    if last != today:
        yest = (dt.date.today() - dt.timedelta(days=1)).isoformat()
        b["sessions"]["streak_days"] = (
            b["sessions"]["streak_days"] + 1) if last == yest else 1
    b["sessions"]["total"] += 1
    b["sessions"]["last_session_date"] = today
    f = franja(dt.datetime.now().hour)
    b["active_hours"][f] = b["active_hours"].get(f, 0) + 1


def add_counter(b, section, key, amount=1):
    b[section][key] = b[section].get(key, 0) + amount


def filter_noise(b):
    total = sum(b["window_samples"].values())
    if total == 0:
        return
    for k in list(b["window_samples"].keys()):
        if b["window_samples"][k] / total < NOISE_FLOOR:
            del b["window_samples"][k]


def weekly_rollup(b):
    roll = b.get("rollup", {"weeks": []})
    snap = {
        "week": dt.date.today().isocalendar()[1],
        "active_hours": dict(b["active_hours"]),
        "focus_blocks": dict(b["focus_blocks"]),
        "profile_usage": dict(b["profile_usage"]),
        "window_samples": dict(b["window_samples"]),
    }
    roll["weeks"].append(snap)
    roll["weeks"] = roll["weeks"][-8:]
    b["rollup"] = roll
    for k in b["active_hours"]:
        b["active_hours"][k] = 0
    for k in b["profile_usage"]:
        b["profile_usage"][k] = 0
    b["window_samples"] = {}
    b["focus_blocks"] = {"count": 0, "total_min": 0,
                         "avg_min": 0, "longest_min": 0}


def maybe_rollup(b):
    today = dt.date.today()
    last = b.get("last_rollup")
    if last:
        last_d = dt.date.fromisoformat(last)
        if (today - last_d).days < 7:
            return
    b["last_rollup"] = today.isoformat()
    weekly_rollup(b)


def sample_loop():
    while True:
        out = subprocess.run(
            ["hyprctl", "activewindow", "-j"],
            capture_output=True, text=True, timeout=5
        ).stdout
        try:
            cls = json.loads(out).get("class", "unknown")
        except Exception:
            cls = "unknown"
        b = load()
        add_counter(b, "window_samples", cls)
        filter_noise(b)
        save(b)
        import time
        time.sleep(60)


def main():
    if len(sys.argv) < 2:
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "sample-loop":
        sample_loop()
        return
    b = load()
    if cmd == "session":
        session_start(b)
    elif cmd == "profile":
        add_counter(b, "profile_usage", sys.argv[2] if len(
            sys.argv) > 2 else "default")
    elif cmd == "focus":
        m = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        fb = b["focus_blocks"]
        fb["count"] += 1
        fb["total_min"] += m
        fb["avg_min"] = fb["total_min"] // fb["count"]
        fb["longest_min"] = max(fb["longest_min"], m)
    elif cmd == "sample":
        add_counter(b, "window_samples", sys.argv[2] if len(
            sys.argv) > 2 else "unknown")
        filter_noise(b)
    elif cmd == "distract":
        key = sys.argv[2] if len(sys.argv) > 2 else "unknown"
        b["distraction"]["apps"][key] = b["distraction"]["apps"].get(key, 0) + 1
    elif cmd == "rollup":
        maybe_rollup(b)
    save(b)


if __name__ == "__main__":
    main()
