#!/usr/bin/env python3
import json, urllib.request, html, os, subprocess, sys
from urllib.error import HTTPError, URLError

cache = os.path.expanduser("~/.cache/waybar-astro")
os.makedirs(cache, exist_ok=True)
url_file = os.path.join(cache, "space_news_url")

if len(sys.argv) > 1 and sys.argv[1] == "--open":
    try:
        with open(url_file) as f:
            subprocess.Popen(["xdg-open", f.read().strip()], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        subprocess.Popen(["xdg-open", "https://www.spaceflightnewsapi.net/"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

headers = {"User-Agent": "BlackNode/1.0"}
endpoints = [
    "https://api.spaceflightnewsapi.net/v4/articles/?limit=3&ordering=-published_at",
    "https://api.spaceflightnewsapi.net/v4/blogs/?limit=3&ordering=-published_at",
    "https://api.spaceflightnewsapi.net/v4/reports/?limit=3&ordering=-published_at",
]

all_items = []
errors = []

for ep in endpoints:
    try:
        req = urllib.request.Request(ep, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as r:
            data = json.loads(r.read())
        items = data.get("results", [])
        for item in items:
            item["_source"] = ep.split("/v4/")[1].split("/")[0]
        all_items.extend(items)
    except HTTPError as e:
        errors.append(f"{ep.split('/v4/')[1].split('/')[0]}: {e.code}")
    except Exception as e:
        errors.append(f"{ep.split('/v4/')[1].split('/')[0]}: {e}")

all_items.sort(key=lambda x: x.get("published_at", ""), reverse=True)

if not all_items:
    err_msg = "; ".join(errors) if errors else "No content"
    print(json.dumps({"text": "\U000F04D7 err", "tooltip": f"News: {err_msg}", "alt": "error"}, ensure_ascii=False))
    sys.exit(0)

latest = all_items[0]
title = html.unescape(latest["title"])
art_url = latest["url"]
site = latest.get("news_site", "Unknown")
summary = html.unescape(latest.get("summary", ""))
pub_date = latest["published_at"][:10]
source_type = latest.get("_source", "article").title()[:-1]

with open(url_file, "w") as f:
    f.write(art_url)

lines = [f"<b>[{source_type}] {title}</b>"]
lines.append(f"<small>{site} | {pub_date}</small>")
if summary:
    lines.append("")
    lines.append(summary[:250] + ("..." if len(summary) > 250 else ""))
lines.append("")
lines.append("<b>More headlines:</b>")
for a in all_items[1:6]:
    t = html.unescape(a["title"])
    s = a.get("_source", "article").title()[:-1]
    lines.append(f"• [{s}] {t}")
    lines.append(f"  <small>{a.get('news_site','?')} {a['published_at'][:10]}</small>")
if errors:
    lines.append("")
    lines.append(f"<small>API issues: {'; '.join(errors)}</small>")

tooltip = "\n".join(lines)
text_title = f"[{source_type}] {title[:40]}{'...' if len(title)>40 else ''}"
text = f"\U000F04D7 {text_title}"
print(json.dumps({"text": text, "tooltip": tooltip, "alt": "news"}, ensure_ascii=False))
