#!/usr/bin/env python3
import json, urllib.request, time
from datetime import datetime, timezone

moon_icons = [
    "\U000F0F5D", "\U000F0F5E", "\U000F0F5F", "\U000F0F60",
    "\U000F0F61", "\U000F0F62", "\U000F0F63", "\U000F0F64"
]
moon_names = [
    "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
    "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"
]

lat, lon = "40.71", "-74.01"
phase = None

try:
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&daily=moon_phase&timezone=auto&forecast_days=1"
    with urllib.request.urlopen(url, timeout=10) as r:
        data = json.loads(r.read())
    phase = data["daily"]["moon_phase"][0]
except Exception:
    ref = datetime(2000, 1, 6, 18, 14, tzinfo=timezone.utc).timestamp()
    now = time.time()
    cycle = 29.53058867 * 86400
    phase = ((now - ref) % cycle) / cycle

idx = int(phase * 8) % 8
pct = phase * 100
text = f"{moon_icons[idx]}"
tooltip = f"<b>{moon_names[idx]}</b>\nCycle: {pct:.0f}%"
print(json.dumps({"text": text, "tooltip": tooltip, "alt": str(idx)}, ensure_ascii=False))
