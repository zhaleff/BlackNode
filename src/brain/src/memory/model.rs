//! Serializable memory layout.
//!
//! Knowledge is stored as timestamped counters so the store can decay them.
//! Nothing here is raw telemetry: it is compressed, decision-relevant belief
//! (e.g. "at 22h, spotify has weight 14", not "window changed 900 times").

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// A timestamped, decaying counter for one observed item.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppCount {
    pub app: String,
    /// Accumulated (decayed) weight for this app in this bucket.
    pub weight: f64,
    /// Last time this app was observed here, in ms since epoch.
    pub last: u64,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Model {
    /// hour (0-23) -> apps the user opens then, with decaying weights.
    pub routines: HashMap<u8, Vec<AppCount>>,
    /// Per-hour accumulated focus weight and sample count.
    pub focus: [f64; 24],
    pub total: [f64; 24],
    /// from app -> next apps the user moves to, with decaying weights.
    pub transitions: HashMap<String, Vec<AppCount>>,
    /// Schema version, for forward-compatible migrations.
    pub version: u32,
}

impl Model {
    pub fn new() -> Self {
        Model {
            routines: HashMap::new(),
            focus: [0.0; 24],
            total: [0.0; 24],
            transitions: HashMap::new(),
            version: 1,
        }
    }
}
