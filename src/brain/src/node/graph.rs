use crate::node::core::*;

/// Accumulated result of a single tick.
pub struct TickResult {
    /// All signals from the final propagation pass.
    pub signals: Vec<Signal>,
    /// Decision signals collected across ALL passes (never lost).
    pub decisions: Vec<Signal>,
}

pub struct NodeGraph {
    nodes: Vec<Box<dyn Node>>,
}

impl NodeGraph {
    pub fn new() -> Self {
        Self { nodes: Vec::new() }
    }

    pub fn add<N: Node>(&mut self, node: N) {
        self.nodes.push(Box::new(node));
    }

    pub fn nodes(&self) -> &[Box<dyn Node>] {
        &self.nodes
    }

    /// Run one tick: propagate signals for PROPAGATION_DEPTH passes, then
    /// return a TickResult with both the last-pass signals and any
    /// decision-prefixed signals seen across every pass.
    pub fn tick(&mut self) -> TickResult {
        let mut signals: Vec<Signal> = Vec::new();
        let mut decisions = Vec::new();

        for _ in 0..PROPAGATION_DEPTH {
            let mut next = Vec::new();
            for node in &mut self.nodes {
                let emitted = node.process(&signals);
                // Capture decision signals as they go by
                for s in &emitted {
                    if s.kind.starts_with("decision/") {
                        decisions.push(s.clone());
                    }
                }
                next.extend(emitted);
            }
            signals = next;
        }

        TickResult { signals, decisions }
    }
}
