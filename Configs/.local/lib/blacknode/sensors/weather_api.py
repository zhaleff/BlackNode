import json
import urllib.request
import urllib.error


OPENMETEO_FORECAST = (
    "https://api.open-meteo.com/v1/forecast"
    "?latitude={lat}&longitude={lon}"
    "&current_weather=true"
    "&hourly=weathercode,temperature_2m,precipitation_probability,precipitation"
    "&timezone=UTC&forecast_hours=12"
)

WMO_DESCRIPTIONS = {
    "0": "Clear sky", "1": "Mainly clear", "2": "Partly cloudy", "3": "Overcast",
    "45": "Fog", "48": "Fog", "51": "Light drizzle", "53": "Moderate drizzle",
    "55": "Dense drizzle", "56": "Freezing drizzle", "57": "Freezing drizzle",
    "61": "Slight rain", "63": "Moderate rain", "65": "Heavy rain",
    "66": "Freezing rain", "67": "Freezing rain",
    "71": "Slight snow", "73": "Moderate snow", "75": "Heavy snow", "77": "Snow grains",
    "80": "Slight showers", "81": "Moderate showers", "82": "Violent showers",
    "85": "Slight snow showers", "86": "Heavy snow showers",
    "95": "Thunderstorm", "96": "Thunderstorm", "99": "Thunderstorm",
}

WMO_CONDITIONS = {
    "0": "clear", "1": "cloudy", "2": "cloudy", "3": "cloudy",
    "45": "fog", "48": "fog", "51": "rain", "53": "rain", "55": "rain",
    "56": "rain", "57": "rain", "61": "rain", "63": "rain", "65": "rain",
    "66": "rain", "67": "rain", "71": "snow", "73": "snow", "75": "snow",
    "77": "snow", "80": "rain", "81": "rain", "82": "rain",
    "85": "snow", "86": "snow", "95": "storm", "96": "storm", "99": "storm",
}


def locate() -> tuple[float, float]:
    req = urllib.request.Request(
        "https://ipapi.co/json/",
        headers={"User-Agent": "BlackNode/3.0"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read())
    lat = float(data.get("latitude", 40.41))
    lon = float(data.get("longitude", -3.70))
    return lat, lon


def fetch(lat: float, lon: float) -> dict | None:
    url = OPENMETEO_FORECAST.format(lat=lat, lon=lon)
    req = urllib.request.Request(url, headers={"User-Agent": "BlackNode/3.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except (urllib.error.URLError, json.JSONDecodeError, OSError):
        return None


class WeatherReport:
    def __init__(self, raw: dict):
        current = raw.get("current_weather", {})
        self.temp = float(current.get("temperature", 0))
        self.wmo = str(current.get("weathercode", 0))
        self.desc = WMO_DESCRIPTIONS.get(self.wmo, "Unknown")
        self.cond = WMO_CONDITIONS.get(self.wmo, "unknown")
        now_str = current.get("time", "")
        self.now_hour = int(now_str[11:13]) if len(now_str) > 11 else 0
        self._parse_hourly(raw.get("hourly", {}))

    def _parse_hourly(self, hourly: dict) -> None:
        self.rain_hours: list[str] = []
        self.storm = False
        times = hourly.get("time", [])
        codes = hourly.get("weathercode", [])
        probs = hourly.get("precipitation_probability", [])
        for i in range(len(times)):
            try:
                h = int(times[i][11:13])
            except (IndexError, ValueError):
                continue
            wc = str(codes[i])
            pp = probs[i] if i < len(probs) else 0
            c = WMO_CONDITIONS.get(wc, "")
            if h > self.now_hour and h <= self.now_hour + 6:
                if c == "rain" and (pp or 0) > 50:
                    self.rain_hours.append(f"{h}:00")
                if c == "storm":
                    self.storm = True

    @property
    def alert(self) -> bool:
        return self.storm or len(self.rain_hours) > 0

    @property
    def advice(self) -> str:
        if self.storm:
            return "Storm approaching"
        if self.rain_hours:
            return f"Rain around {', '.join(self.rain_hours[:3])}"
        if self.temp > 30:
            return "Stay hydrated"
        if self.temp < 5:
            return "Layer up"
        return "Good day out"
