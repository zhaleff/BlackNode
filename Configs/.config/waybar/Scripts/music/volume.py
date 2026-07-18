#!/usr/bin/env python3
import json
import subprocess

ICONS = {
    0: "\uf026",
    30: "\uf027",
    60: "\uf028",
}

def get_volume():
    try:
        out = subprocess.check_output(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode().strip()
        parts = out.split()
        vol = float(parts[1]) if len(parts) > 1 else 0
        muted = "MUTED" in out
        return int(vol * 100), muted
    except Exception:
        return 0, False

def get_sink_name():
    try:
        out = subprocess.check_output(
            ["wpctl", "status"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode()
        for line in out.split("\n"):
            if "*" in line and "Sink" in line:
                parts = line.split()
                if len(parts) >= 4:
                    return " ".join(parts[3:])
        return "default"
    except Exception:
        return "default"

def main():
    vol, muted = get_volume()
    sink = get_sink_name()

    if muted:
        text = f"\uf026  Muted"
        cls = "muted"
    elif vol == 0:
        text = f"\uf026  {vol}%"
        cls = "quiet"
    elif vol < 30:
        text = f"\uf027  {vol}%"
        cls = "quiet"
    elif vol < 60:
        text = f"\uf028  {vol}%"
        cls = "medium"
    else:
        text = f"\uf028  {vol}%"
        cls = "loud"

    sep = "\u2501" * 16
    tooltip = f"Volume\n{sep}\nLevel:  {vol}%\nMuted:  {'Yes' if muted else 'No'}\nSink:   {sink}"

    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
