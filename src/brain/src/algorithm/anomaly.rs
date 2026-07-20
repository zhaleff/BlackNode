//! Anomaly detector over context-switch rate.
//!
//! Uses Welford running mean/variance (O(1), no history kept) on the rate of
//! window changes. A high score means the user is thrashing between apps
//! (ContextSwitching), not a stable session. Publishes `instability`.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};

pub struct Anomaly {
    mean: f64,
    m2: f64,
    n: f64,
    last_switch_ts: u64,
    gap_sum: f64,
    gap_n: f64,
}

impl Anomaly {
    pub fn new() -> Box<Self> {
        Box::new(Anomaly {
            mean: 0.0,
            m2: 0.0,
            n: 0.0,
            last_switch_ts: 0,
            gap_sum: 0.0,
            gap_n: 0.0,
        })
    }
}

impl Algorithm for Anomaly {
    fn name(&self) -> &str {
        "anomaly"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut st = *self;
        loop {
            while let Ok(s) = bus.signal_rx().try_recv() {
                if s.kind == "window" {
                    if st.last_switch_ts > 0 {
                        let gap = s.ts.saturating_sub(st.last_switch_ts) as f64;
                        st.gap_sum += gap;
                        let delta = gap - st.mean;
                        st.mean += delta / st.n.max(1.0);
                        st.m2 += delta * (gap - st.mean);
                    }
                    st.last_switch_ts = s.ts;
                    st.n += 1.0;
                    st.gap_n += 1.0;
                }
            }
            if st.gap_n > 2.0 {
                let var = st.m2 / (st.n - 1.0);
                let avg_gap = st.gap_sum / st.gap_n;
                let instability = if var > 0.0 {
                    (avg_gap / var.sqrt()).min(1.0)
                } else {
                    0.0
                };
                bus.publish_knowledge(Knowledge::new(
                    "anomaly",
                    "instability",
                    instability,
                    0.5,
                ));
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}
