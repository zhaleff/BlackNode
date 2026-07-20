//! Reinforcement: contextual bandit over desktop actions.
//!
//! Each action type has a weight per context. When a decision is acted on, we
//! watch the next focus/distract signal: a focus bump raises the weight
//! (the action helped), a distract bump lowers it. Over time the brain stops
//! proposing actions that do not actually help this user. This is the
//! self-improvement loop — no hard-coded rules survive if they do not earn
//! reward.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Signal};
use std::collections::HashMap;
use std::sync::Mutex;

pub struct Reinforcement {
    weights: Mutex<HashMap<(String, String), f64>>,
    pending: Mutex<Vec<(String, String, f64)>>,
}

impl Reinforcement {
    pub fn new() -> Box<Self> {
        Box::new(Reinforcement {
            weights: Mutex::new(HashMap::new()),
            pending: Mutex::new(Vec::new()),
        })
    }

    fn learn(&self, action: &str, ctx: &str, reward: f64) {
        let mut w = self.weights.lock().unwrap();
        let e = w.entry((ctx.to_string(), action.to_string())).or_insert(0.5);
        *e = (*e + reward * 0.1).clamp(0.0, 1.0);
    }

    fn score(&self, action: &str, ctx: &str) -> f64 {
        let w = self.weights.lock().unwrap();
        *w.get(&(ctx.to_string(), action.to_string())).unwrap_or(&0.5)
    }
}

impl Algorithm for Reinforcement {
    fn name(&self) -> &str {
        "reinforcement"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let r = *self;
        loop {
            while let Ok(s) = bus.signal_rx().try_recv() {
                if s.kind == "focus" || s.kind == "distract" {
                    let reward = if s.kind == "focus" { 0.3 } else { -0.3 };
                    let mut pend = r.pending.lock().unwrap();
                    for (action, ctx, _) in pend.drain(..) {
                        r.learn(&action, &ctx, reward);
                    }
                }
            }
            while let Ok(d) = bus.decision_rx().try_recv() {
                let ctx = d
                    .params
                    .get("context")
                    .cloned()
                    .unwrap_or_else(|| "unknown".into());
                let mut pend = r.pending.lock().unwrap();
                let score = r.score(&d.action, &ctx);
                pend.push((d.action.clone(), ctx, score));
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}
