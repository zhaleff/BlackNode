#!/usr/bin/env python3
import json, urllib.request, os, subprocess, sys

cache = os.path.expanduser("~/.cache/waybar-astro")
os.makedirs(cache, exist_ok=True)
url_file = os.path.join(cache, "sun_url")

if len(sys.argv) > 1 and sys.argv[1] == "--open":
    try:
        with open(url_file) as f:
            subprocess.Popen(["xdg-open", f.read().strip()], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        subprocess.Popen(["xdg-open", "https://www.timeanddate.com/sun/"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

lat, lon = "40.71", "-74.01"
with open(url_file, "w") as f:
    f.write("https://www.timeanddate.com/sun/")

try:
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&daily=sunrise,sunset,daylight_duration,uv_index_max&timezone=auto&forecast_days=1"
    with urllib.request.urlopen(url, timeout=15) as r:
        data = json.loads(r.read())
    d = data["daily"]
    rise = d["sunrise"][0].split("T")[1]
    set = d["sunset"][0].split("T")[1]
    dur = d["daylight_duration"][0]
    uv = d.get("uv_index_max", [0])[0]
    hours = int(dur // 3600)
    mins = int((dur % 3600) // 60)
    text = f"\U0000F185 {rise}-{set}"
    tooltip = f"<b>Solar Data</b>\nSunrise: {rise}\nSunset:  {set}\nDaylight: {hours}h {mins}m\nUV Index: {uv}"
    print(json.dumps({"text": text, "tooltip": tooltip, "alt": "sun"}, ensure_ascii=False))
except Exception as e:
    print(json.dumps({"text": "\U0000F185 --", "tooltip": f"Sun: {e}", "alt": "error"}, ensure_ascii=False))
