//! Context graph: temporal co-occurrence graph of applications.
//!
//! Edges connect apps used close in time. A connected cluster of apps is a
//! "context" (e.g. code editor + terminal + browser = coding). The algorithm
//! publishes the current context label = the most frequent app in the active
//! cluster. This is what lets the HUD and actions know *what* the user is
//! doing, not just how focused.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};
use std::collections::{HashMap, HashSet};

pub struct ContextGraph {
    edges: HashMap<String, HashSet<String>>,
    last: Option<(String, u64)>,
    window_ms: u64,
}

impl ContextGraph {
    pub fn new(window_ms: u64) -> Box<Self> {
        Box::new(ContextGraph {
            edges: HashMap::new(),
            last: None,
            window_ms,
        })
    }
}

impl Algorithm for ContextGraph {
    fn name(&self) -> &str {
        "context_graph"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut g = *self;
        let sig = bus.signal_rx();
        loop {
            while let Ok(s) = sig.try_recv() {
                if s.kind == "window" {
                    let app = s.value.clone();
                    if let Some((prev, ts)) = g.last.take() {
                        if s.ts.saturating_sub(ts) < g.window_ms {
                            g.edges.entry(prev.clone()).or_default().insert(app.clone());
                            g.edges.entry(app.clone()).or_default().insert(prev);
                        }
                    }
                    g.last = Some((app, s.ts));
                    let label = dominant_cluster(&g.edges, &s.value);
                    if let Some(l) = label {
                        bus.publish_knowledge(Knowledge::new(
                            "context_graph",
                            "context",
                            hash01(&l),
                            0.7,
                        ));
                    }
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}

/// BFS the cluster containing `start`, return the most common node.
fn dominant_cluster(edges: &HashMap<String, HashSet<String>>, start: &str) -> Option<String> {
    let mut seen = HashSet::new();
    let mut stack = vec![start.to_string()];
    let mut counts: HashMap<String, u64> = HashMap::new();
    while let Some(n) = stack.pop() {
        if !seen.insert(n.clone()) {
            continue;
        }
        *counts.entry(n.clone()).or_insert(0) += 1;
        if let Some(neigh) = edges.get(&n) {
            for m in neigh {
                if !seen.contains(m) {
                    stack.push(m.clone());
                }
            }
        }
    }
    counts
        .into_iter()
        .max_by_key(|(_, c)| *c)
        .map(|(k, _)| k)
}

fn hash01(s: &str) -> f64 {
    let mut h: u64 = 1469598103934665603;
    for b in s.as_bytes() {
        h ^= *b as u64;
        h = h.wrapping_mul(1099511628211);
    }
    (h % 1000) as f64 / 1000.0
}
