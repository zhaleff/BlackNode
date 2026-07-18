#!/usr/bin/env python3
import json, urllib.request, html, os, subprocess, sys

cache = os.path.expanduser("~/.cache/waybar-astro")
os.makedirs(cache, exist_ok=True)
url_file = os.path.join(cache, "apod_url")

if len(sys.argv) > 1 and sys.argv[1] == "--open":
    try:
        with open(url_file) as f:
            subprocess.Popen(["xdg-open", f.read().strip()], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        subprocess.Popen(["xdg-open", "https://apod.nasa.gov/apod/astropix.html"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

try:
    with urllib.request.urlopen("https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=True", timeout=15) as r:
        data = json.loads(r.read())
    title = html.unescape(data.get("title", "Unknown"))
    date = data.get("date", "")
    expl = html.unescape(data.get("explanation", ""))
    if len(expl) > 350:
        expl = expl[:347] + "..."
    cr = data.get("copyright", "NASA")
    hdurl = data.get("hdurl", data.get("url", ""))
    with open(url_file, "w") as f:
        f.write(hdurl)
    tooltip = f"<b>{title}</b>\n<small>{date} \u00A9 {cr}</small>\n\n{expl}"
    text = f"\U000F030A {date}"
    print(json.dumps({"text": text, "tooltip": tooltip, "alt": "apod"}, ensure_ascii=False))
except Exception as e:
    print(json.dumps({"text": "\U000F030A --", "tooltip": f"APOD: {e}", "alt": "error"}, ensure_ascii=False))
