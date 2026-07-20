//! Collector trait + concrete signal sources.
//!
//! A collector turns outside-world events into `Signal`s on the bus. Signals
//! are deliberately raw: `window` (active app changed), `focus` / `distract`
//! (from blacknode-learn.py), `profile` (session switch). The algorithms do
//! the interpreting.

use crate::bus::{Bus, Signal};
use std::process::Command;

pub trait Collector: Send {
    fn name(&self) -> &str;
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>);
}

fn hyprctl(args: &[&str]) -> Option<String> {
    Command::new("hyprctl")
        .args(args)
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
}

/// Polls hyprctl for the active window class and emits a `window` signal on
/// change. This is the primary context signal for the context graph / markov.
pub struct Hyprland {
    interval_ms: u64,
}

impl Hyprland {
    pub fn new(interval_ms: u64) -> Box<Self> {
        Box::new(Hyprland { interval_ms })
    }
}

impl Collector for Hyprland {
    fn name(&self) -> &str {
        "hyprland"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut last = String::new();
        loop {
            if let Some(out) = hyprctl(&["activewindow", "-j"]) {
                let app = extract_class(&out).unwrap_or_default();
                if !app.is_empty() && app != last {
                    last = app.clone();
                    bus.publish_signal(Signal::new("window", &app));
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(self.interval_ms));
        }
    }
}

fn extract_class(json: &str) -> Option<String> {
    let start = json.find("\"class\"")?;
    let rest = &json[start + 8..];
    let q = rest.find('"')?;
    let end = rest[q + 1..].find('"')?;
    Some(rest[q + 1..q + 1 + end].to_string())
}

/// Watches `~/.local/share/blacknode/behavior.json` for new focus/distract/
/// profile events written by blacknode-learn.py and forwards them as signals.
pub struct BehaviorFile {
    path: std::path::PathBuf,
}

impl BehaviorFile {
    pub fn new() -> Box<Self> {
        let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
        let path = std::path::Path::new(&home).join(".local/share/blacknode/behavior.json");
        Box::new(BehaviorFile { path })
    }
}

impl Collector for BehaviorFile {
    fn name(&self) -> &str {
        "behavior_file"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut last_len = read_len(&self.path);
        loop {
            std::thread::sleep(std::time::Duration::from_millis(500));
            let cur = read_len(&self.path);
            if cur < last_len {
                last_len = cur;
            }
            if cur > last_len {
                if let Some(tail) = tail(&self.path, last_len) {
                    for line in tail.lines() {
                        forward(line, &bus);
                    }
                }
                last_len = cur;
            }
        }
    }
}

fn read_len(p: &std::path::Path) -> u64 {
    std::fs::metadata(p).map(|m| m.len()).unwrap_or(0)
}

fn tail(p: &std::path::Path, from: u64) -> Option<String> {
    let data = std::fs::read(p).ok()?;
    let from = from.min(data.len() as u64) as usize;
    String::from_utf8(data[from..].to_vec()).ok()
}

fn forward(line: &str, bus: &Bus) {
    let kind = if line.contains("\"focus\"") {
        "focus"
    } else if line.contains("\"distract\"") {
        "distract"
    } else if line.contains("\"profile\"") {
        "profile"
    } else if line.contains("\"session\"") {
        "session"
    } else {
        return;
    };
    bus.publish_signal(Signal::new(kind, line.trim()));
}

mod system;
pub use system::System;
