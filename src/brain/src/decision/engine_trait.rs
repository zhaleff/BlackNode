//! DecisionEngine trait: turns knowledge into decisions.
//!
//! Subscribes to Knowledge and the shared context, and emits `Decision`s when
//! evidence crosses a threshold. The concrete engine lives in `mod.rs`; this
//! trait exists so alternative decision logic can be plugged in.

use crate::bus::{Bus, Decision, Knowledge};
use crate::context::Context;
use std::sync::{Arc, Mutex};

pub trait DecisionEngine: Send {
    fn name(&self) -> &str;
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>, ctx: Arc<Mutex<Context>>);
    fn drain_knowledge(&self, bus: &Bus) -> Vec<Knowledge> {
        let mut out = Vec::new();
        while let Ok(k) = bus.knowledge_rx().try_recv() {
            out.push(k);
        }
        out
    }
    fn decide(&mut self, k: &[Knowledge], ctx: &Context) -> Vec<Decision>;
}
