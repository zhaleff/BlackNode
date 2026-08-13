from __future__ import annotations

import json
import os
import time
import urllib.request
from datetime import datetime, timezone

from ..context import NotificationContext
from ..envelope import NotificationEnvelope

WMO_DESC = {
    "0": "Clear", "1": "Mainly clear", "2": "Partly cloudy", "3": "Overcast",
    "45": "Fog", "48": "Fog", "51": "Light drizzle", "53": "Moderate drizzle",
    "55": "Dense drizzle", "56": "Freezing drizzle", "57": "Freezing drizzle",
    "61": "Light rain", "63": "Moderate rain", "65": "Heavy rain",
    "66": "Freezing rain", "67": "Freezing rain", "71": "Light snow",
    "73": "Moderate snow", "75": "Heavy snow", "77": "Snow grains",
    "80": "Light showers", "81": "Moderate showers", "82": "Heavy showers",
    "85": "Light snow showers", "86": "Heavy snow showers", "95": "Thunderstorm",
    "96": "Thunderstorm", "99": "Thunderstorm",
}
WMO_COND = {
    "0": "clear", "1": "cloudy", "2": "cloudy", "3": "cloudy", "45": "fog",
    "48": "fog", "51": "rain", "53": "rain", "55": "rain", "56": "rain",
    "57": "rain", "61": "rain", "63": "rain", "65": "rain", "66": "rain",
    "67": "rain", "71": "snow", "73": "snow", "75": "snow", "77": "snow",
    "80": "rain", "81": "rain", "82": "rain", "85": "snow", "86": "snow",
    "95": "storm", "96": "storm", "99": "storm",
}
WMO_ICON = {
    "0": ("sunny", "clear"), "1": ("mostly_clear", "mostly_cloudy_night"),
    "2": ("partly_cloudy", "partly_clear"), "3": "cloudy", "45": "mist",
    "48": "mist", "51": "drizzle", "53": "drizzle", "55": "drizzle",
    "56": "sleet_hail", "57": "sleet_hail", "61": "showers", "63": "showers",
    "65": "heavy", "66": "sleet_hail", "67": "strong_tstorms", "71": "snow_showers",
    "73": "heavy_snow", "75": "blizzard", "77": "flurries", "80": "showers",
    "81": "scattered_showers", "82": "heavy", "85": "snow_showers", "86": "blizzard",
    "95": "isolated_tstorms", "96": "strong_tstorms", "99": "strong_tstorms",
}
ICON_DIR = os.path.expanduser("~/.config/dunst/assets/weather/dark")
ALERT_ICON = {"rain": "showers", "chance": "showers", "heat": "sunny"}

POLL_SECONDS = 600
RAIN_MIN_THRESHOLD = 60
CHANCE_THRESHOLD_PCT = 55
HEAT_THRESHOLD_C = 33
REPLACE_IDS = {"rain": 2599, "chance": 2601, "heat": 2602}
URGENCY = {"rain": "critical", "chance": "normal", "heat": "normal"}
TIMEOUT_MS = {"rain": 15000, "chance": 12000, "heat": 12000}


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    icon = ctx.get("icon")
    if not icon:
        cond = ctx.get("cond", "cloudy")
        hour = ctx.get("hour", 0)
        icon = _choose_icon(ctx.get("wmo", "0"), ctx.get("temp", 0.0), ctx.get("windspeed", 0), hour, cond)
    kind = ctx.get("kind", "")
    title = ctx.get("title") or ctx.get("desc") or "Weather"
    body = ctx.get("body") or ctx.get("desc", "")
    urgency = URGENCY.get(kind, ctx.get("urgency", "low"))
    timeout = TIMEOUT_MS.get(kind, ctx.get("timeout", 6000))
    return ctx.envelope(
        title=title,
        body=body,
        icon=icon,
        urgency=urgency,
        timeout=timeout,
        replace_id=ctx.get("replace_id", REPLACE_IDS.get(kind, 2599)),
        app_name="Weather",
    )


def _locate() -> tuple[float, float]:
    req = urllib.request.Request("https://ipapi.co/json/", headers={"User-Agent": "BlackNode/3.0"})
    with urllib.request.urlopen(req, timeout=10) as response:
        data = json.loads(response.read())
    return float(data.get("latitude", 40.41)), float(data.get("longitude", -3.70))


def _fetch(lat: float, lon: float):
    url = (
        f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}"
        f"&current_weather=true&hourly=weathercode,temperature_2m,precipitation_probability,"
        f"precipitation&timezone=UTC&forecast_hours=12"
    )
    req = urllib.request.Request(url, headers={"User-Agent": "BlackNode/3.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            return json.loads(response.read())
    except Exception:
        return None


def _parse_dt(raw: str) -> datetime | None:
    try:
        if "T" not in raw:
            return None
        dt = datetime.fromisoformat(raw[:19].replace("Z", "+00:00"))
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt
    except Exception:
        return None


def _minutes_from_hourly(hourly, conds: set[str]) -> tuple[int | None, int]:
    now = datetime.now(timezone.utc)
    forecast = None
    prob = 0
    times = hourly.get("time", [])
    probs = hourly.get("precipitation_probability", [])
    codes = hourly.get("weathercode", [])
    for i in range(len(times)):
        dt = _parse_dt(times[i])
        if dt is None or dt <= now:
            continue
        mins = int((dt - now).total_seconds() / 60)
        code = str(codes[i]) if i < len(codes) else "0"
        p = probs[i] if i < len(probs) else 0
        if WMO_COND.get(code, "") in conds:
            if forecast is None or mins < forecast:
                forecast = mins
                prob = int(p or 0)
    return forecast, prob


def _max_temp(hourly) -> float | None:
    temps = [t for t in hourly.get("temperature_2m", []) if isinstance(t, (int, float))]
    return max(temps) if temps else None


def _choose_icon(wmo: str, temp: float, windspeed: float, hour: int, cond: str) -> str:
    icon = WMO_ICON.get(wmo, "cloudy")
    if isinstance(icon, tuple):
        day_icon, night_icon = icon
        icon = day_icon if 7 <= hour < 20 else night_icon
    if icon == "clear":
        icon = "sunny" if 7 <= hour < 20 else "clear"
    if icon == "cloudy" and windspeed >= 20:
        icon = "windy_breezy"
    if icon == "sunny" and temp <= -10:
        icon = "very_cold"
    path = os.path.join(ICON_DIR, f"{icon}.svg")
    if os.path.isfile(path):
        return path
    return os.path.join(ICON_DIR, "cloudy.svg")


def _decide(hourly, current) -> tuple | None:
    temp = float(current.get("temperature", 0))
    wmo = str(current.get("weathercode", 0))
    windspeed = float(current.get("windspeed", 0))
    hour = datetime.now().hour
    cond = WMO_COND.get(wmo, "cloudy")
    icon = _choose_icon(wmo, temp, windspeed, hour, cond)

    rain_mins, rain_prob = _minutes_from_hourly(hourly, {"rain", "storm"})
    if rain_mins is not None and rain_mins <= RAIN_MIN_THRESHOLD and rain_prob >= 40:
        return {
            "kind": "rain",
            "icon": _icon_path("showers"),
            "title": "Rain incoming",
            "body": f"Rain is starting in about {rain_mins} min — grab a cover.",
            "sig": f"rain-{rain_mins}",
        }

    future_mins, prob = _minutes_from_hourly(hourly, {"rain", "storm"})
    if future_mins is not None and prob >= CHANCE_THRESHOLD_PCT:
        hours = max(1, round(future_mins / 60))
        return {
            "kind": "chance",
            "icon": _icon_path("showers"),
            "title": "Rain expected",
            "body": f"Chance of rain {prob}% in about {hours} h — keep an umbrella handy.",
            "sig": f"chance-{prob // 10}-{future_mins // 60}",
        }

    tmax = _max_temp(hourly)
    if tmax is not None and tmax >= HEAT_THRESHOLD_C:
        return {
            "kind": "heat",
            "icon": _icon_path("sunny"),
            "title": "Heat alert",
            "body": f"Up to {tmax:.0f}°C over the next hours — stay hydrated.",
            "sig": f"heat-{int(tmax // 2)}",
        }

    return None


def _icon_path(name: str) -> str:
    fallback = "cloudy"
    path = os.path.join(ICON_DIR, f"{name}.svg")
    return path if os.path.isfile(path) else os.path.join(ICON_DIR, f"{fallback}.svg")


def run(service) -> None:
    lat, lon = _locate()
    last = {}
    while True:
        raw = _fetch(lat, lon)
        if raw is not None:
            alert = _decide(raw.get("hourly", {}), raw.get("current_weather", {}))
            if alert:
                if last.get(alert["kind"]) != alert["sig"]:
                    service.notify(
                        "weather",
                        kind=alert["kind"],
                        title=alert["title"],
                        body=alert["body"],
                        icon=alert["icon"],
                    )
                    last[alert["kind"]] = alert["sig"]
        time.sleep(POLL_SECONDS)