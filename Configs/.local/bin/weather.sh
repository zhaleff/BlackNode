#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, json, urllib.request
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from datetime import datetime, timezone
from blacknode.notify.envelope import NotificationEnvelope
from blacknode.notify.engine import NotifEngine
from blacknode.resources import resolve

notifier = NotifEngine()

WMO_DESC = {"0":"Clear","1":"Mainly clear","2":"Partly cloudy","3":"Overcast","45":"Fog","48":"Fog","51":"Light drizzle","53":"Moderate drizzle","55":"Dense drizzle","56":"Freezing drizzle","57":"Freezing drizzle","61":"Light rain","63":"Moderate rain","65":"Heavy rain","66":"Freezing rain","67":"Freezing rain","71":"Light snow","73":"Moderate snow","75":"Heavy snow","77":"Snow grains","80":"Light showers","81":"Moderate showers","82":"Heavy showers","85":"Light snow showers","86":"Heavy snow showers","95":"Thunderstorm","96":"Thunderstorm","99":"Thunderstorm"}
WMO_COND = {"0":"clear","1":"cloudy","2":"cloudy","3":"cloudy","45":"fog","48":"fog","51":"rain","53":"rain","55":"rain","56":"rain","57":"rain","61":"rain","63":"rain","65":"rain","66":"rain","67":"rain","71":"snow","73":"snow","75":"snow","77":"snow","80":"rain","81":"rain","82":"rain","85":"snow","86":"snow","95":"storm","96":"storm","99":"storm"}

def locate():
    req = urllib.request.Request("https://ipapi.co/json/", headers={"User-Agent":"BlackNode/3.0"})
    with urllib.request.urlopen(req, timeout=10) as r:
        d = json.loads(r.read())
    return float(d.get("latitude",40.41)), float(d.get("longitude",-3.70))

def fetch(lat, lon):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&hourly=weathercode,temperature_2m,precipitation_probability,precipitation&timezone=UTC&forecast_hours=6"
    req = urllib.request.Request(url, headers={"User-Agent":"BlackNode/3.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except: return None

def rain_minutes(hourly):
    now = datetime.now(timezone.utc)
    for i in range(len(hourly.get("time",[]))):
        try:
            t = hourly["time"][i]
            if "T" not in t: continue
            dt = datetime.fromisoformat(t[:19].replace("Z","+00:00"))
            if dt <= now: continue
            wc = str(hourly["weathercode"][i])
            pp = hourly["precipitation_probability"][i] if i < len(hourly.get("precipitation_probability",[])) else 0
            if WMO_COND.get(wc,"") in ("rain","storm") and (pp or 0) > 40:
                return int((dt - now).total_seconds() / 60)
        except: continue
    return None

lat, lon = locate()
raw = fetch(lat, lon)
if raw is None: sys.exit(1)

cur = raw.get("current_weather",{})
temp = float(cur.get("temperature",0))
wmo = str(cur.get("weathercode",0))
desc = WMO_DESC.get(wmo,"Unknown")
cond = WMO_COND.get(wmo,"unknown")
mins = rain_minutes(raw.get("hourly",{}))

if mins is not None and mins <= 60:
    body = f"Rain in {mins} min. If you were heading out, now's the window."
    icon = resolve("weather-rain","weather")
    title = "Rain incoming"
else:
    body = f"{desc} — {temp:.0f}°C"
    icon = resolve(f"weather-{cond}","weather")
    title = desc

envelope = NotificationEnvelope(
    title=title, body=body, icon=icon,
    urgency="normal" if mins and mins <= 60 else "low",
    timeout=10000 if mins and mins <= 60 else 6000,
    replace_id=2599, app_name="Weather",
)
notifier.send(envelope)
BNPY