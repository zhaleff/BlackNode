//! Routine learner: discovers "at hour H the user usually opens app A".
//!
//! Watches `window` signals and keeps a fixed-size tally hour -> app -> count.
//! When the current hour's most likely app passes a confidence floor it
//! publishes a `routine:<app>` knowledge claim. The DecisionEngine turns that
//! into a LaunchApp decision, and the action asks the user before opening
//! (the brain never launches anything blindly).

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};
use std::collections::HashMap;

pub struct Routine {
    counts: HashMap<(u8, String), u64>,
    totals: HashMap<u8, u64>,
    seen_hour_app: HashMap<(u8, String), bool>,
}

impl Routine {
    pub fn new() -> Box<Self> {
        Box::new(Routine {
            counts: HashMap::new(),
            totals: HashMap::new(),
            seen_hour_app: HashMap::new(),
        })
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

impl Algorithm for Routine {
    fn name(&self) -> &str {
        "routine"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut r = *self;
        loop {
            let mut changed = false;
            while let Ok(s) = bus.signal_rx().try_recv() {
                if s.kind == "window" {
                    let app = s.value.clone();
                    let h = hour_now();
                    *r.counts.entry((h, app.clone())).or_insert(0) += 1;
                    *r.totals.entry(h).or_insert(0) += 1;
                    r.seen_hour_app.insert((h, app), true);
                    changed = true;
                }
            }
            if changed {
                let h = hour_now();
                if let Some(&total) = r.totals.get(&h) {
                    if total >= 3 {
                        let mut best: Option<(String, f64)> = None;
                        for ((hh, app), c) in r.counts.iter() {
                            if *hh == h {
                                let p = *c as f64 / total as f64;
                                if best.as_ref().map(|(_, b)| p > *b).unwrap_or(true) {
                                    best = Some((app.clone(), p));
                                }
                            }
                        }
                        if let Some((app, p)) = best {
                            let conf = (total as f64 / (total as f64 + 20.0)).min(0.95);
                            bus.publish_knowledge(Knowledge::new(
                                "routine",
                                &format!("routine:{}", app),
                                p,
                                conf,
                            ));
                        }
                    }
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(1000));
        }
    }
}
