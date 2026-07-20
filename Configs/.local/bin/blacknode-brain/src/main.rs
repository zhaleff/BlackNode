//! blacknode-brain: local intelligence engine / daemon.
//!
//! Spawns the scheduler on its own thread, captures from Hyprland (or stdin
//! for `--stdin` testing), runs the plugin ensemble, and persists state
//! atomically. The `FocusCoach` plugin performs the system adaptation that
//! previously lived in `blacknode-adapt`: focus suggestions + ambient via
//! matugen, calm-by-default (low urgency, once per key).

use blacknode_brain::api::{ActionSink, EngineApi};
use blacknode_brain::capture::{ChannelSource, HyprlandSource};
use blacknode_brain::predictor::Prediction;
use blacknode_brain::scheduler::Scheduler;
use crossbeam_channel::unbounded;
use std::collections::HashSet;
use std::path::PathBuf;
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let (tx, rx) = unbounded();
    let source = ChannelSource::new(rx);
    let use_stdin = std::env::args().any(|a| a == "--stdin");

    if use_stdin {
        let tx2 = tx.clone();
        thread::spawn(move || HyprlandSource::from_stdin(tx2));
    } else {
        let tx2 = tx.clone();
        thread::spawn(move || HyprlandSource::spawn(tx2));
    }

    let sched = Arc::new(Mutex::new(Scheduler::new(source, 4096, 1000, 30)));
    let sched_run = Arc::clone(&sched);
    thread::spawn(move || {
        sched_run.lock().unwrap().run();
    });

    let mut plugins: Vec<Box<dyn EngineApi>> = vec![Box::new(FocusCoach::new())];
    let seen = Arc::new(Mutex::new(HashSet::new()));

    loop {
        thread::sleep(std::time::Duration::from_millis(1000));
        let p: Prediction = {
            let s = sched.lock().unwrap();
            s.predict()
        };
        let sink = SystemSink;
        let seen_ref = Arc::clone(&seen);
        for plugin in &mut plugins {
            plugin.on_predict(&p, &sink, &|k| {
                let mut g = seen_ref.lock().unwrap();
                g.insert(k.to_string())
            });
        }
    }
}

/// Real sink: shells out to notify-send (low urgency) and matugen.
struct SystemSink;
impl ActionSink for SystemSink {
    fn notify(&self, title: &str, body: &str) {
        let _ = Command::new("notify-send")
            .args(["-a", "BlackNode", "-u", "low", title, body])
            .status();
    }
    fn ambient(&self, mode: &str) {
        let _ = Command::new("matugen").args(["image", "-m", "dark", mode]).status();
    }
}

fn state_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join(".local/share/blacknode")
}

fn decision_path() -> PathBuf {
    state_dir().join("brain_last.json")
}

fn read_decision() -> std::collections::HashMap<String, String> {
    let data = std::fs::read_to_string(decision_path()).unwrap_or_default();
    serde_json::from_str(&data).unwrap_or_default()
}

fn save_decision(d: &std::collections::HashMap<String, String>) {
    if let Ok(s) = serde_json::to_string_pretty(d) {
        let _ = std::fs::write(decision_path(), s);
    }
}

fn current_hour() -> u32 {
    Command::new("date")
        .args(["+%H"])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .and_then(|s| s.trim().parse::<u32>().ok())
        .unwrap_or(12)
}

fn franja_of(h: u32) -> &'static str {
    match h {
        0..=4 => "late",
        5..=7 => "dawn",
        8..=11 => "morning",
        12..=13 => "noon",
        14..=17 => "afternoon",
        18..=21 => "evening",
        _ => "night",
    }
}

fn ambient_mode(franja: &str) -> &'static str {
    match franja {
        "late" | "night" => "night",
        "evening" => "dusk",
        _ => "day",
    }
}

/// Adaptation plugin: replaces blacknode-adapt. Acts on the live Prediction.
struct FocusCoach {
    last_ambient: Option<String>,
    last_focus_key: Option<String>,
}
impl FocusCoach {
    fn new() -> Self {
        let d = read_decision();
        FocusCoach {
            last_ambient: d.get("ambient").cloned(),
            last_focus_key: d.get("focus_key").cloned(),
        }
    }
    fn persist(&self) {
        let mut d = std::collections::HashMap::new();
        if let Some(a) = &self.last_ambient {
            d.insert("ambient".into(), a.clone());
        }
        if let Some(k) = &self.last_focus_key {
            d.insert("focus_key".into(), k.clone());
        }
        save_decision(&d);
    }
}
impl EngineApi for FocusCoach {
    fn name(&self) -> &str {
        "focus-coach"
    }
    fn on_predict(
        &mut self,
        p: &Prediction,
        sink: &dyn ActionSink,
        first_of_kind: &dyn Fn(&str) -> bool,
    ) {
        let today = Command::new("date")
            .args(["+%Y-%m-%d"])
            .output()
            .ok()
            .and_then(|o| String::from_utf8(o.stdout).ok())
            .unwrap_or_default()
            .trim()
            .to_string();
        let hour = current_hour();
        let franja = franja_of(hour);

        // Ambient by time-of-day: apply once per franja change.
        let mode = ambient_mode(franja);
        if self.last_ambient.as_deref() != Some(mode) {
            sink.ambient(mode);
            self.last_ambient = Some(mode.to_string());
            self.persist();
        }

        // Focus suggestion: low focus intensity but the user is active
        // (anomaly high) → suggest a pomodoro, once per day per franja.
        if p.focus_intensity < 0.3 && p.anomaly > 0.5 {
            let key = format!("{}-{}", today, franja);
            if self.last_focus_key.as_deref() != Some(&key) && first_of_kind(&key) {
                sink.notify(
                    "BlackNode",
                    &format!("Low focus signal this {franja} — want a pomodoro?"),
                );
                self.last_focus_key = Some(key);
                self.persist();
            }
        }
    }
}
