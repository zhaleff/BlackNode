#!/usr/bin/env python3
import time
from datetime import datetime, timezone

ref = datetime(2000, 1, 6, 18, 14, tzinfo=timezone.utc).timestamp()
now = time.time()
cycle = 29.53058867 * 86400

elapsed = now - ref
phase = (elapsed % cycle) / cycle
idx = int(phase * 8) % 8

icons = ["🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"]
names = ["New Moon","Waxing Crescent","First Quarter","Waxing Gibbous",
         "Full Moon","Waning Gibbous","Last Quarter","Waning Crescent"]

print(f'{{"text":"{icons[idx]}","tooltip":"{names[idx]} ({phase*100:.0f}%)"}}')
