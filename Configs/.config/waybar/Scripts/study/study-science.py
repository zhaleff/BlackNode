#!/usr/bin/env python3
import json, os, subprocess, sys

links = [
    ("Science.org", "https://www.science.org/"),
    ("Nature", "https://www.nature.com/"),
    ("arXiv", "https://arxiv.org/"),
    ("PubMed", "https://pubmed.ncbi.nlm.nih.gov/"),
    ("Springer", "https://link.springer.com/"),
    ("NASA Science", "https://science.nasa.gov/"),
]

state_file = os.path.expanduser("~/.cache/waybar-study/science_index")

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
    subprocess.Popen(["xdg-open", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

name, url = links[idx]
text = f"\uf0c3 {name}"
tooltip_lines = ["<b>Direct Science</b>", "", "Click to open:", ""]
for i, (n, u) in enumerate(links):
    mark = " \u25B6" if i == idx else ""
    tooltip_lines.append(f"{'▸' if i == idx else '•'} {n}{mark}")
tooltip = "\n".join(tooltip_lines)
print(json.dumps({"text": text, "tooltip": tooltip, "alt": "science"}, ensure_ascii=False))
