#!/usr/bin/env python3
import json
import os
import sys
import time
import requests
from datetime import datetime, date

STATE_DIR = os.path.expanduser("~/.local/state/waybar")
CACHE_FILE = os.path.join(STATE_DIR, "weather_cache.json")
REFRESH_SECONDS = 900
UA = {"User-Agent": "waybar-weather/2.0"}

SUN = "\U000f0599"
PARTLY = "\U000f0595"
CLOUD = "\U000f0590"
FOG = "\U000f0591"
DRIZZLE = "\U000f0597"
RAIN = "\U000f0596"
FREEZING_RAIN = "\U000f067f"
SNOW = "\U000f0598"
STORM = "\U000f0593"
STORM_HAIL = "\U000f067e"
NIGHT = "\U000f0594"
SUNRISE_ICON = "\U000f059e"
SUNSET_ICON = "\U000f059b"
HUMIDITY_ICON = "\U000f058e"
PRESSURE_ICON = "\U000f0205"
WIND_ICON = "\U000f059d"
PRECIP_ICON = "\U000f058c"
THERMO_ICON = "\U000f050f"
ERROR_ICON = "\U000f0026"

WMO = {
    0: (SUN, "Clear sky", "sun"),
    1: (PARTLY, "Mainly clear", "partly"),
    2: (PARTLY, "Partly cloudy", "partly"),
    3: (CLOUD, "Overcast", "cloud"),
    45: (FOG, "Fog", "fog"),
    48: (FOG, "Depositing rime fog", "fog"),
    51: (DRIZZLE, "Light drizzle", "drizzle"),
    53: (DRIZZLE, "Moderate drizzle", "drizzle"),
    55: (RAIN, "Dense drizzle", "drizzle"),
    56: (DRIZZLE, "Light freezing drizzle", "drizzle"),
    57: (RAIN, "Dense freezing drizzle", "drizzle"),
    61: (DRIZZLE, "Slight rain", "rain"),
    63: (RAIN, "Moderate rain", "rain"),
    65: (RAIN, "Heavy rain", "rain"),
    66: (FREEZING_RAIN, "Light freezing rain", "rain"),
    67: (FREEZING_RAIN, "Heavy freezing rain", "rain"),
    71: (SNOW, "Slight snow fall", "snow"),
    73: (SNOW, "Moderate snow fall", "snow"),
    75: (SNOW, "Heavy snow fall", "snow"),
    77: (SNOW, "Snow grains", "snow"),
    80: (DRIZZLE, "Slight rain showers", "rain"),
    81: (RAIN, "Moderate rain showers", "rain"),
    82: (STORM_HAIL, "Violent rain showers", "storm"),
    85: (SNOW, "Slight snow showers", "snow"),
    86: (SNOW, "Heavy snow showers", "snow"),
    95: (STORM, "Thunderstorm", "storm"),
    96: (STORM_HAIL, "Thunderstorm with slight hail", "storm"),
    99: (STORM_HAIL, "Thunderstorm with heavy hail", "storm"),
}

COLOR = {
    "sun": "#FFC107", "cloud": "#E0E0E0", "partly": "#FFD740",
    "rain": "#00E5FF", "drizzle": "#40C4FF", "storm": "#E040FB",
    "snow": "#FFFFFF", "fog": "#B0BEC5", "wind": "#1DE9B6",
    "night": "#FFD600", "sunrise": "#FF6E40", "sunset": "#FF1744",
    "humidity": "#00E5FF", "pressure": "#76FF03", "precip": "#2979FF",
    "very_cold": "#00E5FF", "cold": "#40C4FF", "chilly": "#69F0AE",
    "neutral": "#76FF03", "warm": "#FFEA00", "hot": "#FF1744",
    "pop_low": "#B388FF", "pop_med": "#7C4DFF", "pop_high": "#651FFF",
    "pop_vhigh": "#E040FB", "divider": "#4a4a4a",
}

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


def span(color, text):
    return f'<span foreground="{color}">{text}</span>'


def wmo(code, is_day=True):
    glyph, desc, key = WMO.get(int(code), (CLOUD, "Unknown", "cloud"))
    if not is_day and int(code) in (0, 1, 2):
        glyph, key = NIGHT, "night"
    return glyph, desc, COLOR[key]


def temp_color(t):
    if t < 5:
        return COLOR["very_cold"]
    if t < 18:
        return COLOR["cold"]
    if t < 19:
        return COLOR["chilly"]
    if t < 24:
        return COLOR["neutral"]
    if t < 29:
        return COLOR["warm"]
    return COLOR["hot"]


def pop_color(p):
    p = max(0, min(100, int(p)))
    if p < 30:
        return COLOR["pop_low"]
    if p < 60:
        return COLOR["pop_med"]
    if p < 80:
        return COLOR["pop_high"]
    return COLOR["pop_vhigh"]


def wind_dir(deg):
    dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    return dirs[round(deg / 45) % 8]


def geolocate():
    try:
        r = requests.get("http://ip-api.com/json/", headers=UA, timeout=6)
        r.raise_for_status()
        j = r.json()
        if j.get("status") == "success":
            return j["lat"], j["lon"], j.get("city", ""), j.get("country", "")
    except Exception:
        pass
    r = requests.get("https://ipapi.co/json/", headers=UA, timeout=6)
    r.raise_for_status()
    j = r.json()
    return j["latitude"], j["longitude"], j.get("city", ""), j.get("country_name", "")


def reverse_geocode(lat, lon, fallback_city, fallback_country):
    try:
        r = requests.get(
            "https://geocoding-api.open-meteo.com/v1/reverse",
            params={"latitude": lat, "longitude": lon, "language": "en"},
            headers=UA, timeout=6,
        )
        r.raise_for_status()
        results = r.json().get("results")
        if results:
            p = results[0]
            return p.get("name", fallback_city), p.get("country", fallback_country)
    except Exception:
        pass
    return fallback_city, fallback_country


def fetch_forecast(lat, lon):
    params = {
        "latitude": lat, "longitude": lon,
        "current": "temperature_2m,apparent_temperature,relative_humidity_2m,"
                   "surface_pressure,wind_speed_10m,wind_gusts_10m,wind_direction_10m,"
                   "weather_code,is_day,precipitation",
        "daily": "weather_code,temperature_2m_max,temperature_2m_min,"
                 "precipitation_sum,precipitation_probability_max,sunrise,sunset",
        "timezone": "auto",
        "forecast_days": 7,
    }
    r = requests.get("https://api.open-meteo.com/v1/forecast", params=params, headers=UA, timeout=10)
    r.raise_for_status()
    return r.json()


def load_cache():
    try:
        with open(CACHE_FILE) as f:
            return json.load(f)
    except Exception:
        return None


def save_cache(payload):
    os.makedirs(STATE_DIR, exist_ok=True)
    payload["_ts"] = time.time()
    with open(CACHE_FILE, "w") as f:
        json.dump(payload, f)


def cache_fresh(cache):
    return cache is not None and (time.time() - cache.get("_ts", 0)) < REFRESH_SECONDS


def get_data():
    cache = load_cache()
    if cache_fresh(cache):
        return cache
    lat, lon, city, country = geolocate()
    city, country = reverse_geocode(lat, lon, city, country)
    data = fetch_forecast(lat, lon)
    payload = {"city": city, "country": country, "data": data}
    save_cache(payload)
    return payload


def fmt_time(iso):
    return datetime.fromisoformat(iso).strftime("%I:%M %p").lstrip("0")


def fmt_day(iso):
    dt = datetime.fromisoformat(iso)
    return DAYS[dt.weekday()], dt.strftime("%d/%m")


def build_tooltip(city, country, cur, daily):
    glyph, desc, color = wmo(cur["weather_code"], cur["is_day"])
    feels = round(cur["apparent_temperature"], 1)
    humidity = cur["relative_humidity_2m"]
    pressure = round(cur["surface_pressure"], 1)
    wind_speed = round(cur["wind_speed_10m"], 1)
    wind_gust = round(cur["wind_gusts_10m"], 1)
    sunrise = fmt_time(daily["sunrise"][0])
    sunset = fmt_time(daily["sunset"][0])

    lines = [
        f"<b>{city}, {country}</b>",
        desc,
        f"Feels like: {feels}°C",
        f"Humidity: {humidity}%",
        f"Pressure: {pressure:,} hPa",
        f"Wind: {wind_speed} \u2192 {wind_gust} km/h ({wind_dir(cur['wind_direction_10m'])})",
        "",
        f"{span(COLOR['sunrise'], SUNRISE_ICON)} {sunrise}   {span(COLOR['sunset'], SUNSET_ICON)} {sunset}",
    ]
    return "\n".join(lines)


def run():
    payload = get_data()
    city, country, data = payload["city"], payload["country"], payload["data"]
    cur = data["current"]
    daily = data["daily"]

    glyph, desc, color = wmo(cur["weather_code"], cur["is_day"])
    temp = round(cur["temperature_2m"], 1)

    out = {
        "text": f"{span(color, glyph)} {temp}°C",
        "alt": desc,
        "tooltip": build_tooltip(city, country, cur, daily),
        "class": f"wmo-{cur['weather_code']}",
        "percentage": cur["relative_humidity_2m"],
    }
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    try:
        run()
    except Exception as e:
        print(json.dumps({
            "text": f"{span(COLOR['storm'], ERROR_ICON)} err",
            "tooltip": f"{type(e).__name__}: {e}",
            "class": "error",
        }, ensure_ascii=False))
        sys.exit(0)
