//! Bayesian focus probability by hour.
//!
//! Learns P(focus | hour) into durable [`Memory`] and publishes the current
//! hour's focus probability as `Knowledge`. Over weeks this becomes a reliable
//! prior the DecisionEngine can act on before you even start focusing.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};
use std::sync::Arc;

pub struct Bayes;

impl Bayes {
    pub fn new() -> Box<Self> {
        Box::new(Bayes)
    }
}

fn hour_now() -> u8 {
    use std::time::{SystemTime, UNIX_EPOCH};
    let s = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    ((s / 3600) % 24) as u8
}

impl Algorithm for Bayes {
    fn name(&self) -> &str {
        "bayes"
    }
    fn run(self: Box<Self>, bus: Arc<Bus>) {
        let mem = bus.memory();
        let sig = bus.signal_rx();
        let mut last_pub = 0u64;
        loop {
            while let Ok(s) = sig.try_recv() {
                if s.kind == "focus" {
                    mem.observe_focus(hour_now(), true);
                } else if s.kind == "distract" {
                    mem.observe_focus(hour_now(), false);
                }
            }
            let now = now_ms();
            if now - last_pub > 1000 {
                last_pub = now;
                let h = hour_now();
                let p = mem.focus_prob(h);
                let conf = (mem.total_samples(h) / (mem.total_samples(h) + 10.0)).min(0.9);
                bus.publish_knowledge(Knowledge::new("bayes", "focus_hour", p, conf));
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}

fn now_ms() -> u64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}
