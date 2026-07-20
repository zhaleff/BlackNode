//! Inferred context: the brain's current belief about what the user is doing.
//!
//! Algorithms feed evidence (knowledge); this module fuses it into a single
//! `Activity` belief stored in the shared `Context`. The DecisionEngine reads
//! that belief to choose actions. It is working memory, not a stored metric.

use crate::bus::{Bus, Knowledge};
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
            "activity={:?} conf={:.0}% focus_min={:.0} distract={:.1} profile={} app={} ctx={}",
            self.activity,
            self.confidence * 100.0,
            self.focus_min,
            self.distract_pressure,
            self.active_profile,
            self.top_app,
            self.context_label
        )
    }
}

/// ContextEngine: fuse knowledge into a belief and store it. Runs its own
/// thread, subscribing to the knowledge bus.
pub fn run(bus: Arc<Bus>, ctx: Arc<Mutex<Context>>) {
    let mut focus = 0.0;
    let mut distract = 0.0;
    let mut instability = 0.0;
    let mut context_label = String::new();
    let mut last_window_ts = now_ms();
    loop {
        while let Ok(k) = bus.knowledge_rx().try_recv() {
            match k.claim.as_str() {
                "focus" => focus = k.value,
                "instability" => instability = k.value,
                "context" => context_label = format!("{:.2}", k.value),
                _ => {}
            }
        }
        while let Ok(_s) = bus.signal_rx().try_recv() {
            last_window_ts = now_ms();
        }
        let idle_for = now_ms().saturating_sub(last_window_ts);
        let (activity, conf) = infer(focus, distract, instability, idle_for);
        {
            let mut g = ctx.lock().unwrap();
            g.focus_min = focus * 25.0;
            g.distract_pressure = distract;
            g.activity = activity;
            g.confidence = conf;
            g.context_label = context_label.clone();
        }
        std::thread::sleep(std::time::Duration::from_millis(500));
    }
}

fn infer(focus: f64, _distract: f64, instability: f64, idle_for: u64) -> (Activity, f64) {
    if idle_for > 5 * 60 * 1000 {
        return (Activity::Idle, 0.8);
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
