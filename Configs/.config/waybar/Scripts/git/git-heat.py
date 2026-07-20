#!/usr/bin/env python3
import json
import subprocess
import datetime as dt
from collections import Counter

DAYS = 7
REPO = subprocess.run(["bash", "-lc", "echo $HOME/BlackNode"],
                      capture_output=True, text=True).stdout.strip()

LEVELS = ["#21262d", "#0e4429", "#006d32", "#26a641", "#39d353"]
DOT = "\u25cf"


def level_for(count):
    if count <= 0:
        return 0
    if count == 1:
        return 1
    if count <= 3:
        return 2
    if count <= 6:
        return 3
    return 4


def gh_contribs(days):
    try:
        from datetime import date
        end = date.today()
        start = end - dt.timedelta(days=days)
        q = (
            "query($from:DateTime!, $to:DateTime!){"
            "  viewer{ contributionsCollection(from:$from, to:$to){"
            "    contributionCalendar{ weeks{ contributionDays{ date contributionCount } } } } } }"
        )
        out = subprocess.run(
            ["gh", "api", "graphql", "-f", f"query={q}",
             "-F", f"from={start.isoformat()}T00:00:00Z",
             "-F", f"to={end.isoformat()}T23:59:59Z"],
            capture_output=True, text=True, timeout=20)
        if out.returncode != 0:
            return None
        data = json.loads(out.stdout)
        coll = data["data"]["viewer"]["contributionsCollection"]
        days_map = {}
        for w in coll["contributionCalendar"]["weeks"]:
            for d in w["contributionDays"]:
                days_map[d["date"]] = d["contributionCount"]
        return days_map
    except Exception:
        return None


def local_contribs(days, repo):
    since = (dt.date.today() - dt.timedelta(days=days)).isoformat()
    try:
        out = subprocess.run(
            ["git", "-C", repo, "log", f"--since={since}",
             "--format=%ad", "--date=short"],
            capture_output=True, text=True, timeout=20)
    except Exception:
        return {}
    counts = Counter(out.stdout.split())
    return dict(counts)


def main():
    repo = REPO or ("/home/" + subprocess.run(["whoami"], capture_output=True, text=True).stdout.strip() + "/BlackNode")
    counts = gh_contribs(DAYS)
    source = "gh"
    if counts is None:
        counts = local_contribs(DAYS, repo)
        source = "local"

    today = dt.date.today()
    cells = []
    tip_lines = []
    total = 0
    for i in range(DAYS):
        d = today - dt.timedelta(days=(DAYS - 1 - i))
        c = counts.get(d.isoformat(), 0) or counts.get(d.strftime("%Y-%m-%d"), 0)
        total += c
        lvl = level_for(c)
        color = LEVELS[lvl]
        if d == today:
            cells.append(f'<span foreground="{color}" weight="bold" underline="single">\u25b3</span>')
            tip_lines.append(f"  TODAY ({d.strftime('%a %d %b')}): {c} commit(s)")
        else:
            cells.append(f'<span foreground="{color}">{DOT}</span>')
            if c:
                tip_lines.append(f"  {d.strftime('%a %d %b')}: {c} commit(s)")

    text = "".join(cells)
    tip = (f"Git contributions ({source}) — last week\n"
           f"Commits this week: {total}\n"
           f"Today: {counts.get(today.isoformat(),0)} commit(s)\n" + "\n".join(tip_lines[:7]))

    print(json.dumps({
        "text": text,
        "tooltip": tip,
        "class": "git-heat",
        "alt": "git-heat",
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
