use super::core::*;

pub struct NodeGraph {
    nodes: Vec<Box<dyn Node>>,
}

pub struct TickResult {
    pub signals: Vec<Signal>,
    pub decisions: Vec<Signal>,
    pub state: BrainState,
}

impl NodeGraph {
    pub fn new() -> Self {
        Self { nodes: vec![] }
    }

    pub fn add(&mut self, node: impl Node) {
        self.nodes.push(Box::new(node));
    }

    pub fn tick(&mut self) -> TickResult {
        let mut state = BrainState::default();

        // 1) Sensor poll — collect environment state
        let mut signals: Vec<Signal> = vec![];
        for n in &mut self.nodes {
            signals.extend(n.process(&[], &mut state));
        }

        // 2) Context propagation — up to 4 passes for signal chains
        for _ in 0..4 {
            let mut next: Vec<Signal> = vec![];
            for n in &mut self.nodes {
                next.extend(n.process(&signals, &mut state));
            }
            if next.is_empty() {
                break;
            }
            signals = next;
        }

        // 3) Collect decisions from the last pass
        let decisions: Vec<Signal> = signals.iter()
            .filter(|s| s.kind.starts_with("decision/"))
            .cloned()
            .collect();

        TickResult { signals, decisions, state }
    }
}