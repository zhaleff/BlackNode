//! EWMA focus tracker.
//!
//! Maintains a smoothed estimate of how focused the user is right now, from
//! focus/distract signals. Publishes `focus` knowledge in [0,1]. Low alpha =
//! stable, ignores single spikes. This is a primitive the DecisionEngine
//! combines with others; it is not shown to the user.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};

pub struct Ewma {
    alpha: f64,
    value: f64,
}

impl Ewma {
    pub fn new(alpha: f64) -> Box<Self> {
        Box::new(Ewma { alpha, value: 0.0 })
    }
}

impl Algorithm for Ewma {
    fn name(&self) -> &str {
        "ewma"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut value = self.value;
        let alpha = self.alpha;
        loop {
            let signals = {
                let mut v = Vec::new();
                while let Ok(s) = bus.signal_rx().try_recv() {
                    v.push(s);
                }
                v
            };
            let mut sample = value;
            for s in &signals {
                sample = match s.kind.as_str() {
                    "focus" => 1.0,
                    "distract" => 0.0,
                    _ => sample,
                };
            }
            if signals.iter().any(|s| s.kind == "focus" || s.kind == "distract") {
                value = alpha * sample + (1.0 - alpha) * value;
                bus.publish_knowledge(Knowledge::new("ewma", "focus", value, 0.6));
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}
