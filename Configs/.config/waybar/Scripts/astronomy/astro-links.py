#!/usr/bin/env python3
import json, os, subprocess, sys

links = [
    ("Stellarium", "stellarium"),
    ("NASA Eyes", "https://eyes.nasa.gov/"),
    ("Heavens Above", "https://www.heavens-above.com/"),
    ("Clear Sky Chart", "https://www.cleardarksky.com/csk/"),
    ("JWST Feed", "https://www.jwst.nasa.gov/"),
    ("Space.com", "https://www.space.com/"),
    ("NASA APOD", "https://apod.nasa.gov/apod/astropix.html"),
]

state_dir = os.path.expanduser("~/.cache/waybar-astro")
os.makedirs(state_dir, exist_ok=True)
state_file = os.path.join(state_dir, "link_index")

try:
    with open(state_file) as f:
        idx = int(f.read().strip())
except Exception:
    idx = 0

if len(sys.argv) > 1 and sys.argv[1] == "--next":
    idx = (idx + 1) % len(links)
    with open(state_file, "w") as f:
        f.write(str(idx))
    name, url = links[idx]
    if url == "stellarium":
        subprocess.Popen(["stellarium"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        subprocess.Popen(["xdg-open", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

name, url = links[idx]
text = f"\U0000F0AC {name}"
tooltip_lines = ["<b>Quick Links</b>", "", "Click to cycle and open:", ""]
for i, (n, u) in enumerate(links):
    mark = " \u25B6" if i == idx else ""
    tooltip_lines.append(f"{'•' if i != idx else '▸'} {n}{mark}")
tooltip = "\n".join(tooltip_lines)
out = json.dumps({"text": text, "tooltip": tooltip, "alt": "links"}, ensure_ascii=False)
print(out)
