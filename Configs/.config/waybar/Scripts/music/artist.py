#!/usr/bin/env python3
import json
import subprocess

def get_artist():
    try:
        artist = subprocess.check_output(
            ["playerctl", "metadata", "artist", "--all-players"],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip().split("\n")[0]
        return artist
    except Exception:
        return None

def get_status():
    try:
        status = subprocess.check_output(
            ["playerctl", "status", "--all-players"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode().strip()
        return "Playing" if "Playing" in status else "Paused" if "Paused" in status else "Stopped"
    except Exception:
        return "Stopped"

def main():
    artist = get_artist()
    status = get_status()

    if not artist or status == "Stopped":
        print(json.dumps({
            "text": "",
            "tooltip": "No music",
            "class": "stopped",
            "alt": "stopped"
        }, ensure_ascii=False))
        return

    cls = "paused" if status == "Paused" else "artist"
    print(json.dumps({
        "text": f"\uf025  {artist}",
        "tooltip": f"Artist: {artist}",
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
