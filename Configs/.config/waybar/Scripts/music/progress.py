#!/usr/bin/env python3
import json
import subprocess

WIDTH = 9

def get_position():
    try:
        out = subprocess.check_output(
            ["playerctl", "metadata", "--format",
             "{{duration(position)}}|||{{duration(mpris:length)}}|||{{status}}",
             "--all-players"],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip()
        if not out:
            return None
        for line in out.split("\n"):
            parts = [p.strip() for p in line.split("|||")]
            if len(parts) >= 2 and parts[0]:
                return {"pos": parts[0], "len": parts[1], "status": parts[2] if len(parts) > 2 else ""}
        return None
    except:
        return None

def to_sec(t):
    if not t:
        return 0
    p = t.split(":")
    if len(p) == 2:
        return int(p[0]) * 60 + int(p[1])
    if len(p) == 3:
        return int(p[0]) * 3600 + int(p[1]) * 60 + int(p[2])
    return 0

def main():
    meta = get_position()
    if not meta or meta["status"] == "Stopped":
        print(json.dumps({
            "text": "",
            "class": "stopped",
            "alt": "stopped"
        }, ensure_ascii=False))
        return

    pos_s = to_sec(meta["pos"])
    len_s = to_sec(meta["len"])
    playing = meta["status"] == "Playing"
    cls = "playing" if playing else "paused"

    if len_s == 0:
        text = meta["pos"]
    else:
        ratio = pos_s / len_s if len_s > 0 else 0
        dot = round(ratio * (WIDTH - 1))
        line = "".join("\u2500" if i != dot else "\u25cf" for i in range(WIDTH))
        text = f"{line} {meta['pos']}"

    print(json.dumps({
        "text": text,
        "tooltip": f"{meta['pos']} / {meta['len']}",
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
