//! Algorithm trait: turns signals into knowledge.
//!
//! An algorithm subscribes to the bus, updates its internal incremental
//! model, and publishes `Knowledge` claims. Algorithms are the only place
//! where ML lives (EWMA, Markov, Bayes, KMeans, anomaly, context graph,
//! reinforcement). Each is a module under `algorithm/`.

use crate::bus::{Bus, Knowledge, Signal};

pub trait Algorithm: Send {
    fn name(&self) -> &str;
    /// Called once on startup to spawn the algorithm's loop.
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>);
    /// Convenience: publish a knowledge claim.
    fn emit(&self, bus: &Bus, source: &str, claim: &str, value: f64, confidence: f64) {
        bus.publish_knowledge(Knowledge::new(source, claim, value, confidence));
    }
    /// Pull pending signals without blocking. Returns collected signals.
    fn drain(&self, bus: &Bus) -> Vec<Signal> {
        let mut out = Vec::new();
        while let Ok(s) = bus.signal_rx().try_recv() {
            out.push(s);
        }
        out
    }
}
