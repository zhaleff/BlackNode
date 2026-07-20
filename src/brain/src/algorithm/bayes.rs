//! Naive-Bayes-style focus probability by hour.
//!
//! Learns P(focus | hour) incrementally: for each focus/distract signal it
//! bumps the count for the current hour, then publishes the focus
//! probability for the current hour. This is how the brain knows "at 22:00
//! you are almost always focused" and can act preemptively.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};

pub struct Bayes {
    focus: [u64; 24],
    total: [u64; 24],
}

impl Bayes {
    pub fn new() -> Box<Self> {
        Box::new(Bayes {
            focus: [0; 24],
            total: [0; 24],
        })
    }
    fn hour() -> usize {
        chrono_now_hour()
    }
}

fn chrono_now_hour() -> usize {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    ((secs / 3600) % 24) as usize
}

impl Algorithm for Bayes {
    fn name(&self) -> &str {
        "bayes"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut b = *self;
        loop {
            while let Ok(s) = bus.signal_rx().try_recv() {
                if s.kind == "focus" || s.kind == "distract" {
                    let h = Bayes::hour();
                    b.total[h] += 1;
                    if s.kind == "focus" {
                        b.focus[h] += 1;
                    }
                }
            }
            let h = Bayes::hour();
            if b.total[h] > 0 {
                let p = b.focus[h] as f64 / b.total[h] as f64;
                let conf = (b.total[h] as f64 / (b.total[h] as f64 + 10.0)).min(0.9);
                bus.publish_knowledge(Knowledge::new("bayes", "focus_hour", p, conf));
            }
            std::thread::sleep(std::time::Duration::from_millis(1000));
        }
    }
}
