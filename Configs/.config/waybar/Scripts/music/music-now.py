#!/usr/bin/env python3
import json
import subprocess
import sys

def get_metadata():
    try:
        fmt = "{{title}}|||{{artist}}|||{{album}}|||{{duration(position)}}|||{{duration(mpris:length)}}|||{{playerName}}|||{{status}}|||{{mpris:artUrl}}"
        output = subprocess.check_output(
            ["playerctl", "metadata", "--format", fmt],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip()
        parts = [p.strip() for p in output.split("|||")]
        return {
            "title": parts[0] if len(parts) > 0 else "",
            "artist": parts[1] if len(parts) > 1 else "",
            "album": parts[2] if len(parts) > 2 else "",
            "position": parts[3] if len(parts) > 3 else "",
            "length": parts[4] if len(parts) > 4 else "",
            "player": parts[5] if len(parts) > 5 else "",
            "status": parts[6] if len(parts) > 6 else "",
            "artUrl": parts[7] if len(parts) > 7 else ""
        }
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return None

def main():
    meta = get_metadata()
    if not meta or not meta["title"]:
        out = {
            "text": " 󰝚  No music",
            "tooltip": "Nothing playing\n\nPlay something to see details here",
            "class": "stopped",
            "alt": "stopped"
        }
        print(json.dumps(out))
        return

    icon = "" if meta["status"] == "Playing" else ""
    text = f"{icon} {meta['title']} — {meta['artist']}"

    lines = [
        f"Now Playing ({meta['player']})",
        "",
        f"Title:   {meta['title']}",
        f"Artist:  {meta['artist']}",
        f"Album:   {meta['album']}"
    ]
    if meta["position"] and meta["length"]:
        lines.append(f"Time:    {meta['position']} / {meta['length']}")
    lines.append(f"Status:  {meta['status']}")

    cls = meta["status"].lower() if meta["status"] else "stopped"

    out = {
        "text": text,
        "tooltip": "\n".join(lines),
        "class": cls,
        "alt": cls
    }
    print(json.dumps(out, ensure_ascii=False))

if __name__ == "__main__":
    main()
