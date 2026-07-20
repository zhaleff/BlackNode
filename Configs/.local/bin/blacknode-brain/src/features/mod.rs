//! Feature extraction.
//!
//! Converts the raw event stream into fixed-dimensional feature vectors over
//! sliding time windows. A feature vector is what algorithms consume; the
//! raw stream is never fed to models directly. This keeps models agnostic to
//! event shape and lets us swap feature extractors via the [`FeatureExtractor`]
//! trait.
//!
//! Window complexity: O(n) over events in the window, n bounded by log capacity.

use crate::capture::Event;
use crate::storage::EventLog;
use std::collections::HashMap;

/// Flattened feature vector for a time window.
#[derive(Debug, Clone, Default)]
pub struct Features {
    /// Total events in window.
    pub count: f64,
    /// Per-kind counts (window + session + profile + focus + distract + window).
    pub by_kind: HashMap<String, f64>,
    /// Per-value frequency for the `window` kind (app usage histogram).
    pub window_hist: HashMap<String, f64>,
    /// Inter-event mean gap in ms (rhythm signal).
    pub mean_gap_ms: f64,
}

/// Extracts features from a window of events.
pub trait FeatureExtractor: Send {
    fn extract(&self, events: &[Event]) -> Features;
}

/// Default extractor: counts + app histogram + mean inter-event gap.
pub struct DefaultExtractor;

impl FeatureExtractor for DefaultExtractor {
    fn extract(&self, events: &[Event]) -> Features {
        let mut f = Features::default();
        f.count = events.len() as f64;
        let mut prev: Option<u64> = None;
        let mut gap_sum = 0u64;
        let mut gap_n = 0u64;
        for e in events {
            *f.by_kind.entry(e.kind.clone()).or_insert(0.0) += 1.0;
            if e.kind == "window" {
                *f.window_hist.entry(e.value.clone()).or_insert(0.0) += 1.0;
            }
            if let Some(p) = prev {
                gap_sum += e.ts.saturating_sub(p);
                gap_n += 1;
            }
            prev = Some(e.ts);
        }
        if gap_n > 0 {
            f.mean_gap_ms = gap_sum as f64 / gap_n as f64;
        }
        f
    }
}

/// Collect events from the log within the last `window_ms` milliseconds.
pub fn window_events(log: &EventLog, window_ms: u64, now: u64) -> Vec<Event> {
    log.iter()
        .filter(|e| e.ts.saturating_sub(now.saturating_sub(window_ms)) < window_ms)
        .cloned()
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::capture::Event;
    use crate::storage::EventLog;

    #[test]
    fn extractor_counts_kinds() {
        let mut log = EventLog::with_capacity(8);
        log.push(Event { kind: "window".into(), value: "kitty".into(), ts: 1000 });
        log.push(Event { kind: "focus".into(), value: "1".into(), ts: 2000 });
        log.push(Event { kind: "window".into(), value: "kitty".into(), ts: 3000 });
        let evs = window_events(&log, 10_000, 3000);
        let f = DefaultExtractor.extract(&evs);
        assert_eq!(f.count, 3.0);
        assert_eq!(f.by_kind.get("window").copied(), Some(2.0));
        assert_eq!(f.window_hist.get("kitty").copied(), Some(2.0));
    }
}
