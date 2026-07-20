//! DecisionEngine trait: turns knowledge into decisions.
//!
//! Subscribes to Knowledge, maintains an inferred context, and emits
//! `Decision`s when the evidence crosses a threshold. The concrete engine
//! lives in `decision/`. This trait exists so alternative decision logic can
//! be plugged in.

use crate::bus::{Bus, Decision, Knowledge};

pub trait DecisionEngine: Send {
    fn name(&self) -> &str;
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>);
    fn drain_knowledge(&self, bus: &Bus) -> Vec<Knowledge> {
        let mut out = Vec::new();
        while let Ok(k) = bus.knowledge_rx().try_recv() {
            out.push(k);
        }
        out
    }
    fn decide(&mut self, k: &[Knowledge]) -> Vec<Decision>;
}
