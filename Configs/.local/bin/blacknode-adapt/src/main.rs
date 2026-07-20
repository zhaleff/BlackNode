use serde::Deserialize;
use std::collections::HashMap;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::PathBuf;
use std::process::Command;

#[derive(Debug, Deserialize)]
struct Behavior {
    sessions: Sessions,
    active_hours: HashMap<String, u64>,
    focus_blocks: FocusBlocks,
    distraction: Distraction,
    profile_usage: HashMap<String, u64>,
    window_samples: HashMap<String, u64>,
    last_rollup: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Sessions {
    streak_days: u64,
    last_session_date: String,
}

#[derive(Debug, Deserialize)]
struct FocusBlocks {
    count: u64,
    avg_min: u64,
    longest_min: u64,
}

#[derive(Debug, Deserialize)]
struct Distraction {
    apps: HashMap<String, u64>,
}

fn state_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join(".local/share/blacknode")
}

fn behavior_path() -> PathBuf {
    state_dir().join("behavior.json")
}

fn decision_path() -> PathBuf {
    state_dir().join("adapt_last.json")
}

#[derive(Debug, Deserialize, serde::Serialize)]
struct LastDecision {
    focus_suggest: Option<String>,
    ambient: Option<String>,
}

fn notify(title: &str, body: &str) {
    let _ = Command::new("notify-send")
        .args(["-a", "BlackNode", "-u", "low", title, body])
        .status();
}

fn dominant<K: std::fmt::Display>(map: &HashMap<K, u64>) -> Option<(String, u64)> {
    map.iter()
        .max_by_key(|(_, v)| *v)
        .map(|(k, v)| (k.to_string(), *v))
}

fn main() {
    let path = behavior_path();
    let data = match fs::read_to_string(&path) {
        Ok(s) => match serde_json::from_str::<Behavior>(&s) {
            Ok(b) => b,
            Err(_) => return,
        },
        Err(_) => return,
    };

    let last: LastDecision = fs::read_to_string(decision_path())
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or(LastDecision {
            focus_suggest: None,
            ambient: None,
        });

    let today = chrono_today();
    let mut next = LastDecision {
        focus_suggest: last.focus_suggest.clone(),
        ambient: last.ambient.clone(),
    };

    let hour = current_hour();
    let franja_now = franja_of(hour);

    if let Some((fk, _)) = dominant(&data.active_hours) {
        if fk == franja_now && data.focus_blocks.count >= 3 {
            let key = format!("{}-{}", today, franja_now);
            if last.focus_suggest.as_deref() != Some(&key) {
                let avg = data.focus_blocks.avg_min;
                notify(
                    "BlackNode",
                    &format!(
                        "Your {} block usually starts now. Want a {} min focus session?",
                        franja_now, avg
                    ),
                );
                next.focus_suggest = Some(key);
            }
        }
    }

    if let Some((fk, _)) = dominant(&data.active_hours) {
        if fk != last.ambient.as_deref().unwrap_or("") {
            apply_ambient(&fk);
            next.ambient = Some(fk);
        }
    }

    let _ = fs::write(
        decision_path(),
        serde_json::to_string_pretty(&next).unwrap_or_default(),
    );
}

fn current_hour() -> u32 {
    let out = Command::new("date").args(["+%H"]).output().ok();
    out.and_then(|o| String::from_utf8(o.stdout).ok())
        .and_then(|s| s.trim().parse::<u32>().ok())
        .unwrap_or(12)
}

fn franja_of(h: u32) -> String {
    match h {
        0..=4 => "late",
        5..=7 => "dawn",
        8..=11 => "morning",
        12..=13 => "noon",
        14..=17 => "afternoon",
        18..=21 => "evening",
        _ => "night",
    }
    .into()
}

fn chrono_today() -> String {
    let out = Command::new("date").args(["+%Y-%m-%d"]).output().ok();
    out.and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_default()
        .trim()
        .into()
}

fn apply_ambient(franja: &str) {
    let mode = match franja {
        "late" | "night" => "night",
        "dawn" | "morning" => "day",
        "noon" | "afternoon" => "day",
        "evening" => "dusk",
        _ => "day",
    };
    let _ = Command::new("matugen")
        .args(["image", "-m", "dark", mode])
        .status();
}
