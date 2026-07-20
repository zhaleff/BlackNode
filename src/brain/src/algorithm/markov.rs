//! Markov transition model over active application classes.
//!
//! Counts (prev_app -> app) transitions and publishes, for the current app,
//! the most likely next app plus a confidence. Lets the DecisionEngine infer
//! routine: if the next app is the expected one, the user is in flow.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge, Signal};
use std::collections::HashMap;

pub struct Markov {
    counts: HashMap<(String, String), u64>,
    totals: HashMap<String, u64>,
    prev: Option<String>,
}

impl Markov {
    pub fn new() -> Box<Self> {
        Box::new(Markov {
            counts: HashMap::new(),
            totals: HashMap::new(),
            prev: None,
        })
    }
}

impl Algorithm for Markov {
    fn name(&self) -> &str {
        "markov"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut m = *self;
        loop {
            while let Ok(s) = bus.signal_rx().try_recv() {
                if s.kind == "window" {
                    let app = s.value.clone();
                    if let Some(p) = m.prev.take() {
                        *m.counts.entry((p.clone(), app.to_string())).or_insert(0) += 1;
                        *m.totals.entry(p).or_insert(0) += 1;
                    }
                    m.prev = Some(app.to_string());
                    if let Some(p) = m.prev.clone() {
                        if let Some(&total) = m.totals.get(&p) {
                            if total > 0 {
                                let mut best: Option<(String, f64)> = None;
                                for ((from, to), c) in m.counts.iter() {
                                    if from == &p {
                                        let conf = *c as f64 / total as f64;
                                        if best.as_ref().map(|(_, b)| conf > *b).unwrap_or(true) {
                                            best = Some((to.clone(), conf));
                                        }
                                    }
                                }
                                if let Some((to, conf)) = best {
                                    bus.publish_knowledge(Knowledge::new(
                                        "markov",
                                        &format!("next:{}", to),
                                        conf,
                                        conf,
                                    ));
                                }
                            }
                        }
                    }
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}
