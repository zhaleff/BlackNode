#!/usr/bin/env python3
import json
import subprocess

MAX_LENGTH = 65

def get_metadata():
    try:
        fmt = "{{title}}|||{{artist}}|||{{album}}|||{{duration(position)}}|||{{status}}|||{{mpris:artUrl}}"
        output = subprocess.check_output(
            ["playerctl", "metadata", "--format", fmt, "--all-players"],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip()
        if not output:
            return None
        for line in output.split("\n"):
            parts = [p.strip() for p in line.split("|||")]
            if len(parts) >= 6 and parts[0]:
                return {
                    "title": parts[0],
                    "artist": parts[1],
                    "album": parts[2],
                    "position": parts[3],
                    "length": parts[4],
                    "status": parts[5],
                    "artUrl": parts[6] if len(parts) > 6 else ""
                }
        return None
    except Exception:
        return None

def truncate(text, limit):
    if len(text) <= limit:
        return text
    return text[:limit-1] + "\u2026"

def main():
    meta = get_metadata()
    if not meta or not meta["title"]:
        print(json.dumps({
            "text": " 󰝚  No music",
            "tooltip": "No music playing",
            "class": "stopped",
            "alt": "stopped"
        }, ensure_ascii=False))
        return

    text = meta["title"]
    if meta["artist"]:
        text += f"  \u2014  {meta['artist']}"
    if meta["status"] == "Playing" and meta["position"]:
        text += f"  {meta['position']}"

    text = truncate(text, MAX_LENGTH)

    sep = "\u2501" * 25
    tooltip = (
        f"Now Playing\n"
        f"{sep}\n"
        f"Title:   {meta['title']}\n"
        f"Artist:  {meta['artist']}\n"
        f"Album:   {meta['album']}\n"
        f"Time:    {meta['position']} / {meta['length']}\n"
        f"Status:  {meta['status']}"
    )

    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": meta["status"].lower(),
        "alt": meta["status"].lower()
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
