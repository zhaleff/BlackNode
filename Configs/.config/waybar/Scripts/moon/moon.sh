#!/usr/bin/env python3
import json, urllib.request, sys, time
from datetime import datetime, timezone

icons = ["🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"]
names = ["New Moon","Waxing Crescent","First Quarter","Waxing Gibbous",
         "Full Moon","Waning Gibbous","Last Quarter","Waning Crescent"]

lat, lon = "40.71", "-74.01"

try:
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&daily=moon_phase&timezone=auto&forecast_days=1"
    with urllib.request.urlopen(url, timeout=10) as resp:
        data = json.loads(resp.read())
    phase = data["daily"]["moon_phase"][0]
except Exception:
    ref = datetime(2000, 1, 6, 18, 14, tzinfo=timezone.utc).timestamp()
    now = time.time()
    cycle = 29.53058867 * 86400
    phase = ((now - ref) % cycle) / cycle

idx = int(phase * 8) % 8
pct = phase * 100
print(f'{{"text":"{icons[idx]}","tooltip":"{names[idx]} ({pct:.0f}%)"}}')
