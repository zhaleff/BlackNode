//! Event bus: the single channel every stage communicates through.
//!
//! Collectors publish [`Signal`]s. Algorithms subscribe and publish
//! [`Knowledge`]. The DecisionEngine subscribes to Knowledge and emits
//! [`Decision`]. The ActionEngine subscribes to Decision and executes.
//!
//! A `Bus` is just crossbeam channels behind a small API. It is intentionally
//! dumb: routing logic lives in the engine, not here.

use crossbeam_channel::{unbounded, Receiver, Sender};
use std::time::{SystemTime, UNIX_EPOCH};

/// A raw observation from a collector (window change, focus block, etc).
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Signal {
    pub kind: String,
    pub value: String,
    pub ts: u64,
}

impl Signal {
    pub fn new(kind: &str, value: &str) -> Self {
        Signal {
            kind: kind.to_string(),
            value: value.to_string(),
            ts: now_ms(),
        }
    }
}

/// Output of an algorithm: a claim about the world with a confidence.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Knowledge {
    pub source: String,
    pub claim: String,
    pub value: f64,
    pub confidence: f64,
    pub ts: u64,
}

impl Knowledge {
    pub fn new(source: &str, claim: &str, value: f64, confidence: f64) -> Self {
        Knowledge {
            source: source.to_string(),
            claim: claim.to_string(),
            value,
            confidence,
            ts: now_ms(),
        }
    }
}

/// A decision emitted by the DecisionEngine, consumed by the ActionEngine.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Decision {
    pub action: String,
    pub params: std::collections::HashMap<String, String>,
    pub reason: Vec<String>,
    pub confidence: f64,
    pub ts: u64,
}

impl Decision {
    pub fn new(action: &str) -> Self {
        Decision {
            action: action.to_string(),
            params: std::collections::HashMap::new(),
            reason: Vec::new(),
            confidence: 1.0,
            ts: now_ms(),
        }
    }
    pub fn param(mut self, k: &str, v: &str) -> Self {
        self.params.insert(k.to_string(), v.to_string());
        self
    }
    pub fn because(mut self, line: &str) -> Self {
        self.reason.push(line.to_string());
        self
    }
    pub fn confidence(mut self, c: f64) -> Self {
        self.confidence = c;
        self
    }
}

/// The bus: three independent broadcast-ish channels.
pub struct Bus {
    signal_tx: Sender<Signal>,
    signal_rx: Receiver<Signal>,
    knowledge_tx: Sender<Knowledge>,
    knowledge_rx: Receiver<Knowledge>,
    decision_tx: Sender<Decision>,
    decision_rx: Receiver<Decision>,
}

impl Bus {
    pub fn new() -> Self {
        let (signal_tx, signal_rx) = unbounded();
        let (knowledge_tx, knowledge_rx) = unbounded();
        let (decision_tx, decision_rx) = unbounded();
        Bus {
            signal_tx,
            signal_rx,
            knowledge_tx,
            knowledge_rx,
            decision_tx,
            decision_rx,
        }
    }

    pub fn publish_signal(&self, s: Signal) {
        let _ = self.signal_tx.send(s);
    }
    pub fn publish_knowledge(&self, k: Knowledge) {
        let _ = self.knowledge_tx.send(k);
    }
    pub fn publish_decision(&self, d: Decision) {
        let _ = self.decision_tx.send(d);
    }

    pub fn signal_rx(&self) -> &Receiver<Signal> {
        &self.signal_rx
    }
    pub fn knowledge_rx(&self) -> &Receiver<Knowledge> {
        &self.knowledge_rx
    }
    pub fn decision_rx(&self) -> &Receiver<Decision> {
        &self.decision_rx
    }
}

pub fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}
