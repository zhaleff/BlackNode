#!/usr/bin/env python3
import json
import subprocess

def is_active():
    try:
        s = subprocess.check_output(["playerctl", "status", "--all-players"],
            stderr=subprocess.DEVNULL, timeout=1).decode().strip()
        return "Playing" in s or "Paused" in s
    except:
        return False

def main():
    if not is_active():
        print(json.dumps({"text": "", "tooltip": "No player", "class": "stopped", "alt": "stopped"}, ensure_ascii=False))
        return

    text = "\uf074"
    tooltip = "Shuffle: On"

    print(json.dumps({"text": text, "tooltip": tooltip, "class": "shuffle", "alt": "shuffle"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
