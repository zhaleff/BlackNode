#!/usr/bin/env python3
import json, os, subprocess, sys
from datetime import date

cache = os.path.expanduser("~/.cache/waybar-astro")
os.makedirs(cache, exist_ok=True)
url_file = os.path.join(cache, "astro_event_url")

if len(sys.argv) > 1 and sys.argv[1] == "--open":
    try:
        with open(url_file) as f:
            subprocess.Popen(["xdg-open", f.read().strip()], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        subprocess.Popen(["xdg-open", "https://www.timeanddate.com/astronomy/"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

today = date.today()
year = today.year
events = []

for y in [year - 1, year, year + 1]:
    for m in [3, 6, 9, 12]:
        d = date(y, m, 20)
        events.append((d, "Equinox/Solstice", "https://www.timeanddate.com/calendar/seasons.html"))
    for m, d, name, link in [
        (1, 3, "Quadrantids", "https://www.timeanddate.com/astronomy/meteor-shower/quadrantids.html"),
        (4, 22, "Lyrids", "https://www.timeanddate.com/astronomy/meteor-shower/lyrids.html"),
        (5, 5, "Eta Aquariids", "https://www.timeanddate.com/astronomy/meteor-shower/eta-aquariids.html"),
        (8, 12, "Perseids", "https://www.timeanddate.com/astronomy/meteor-shower/perseids.html"),
        (10, 21, "Orionids", "https://www.timeanddate.com/astronomy/meteor-shower/orionids.html"),
        (11, 17, "Leonids", "https://www.timeanddate.com/astronomy/meteor-shower/leonids.html"),
        (12, 13, "Geminids", "https://www.timeanddate.com/astronomy/meteor-shower/geminids.html"),
    ]:
        events.append((date(y, m, d), name, link))

events.sort()
next_events = [e for e in events if e[0] >= today][:3]

if not next_events:
    print(json.dumps({"text": "\U0000F005 --", "tooltip": "No upcoming events", "alt": "events"}, ensure_ascii=False))
else:
    with open(url_file, "w") as f:
        f.write(next_events[0][2])
    lines = ["<b>Upcoming Astronomy Events</b>", ""]
    for d, name, _ in next_events:
        delta = (d - today).days
        label = "Today!" if delta == 0 else f"In {delta}d" if delta <= 30 else d.strftime("%b %d")
        lines.append(f"• {name}")
        lines.append(f"  <small>{label} | {d.strftime('%b %d, %Y')}</small>")
    tooltip = "\n".join(lines)
    primary = next_events[0]
    delta = (primary[0] - today).days
    label = "TODAY" if delta == 0 else f"{delta}d" if delta <= 365 else primary[0].strftime("%b %d")
    text = f"\U0000F005 {label}"
    print(json.dumps({"text": text, "tooltip": tooltip, "alt": "events"}, ensure_ascii=False))
