//! Inferred context: the brain's current belief about the whole desktop.
//!
//! Algorithms and collectors feed evidence (knowledge + signals); this module
//! fuses it into a single `Context` belief stored in shared state for the
//! DecisionEngine and for inspection (`blacknode brain status`). It is working
//! memory, not a stored metric: it models relationships (what you are doing,
//! for how long, on what power, with what connectivity), not raw telemetry.

use crate::bus::Bus;
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Clone, Default, serde::Serialize, serde::Deserialize)]
pub struct Context {
    pub activity: Activity,
    pub confidence: f64,
    pub focus_min: f64,
    pub distract_pressure: f64,
    pub active_profile: String,
    pub top_app: String,
    pub context_label: String,
    /// Minutes since the last window change (idle awareness).
    pub idle_min: f64,
    /// Currently playing media (a known media app is focused/active).
    pub music: bool,
    /// Battery level percent, or -1 when unknown / no battery.
    pub battery: f64,
    /// True when running on battery, false on AC.
    pub on_battery: bool,
    /// True when a network link is up.
    pub network: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Default, serde::Serialize, serde::Deserialize)]
pub enum Activity {
    #[default]
    Unknown,
    DeepWork,
    Browsing,
    Media,
    Idle,
    ContextSwitching,
}

impl Context {
    pub fn describe(&self) -> String {
        format!(
            "activity={:?} conf={:.0}% focus_min={:.0} distract={:.1} profile={} app={} ctx={} idle={:.0}m music={} bat={:.0} ac={} net={}",
            self.activity,
            self.confidence * 100.0,
            self.focus_min,
            self.distract_pressure,
            self.active_profile,
            self.top_app,
            self.context_label,
            self.idle_min,
            self.music,
            self.battery,
            !self.on_battery,
            self.network,
        )
    }
}

const MEDIA_APPS: &[&str] = &["spotify", "vlc", "mpv", "youtube-music", "rhythmbox"];

/// ContextEngine: fuse knowledge + signals into a belief and store it. Runs
/// its own thread, subscribing to the knowledge and signal buses.
pub fn run(bus: Arc<Bus>, ctx: Arc<Mutex<Context>>) {
    let mut focus = 0.0;
    let mut distract = 0.0;
    let mut instability = 0.0;
    let mut context_label = String::new();
    let mut top_app = String::new();
    let mut battery = -1.0;
    let mut on_battery = false;
    let mut network = false;
    let mut last_window_ts = now_ms();
    let sig = bus.signal_rx();
    let kn = bus.knowledge_rx();
    loop {
        while let Ok(k) = kn.try_recv() {
            match k.claim.as_str() {
                "focus" => focus = k.value,
                "distract" => distract = k.value,
                "instability" => instability = k.value,
                "context" => context_label = format!("{:.2}", k.value),
                _ => {}
            }
        }
        while let Ok(s) = sig.try_recv() {
            last_window_ts = now_ms();
            match s.kind.as_str() {
                "window" => top_app = s.value.clone(),
                "battery" => battery = s.value.parse().unwrap_or(-1.0),
                "power" => on_battery = s.value == "battery",
                "network" => network = s.value == "up",
                _ => {}
            }
        }
        let idle_min = (now_ms().saturating_sub(last_window_ts) as f64) / 60000.0;
        let music = MEDIA_APPS.iter().any(|m| top_app.to_lowercase().contains(m));
        let (activity, conf) = infer(focus, distract, instability, idle_min, &top_app);
        {
            let mut g = ctx.lock().unwrap();
            g.focus_min = focus * 25.0;
            g.distract_pressure = distract;
            g.activity = activity;
            g.confidence = conf;
            g.context_label = context_label.clone();
            g.top_app = top_app.clone();
            g.idle_min = idle_min;
            g.music = music;
            g.battery = battery;
            g.on_battery = on_battery;
            g.network = network;
        }
        std::thread::sleep(std::time::Duration::from_millis(500));
    }
}

fn infer(
    focus: f64,
    _distract: f64,
    instability: f64,
    idle_min: f64,
    top_app: &str,
) -> (Activity, f64) {
    let app = top_app.to_lowercase();
    if MEDIA_APPS.iter().any(|m| app.contains(m)) {
        return (Activity::Media, 0.9);
    }
    if idle_min > 5.0 {
        return (Activity::Idle, (0.6 + idle_min / 60.0).min(0.95));
    }
    if instability > 0.6 {
        return (Activity::ContextSwitching, instability);
    }
    if focus > 0.7 {
        return (Activity::DeepWork, focus);
    }
    if focus < 0.3 {
        return (Activity::Browsing, 1.0 - focus);
    }
    (Activity::Browsing, 0.4)
}

fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}
