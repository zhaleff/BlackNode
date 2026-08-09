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

fn icon_color(code: i64, is_day: bool) -> &'static str {
    match code {
        0..=1 if is_day => "#E6C27A",   // clear / sunny — soft warm amber
        0..=1 => "#8C93B0",             // clear night — cool moon
        2..=3 => "#9A97A8",             // cloudy — muted lilac gray
        45..=48 => "#8C8A99",          // fog
        51..=57 => "#8FB4D9",           // drizzle
        61..=67 => "#6B7FC6",           // rain
        71..=77 => "#A9CFEA",           // snow
        80..=86 => "#7FA8D6",           // showers
        _ => "#9A8FC9",                 // storm
    }
}

// weekday (0=Sunday) for a YYYY-MM-DD string, no external crates
fn ymd_weekday(date: &str) -> usize {
    let mut parts = date.split('-');
    let mut y: i64 = parts.next().and_then(|s| s.parse().ok()).unwrap_or(1970);
    let m: i64 = parts.next().and_then(|s| s.parse().ok()).unwrap_or(1);
    let d: i64 = parts.next().and_then(|s| s.parse().ok()).unwrap_or(1);
    y -= if m <= 2 { 1 } else { 0 };
    let era = if y >= 0 { y } else { y - 399 } / 400;
    let yoe = y - era * 400;
    let doy = (153 * (m + if m > 2 { -3 } else { 9 }) + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    let days = era * 146097 + doe - 719468; // days since 1970-01-01
    ((days + 4) % 7) as usize // 1970-01-01 was Thursday (index 4)
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
        ("hourly", "precipitation_probability,temperature_2m".into()),
        ("daily", "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,sunrise,sunset,sunshine_duration".into()),
        ("temperature_unit", if is_celsius { "celsius".into() } else { "fahrenheit".into() }),
        ("precipitation_unit", precip_unit.into()),
        ("wind_speed_unit", if is_celsius { "kmh".into() } else { "mph".into() }),
        ("timezone", "auto".into()),
        ("forecast_days", "7".into()),
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

    let text = format!(
        "<span color='{}'>{}</span> <span alpha='70%'>{:.0}{}</span>",
        icon_color(code, is_day), icon, temp, temp_unit
    );

    let sunrise_fmt = if !sunrise.is_empty() && sunrise.len() >= 16 {
        &sunrise[11..16]
    } else { "" };
    let sunset_fmt = if !sunset.is_empty() && sunset.len() >= 16 {
        &sunset[11..16]
    } else { "" };

    // ----- WEEKLY tooltip -----
    let days = daily["time"].as_array().map(|a| a.clone()).unwrap_or_default();
    let codes = daily["weather_code"].as_array().map(|a| a.clone()).unwrap_or_default();
    let tmax = daily["temperature_2m_max"].as_array().map(|a| a.clone()).unwrap_or_default();
    let tmin = daily["temperature_2m_min"].as_array().map(|a| a.clone()).unwrap_or_default();
    let pops = daily["precipitation_probability_max"].as_array().map(|a| a.clone()).unwrap_or_default();

    // header
    let mut tooltip = String::new();
    tooltip += &format!(
        "{} <small><i>{}</i></small>\n",
        loc.name, desc
    );

    // current temp — the hero number
    tooltip += &format!(
        "<span size='x-large' color='{}'>{:.0}{}</span>",
        icon_color(code, is_day), temp, temp_unit
    );
    tooltip += &format!(
        "   <span alpha='60%' size='small'>feels {:.0}{}</span>",
        feels, temp_unit
    );

    // precipitation line, only when relevant (selective attention)
    if pop_max >= 20.0 {
        tooltip += &format!(
            "\n<span alpha='55%'>⚡</span> <span color='#6B7FC6'>{:.0}%</span> chance of rain",
            pop_max
        );
    }

    tooltip += &format!(
        "\n<span alpha='40%'>Sunrise {} · Sunset {}</span>",
        sunrise_fmt, sunset_fmt
    );

    // weekly forecast — clean aligned rows
    tooltip += "\n──────\n";
    tooltip += "<span size='small' alpha='35%'>day · temps · chances</span>\n";

    let weekday_name = |i: usize| -> String {
        let wd = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        let date = days.get(i).and_then(|v| v.as_str()).unwrap_or("");
        let ymd = date.split('T').next().unwrap_or("");
        match i {
            0 => "Today".into(),
            1 => "Tomorrow".into(),
            _ => wd.get(ymd_weekday(ymd)).copied().unwrap_or("").to_string(),
        }
    };

    for i in 0..7 {
        if i >= codes.len() || i >= tmax.len() || i >= tmin.len() { continue; }
        let c = codes[i].as_i64().unwrap_or(0);
        let hi = tmax[i].as_f64().unwrap_or(0.0).round() as i64;
        let lo = tmin[i].as_f64().unwrap_or(0.0).round() as i64;
        let p = pops.get(i).and_then(|v| v.as_f64()).unwrap_or(0.0);

        let day = weekday_name(i);
        let day_icon = weather_icon(c, true);
        let chances = if p >= 50.0 {
            format!("{:>4}", format!("💧{:.0}%", p))
        } else if p >= 20.0 {
            format!("{:>4}", format!("💦{:.0}%", p))
        } else { String::new() };

        tooltip += &format!(
            "\n{:>9} {}  {:>3}° / {:>3}°  {}",
            day, day_icon, hi, lo, chances.trim()
        );
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
