use serde::Deserialize;
use std::env;
use std::fs;

#[derive(Deserialize)]
struct Settings {
    #[serde(default = "default_lat")]
    latitude: String,
    #[serde(default = "default_lon")]
    longitude: String,
    #[serde(default = "default_unit")]
    unit: String,
}

fn default_lat() -> String { "auto".into() }
fn default_lon() -> String { "auto".into() }
fn default_unit() -> String { "Celsius".into() }

fn read_settings() -> Settings {
    let home = env::var("HOME").unwrap_or_default();
    let path = format!("{}/.config/waybar/Scripts/weather/weather_settings.jsonc", home);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => return Settings { latitude: "auto".into(), longitude: "auto".into(), unit: "Celsius".into() },
    };
    let cleaned: String = content.lines()
        .filter(|l| !l.trim().starts_with("//"))
        .collect::<Vec<_>>()
        .join("\n");
    serde_json::from_str(&cleaned).unwrap_or_else(|_| Settings {
        latitude: "auto".into(), longitude: "auto".into(), unit: "Celsius".into(),
    })
}

struct Location {
    lat: f64,
    lon: f64,
    name: String,
}

fn locate(settings: &Settings) -> Location {
    if settings.latitude == "auto" || settings.longitude == "auto" {
        let body = ureq::get("http://ip-api.com/json/?fields=lat,lon,city,regionName,country")
            .call()
            .ok()
            .and_then(|r| r.into_string().ok())
            .unwrap_or_default();
        let geo: serde_json::Value = serde_json::from_str(&body).unwrap_or_default();
        let city = geo["city"].as_str().unwrap_or("");
        let region = geo["regionName"].as_str().unwrap_or("");
        let country = geo["country"].as_str().unwrap_or("");
        Location {
            lat: geo["lat"].as_f64().unwrap_or(40.41),
            lon: geo["lon"].as_f64().unwrap_or(-3.70),
            name: format!("{city}, {region}, {country}"),
        }
    } else {
        Location {
            lat: settings.latitude.parse().unwrap_or(40.41),
            lon: settings.longitude.parse().unwrap_or(-3.70),
            name: String::new(),
        }
    }
}

fn weather_icon(code: i64, is_day: bool) -> &'static str {
    match (code, is_day) {
        (0 | 1, true) => "\u{f0599}",
        (0 | 1, false) => "\u{f0594}",
        (2 | 3, true) => "\u{f0595}",
        (2 | 3, false) => "\u{f0f31}",
        (45, _) => "\u{f0591}",
        (48, true) => "\u{e313}",
        (48, false) => "\u{f0591}",
        (51 | 53 | 55 | 61 | 80, true) => "\u{ef1e}",
        (51 | 53 | 55 | 61 | 80, false) => "\u{ef1b}",
        (56, true) => "\u{e306}",
        (56, false) => "\u{e323}",
        (57, _) => "\u{fb7d}",
        (63, _) => "\u{f0597}",
        (65, _) => "\u{f0596}",
        (66, true) => "\u{f0f35}",
        (66, false) => "\u{f067f}",
        (67, _) => "\u{f067f}",
        (71 | 73, true) => "\u{f0f34}",
        (71 | 73, false) => "\u{e361}",
        (75 | 77, _) => "\u{f0f36}",
        (81 | 82, _) => "\u{ef1d}",
        (85 | 86 | 95 | 96 | 99, true) => "\u{e365}",
        (85 | 86 | 95 | 96 | 99, false) => "\u{e367}",
        _ => "\u{f0599}",
    }
}

fn weather_desc(code: i64) -> &'static str {
    match code {
        0 => "Clear sky",
        1 => "Mainly clear",
        2 => "Partly cloudy",
        3 => "Overcast",
        45 => "Fog",
        48 => "Depositing rime fog",
        51 => "Light drizzle",
        53 => "Moderate drizzle",
        55 => "Dense drizzle",
        56 => "Freezing drizzle",
        57 => "Freezing drizzle",
        61 => "Slight rain",
        63 => "Moderate rain",
        65 => "Heavy rain",
        66 => "Freezing rain",
        67 => "Freezing rain",
        71 => "Slight snow",
        73 => "Moderate snow",
        75 => "Heavy snow",
        77 => "Snow grains",
        80 => "Light showers",
        81 => "Moderate showers",
        82 => "Heavy showers",
        85 => "Light snow showers",
        86 => "Heavy snow showers",
        95 => "Thunderstorm",
        96 => "Thunderstorm",
        99 => "Thunderstorm",
        _ => "Unknown",
    }
}

fn fail(reason: &str) {
    let out = serde_json::json!({
        "text": "\u{f0591} \u{2026}",
        "tooltip": reason,
        "class": "error",
        "alt": "error",
    });
    println!("{}", serde_json::to_string(&out).unwrap());
}

fn main() {
    let settings = read_settings();
    let loc = locate(&settings);
    let is_celsius = settings.unit == "Celsius";
    let temp_unit = if is_celsius { "\u{b0}C" } else { "\u{b0}F" };
    let precip_unit = if is_celsius { "mm" } else { "inch" };

    let params = [
        ("latitude", loc.lat.to_string()),
        ("longitude", loc.lon.to_string()),
        ("current", "temperature_2m,apparent_temperature,is_day,precipitation,weather_code".into()),
        ("daily", "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,sunrise,sunset".into()),
        ("temperature_unit", if is_celsius { "celsius".into() } else { "fahrenheit".into() }),
        ("precipitation_unit", precip_unit.into()),
        ("timezone", "auto".into()),
        ("forecast_days", "1".into()),
    ];

    let url = "https://api.open-meteo.com/v1/forecast";
    let body = match ureq::get(url)
        .query_pairs(params.iter().map(|(k, v)| (k.as_ref(), v.as_ref())))
        .call()
    {
        Ok(r) => match r.into_string() {
            Ok(s) => s,
            Err(_) => { fail("Failed to read response"); return; }
        },
        Err(_) => { fail("No network"); return; }
    };

    let data: serde_json::Value = match serde_json::from_str(&body) {
        Ok(d) => d,
        Err(_) => { fail("Failed to parse weather data"); return; }
    };

    let cur = &data["current"];
    let code = cur["weather_code"].as_i64().unwrap_or(0);
    let temp = cur["temperature_2m"].as_f64().unwrap_or(0.0);
    let feels = cur["apparent_temperature"].as_f64().unwrap_or(0.0);
    let precip = cur["precipitation"].as_f64().unwrap_or(0.0);
    let is_day = cur["is_day"].as_i64().unwrap_or(1) != 0;

    let daily = &data["daily"];
    let pop_max = daily["precipitation_probability_max"].as_array()
        .and_then(|a| a.first()?.as_f64()).unwrap_or(0.0);
    let sunrise = daily["sunrise"].as_array()
        .and_then(|a| a.first()?.as_str()).unwrap_or("");
    let sunset = daily["sunset"].as_array()
        .and_then(|a| a.first()?.as_str()).unwrap_or("");

    let icon = weather_icon(code, is_day);
    let desc = weather_desc(code);

    let text = format!("{icon} {temp:.0}{temp_unit}");

    let sunrise_fmt = if !sunrise.is_empty() && sunrise.len() >= 16 {
        &sunrise[11..16]
    } else { "" };
    let sunset_fmt = if !sunset.is_empty() && sunset.len() >= 16 {
        &sunset[11..16]
    } else { "" };

    let mut tooltip = format!(
        "<b>{}</b>\n\n{} {} | {:.0}{} (feels {:.0}{})",
        loc.name, icon, desc, temp, temp_unit, feels, temp_unit
    );

    if pop_max > 0.0 {
        tooltip += &format!("\nPoP {:.0}% | Precip {:.1} {precip_unit}", pop_max, precip);
    }

    if !sunrise_fmt.is_empty() {
        tooltip += &format!("\n\u{e343} Sunrise {sunrise_fmt} | \u{f059a} Sunset {sunset_fmt}");
    }

    let class = match code {
        0..=1 => "weather-clear",
        2..=3 => "weather-cloudy",
        45..=48 => "weather-fog",
        51..=57 => "weather-drizzle",
        61..=67 => "weather-rain",
        71..=77 => "weather-snow",
        80..=86 => "weather-showers",
        _ => "weather-storm",
    };

    let out = serde_json::json!({
        "text": text,
        "tooltip": tooltip,
        "class": class,
        "alt": desc,
    });

    println!("{}", serde_json::to_string(&out).unwrap());
}
