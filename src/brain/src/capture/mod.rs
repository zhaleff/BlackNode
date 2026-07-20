//! Event capture layer.
//!
//! Defines the canonical [`Event`] type and a [`CaptureSource`] trait so new
//! event producers (hyprland, x11, wayland, synthetic) can be plugged in
//! without touching the core. A [`ChannelSource`] adapts any source to a
//! `crossbeam_channel::Receiver<Event>` consumed by the scheduler.

use serde::{Deserialize, Serialize};
use std::time::{SystemTime, UNIX_EPOCH};

/// A single observation from the user's environment.
///
/// Events are intentionally minimal: a tag (what happened), a value
/// (the entity, e.g. window class or profile name) and a timestamp.
/// All higher-level meaning is derived later in `features`.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Event {
    /// Kind of event: `window`, `profile`, `focus`, `session`, `distract`.
    pub kind: String,
    /// Entity involved, e.g. window class `kitty` or profile `coding`.
    pub value: String,
    /// Unix epoch milliseconds.
    pub ts: u64,
}

impl Event {
    pub fn new(kind: &str, value: &str) -> Self {
        Event {
            kind: kind.to_string(),
            value: value.to_string(),
            ts: now_ms(),
        }
    }
}

pub fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

/// A producer of events. Implement this to add a new capture backend.
pub trait CaptureSource: Send {
    /// Blocking poll for the next event, or `None` if the source is closed.
    fn next_event(&mut self) -> Option<Event>;
}

/// Adapts any [`CaptureSource`] into a channel receiver.
///
/// Spawns a thread that drains the source and pushes into the channel,
/// decoupling slow/blocking producers from the consumer loop.
pub struct ChannelSource {
    rx: crossbeam_channel::Receiver<Event>,
}

impl ChannelSource {
    pub fn spawn<S>(mut source: S) -> Self
    where
        S: CaptureSource + 'static,
    {
        let (tx, rx) = crossbeam_channel::unbounded();
        std::thread::spawn(move || {
            while let Some(e) = source.next_event() {
                if tx.send(e).is_err() {
                    break;
                }
            }
        });
        ChannelSource { rx }
    }

    /// Build directly from an existing receiver (e.g. wired from main).
    pub fn new(rx: crossbeam_channel::Receiver<Event>) -> Self {
        ChannelSource { rx }
    }

    pub fn receiver(&self) -> &crossbeam_channel::Receiver<Event> {
        &self.rx
    }
}

/// Reads `kind value` lines from stdin (one per line) for testing/debugging.
///
/// Used by `blacknode-brain --stdin` so the engine can be fed synthetic
/// events without a running compositor.
impl HyprlandSource {
    pub fn spawn(tx: crossbeam_channel::Sender<Event>) {
        let mut src = HyprlandSource::new(1000);
        std::thread::spawn(move || loop {
            if let Some(e) = src.next_event() {
                if tx.send(e).is_err() {
                    break;
                }
            }
        });
    }

    pub fn from_stdin(tx: crossbeam_channel::Sender<Event>) {
        use std::io::BufRead;
        std::thread::spawn(move || {
            let stdin = std::io::stdin();
            for line in stdin.lock().lines().flatten() {
                let mut parts = line.split_whitespace();
                if let (Some(kind), Some(value)) = (parts.next(), parts.next()) {
                    let _ = tx.send(Event::new(kind, value));
                }
            }
        });
    }
}

/// A capture source backed by polling `hyprctl activewindow`.
///
/// Cost: one `hyprctl` call per `interval_ms`. No allocation beyond the
/// JSON parse. Only emits when the active class changes, keeping the
/// event stream sparse (low memory, low downstream cost).
pub struct HyprlandSource {
    last_class: Option<String>,
    interval_ms: u64,
}

impl HyprlandSource {
    pub fn new(interval_ms: u64) -> Self {
        HyprlandSource {
            last_class: None,
            interval_ms,
        }
    }
}

impl CaptureSource for HyprlandSource {
    fn next_event(&mut self) -> Option<Event> {
        std::thread::sleep(std::time::Duration::from_millis(self.interval_ms));
        let out = std::process::Command::new("hyprctl")
            .args(["activewindow", "-j"])
            .output()
            .ok()
            .and_then(|o| String::from_utf8(o.stdout).ok());
        let class = out
            .and_then(|s| serde_json::from_str::<serde_json::Value>(&s).ok())
            .and_then(|v| v.get("class").and_then(|c| c.as_str()).map(str::to_string));
        match class {
            Some(c) if self.last_class.as_deref() != Some(&c) => {
                self.last_class = Some(c.clone());
                Some(Event::new("window", &c))
            }
            _ => Some(Event::new("window", self.last_class.as_deref().unwrap_or("unknown"))),
        }
    }
}
