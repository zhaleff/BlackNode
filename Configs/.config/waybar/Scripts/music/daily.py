#!/usr/bin/env python3
import json
import os
import time
from datetime import datetime, date

LOG = os.path.expanduser("~/.local/share/blacknode/music_history")

def parse_log():
    if not os.path.isfile(LOG):
        return []
    today = date.today()
    tracks = []
    with open(LOG) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split("|")
            if len(parts) < 3:
                continue
            try:
                ts = int(parts[0])
                log_date = datetime.fromtimestamp(ts).date()
                if log_date != today:
                    continue
                title = parts[1]
                artist = parts[2] if len(parts) > 2 else ""
                tracks.append((title, artist))
            except (ValueError, IndexError):
                continue
    return tracks

def format_duration(seconds):
    h = seconds // 3600
    m = (seconds % 3600) // 60
    if h > 0:
        return f"{h}h {m}m"
    return f"{m}m"

def main():
    tracks = parse_log()
    total_tracks = len(tracks)
    # Estimate: average song ~3.5 min = 210 seconds per unique track play
    # Better: count from log timestamps, but we don't have per-track duration
    # So use a fixed estimate or just show count
    estimated_min = total_tracks * 3  # rough 3 min per song

    if total_tracks == 0:
        text = " 󰝚  No songs today"
        tooltip = "Start playing to track your listening"
        cls = "stopped"
    else:
        text = f" 󰋲  {total_tracks} songs"
        if estimated_min >= 60:
            text += f" · {format_duration(estimated_min * 60)}"
        else:
            text += f" · {estimated_min}m"

        lines = [f"Today's Listening ({date.today().isoformat()})", ""]
        for i, (title, artist) in enumerate(tracks[:8], 1):
            line = f"  {i}. {title}"
            if artist:
                line += f" — {artist}"
            lines.append(line)
        if total_tracks > 8:
            lines.append(f"  ... and {total_tracks - 8} more")
        tooltip = "\n".join(lines)
        cls = "playing"

    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
