#!/usr/bin/env python3
import json
import subprocess

def get_metadata():
    try:
        fmt = "{{title}}|||{{artist}}|||{{album}}|||{{xesam:genre}}|||{{mpris:length}}|||{{status}}"
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
                    "genre": parts[3],
                    "length": parts[4],
                    "status": parts[5],
                }
        return None
    except Exception:
        return None

def main():
    meta = get_metadata()
    if not meta or not meta["title"]:
        print(json.dumps({
            "text": "",
            "tooltip": "No music",
            "class": "stopped",
            "alt": "stopped"
        }, ensure_ascii=False))
        return

    genre = meta.get("genre", "") or ""
    status = meta["status"]
    playing = status == "Playing"

    if genre:
        text = f"\uf001  {genre}"
        tooltip = f"Genre: {genre}\n{meta['title']}\n{meta['artist']}"
    elif meta.get("album"):
        text = f"\uf001  {meta['album']}"
        tooltip = f"Album: {meta['album']}\n{meta['artist']}"
    else:
        text = f"\uf001  {meta['artist']}" if meta.get("artist") else "\uf001  \u266c"
        tooltip = f"{meta['title']}\n{meta.get('artist', '')}"

    cls = "playing" if playing else "paused"
    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
