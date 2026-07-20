//! K-means (k=2) over inter-action gaps to split the session into
//! "dense" vs "sparse" activity blocks. Used to detect whether the user is
//! in a long focused block (small gaps) versus a fragmented one.
//!
//! One-dimensional online-ish k-means with fixed iterations per batch. Keeps
//! no per-sample history beyond the running batches.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge, Signal};

pub struct Kmeans {
    gaps: Vec<f64>,
    c0: f64,
    c1: f64,
}

impl Kmeans {
    pub fn new() -> Box<Self> {
        Box::new(Kmeans {
            gaps: Vec::new(),
            c0: 1.0,
            c1: 30.0,
        })
    }
}

impl Algorithm for Kmeans {
    fn name(&self) -> &str {
        "kmeans"
    }
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>) {
        let mut k = *self;
        let mut last_ts = 0u64;
        loop {
            while let Ok(s) = bus.signal_rx().try_recv() {
                if last_ts > 0 && s.ts > last_ts {
                    k.gaps.push((s.ts - last_ts) as f64 / 1000.0);
                    if k.gaps.len() > 256 {
                        k.gaps.remove(0);
                    }
                }
                last_ts = s.ts;
            }
            if k.gaps.len() >= 8 {
                let (a, b) = step(&k.gaps, k.c0, k.c1);
                k.c0 = a;
                k.c1 = b;
                let dense = a.min(b);
                let sparse = a.max(b);
                let ratio = if sparse > 0.0 {
                    (dense / sparse).min(1.0)
                } else {
                    0.0
                };
                bus.publish_knowledge(Knowledge::new("kmeans", "density", ratio, 0.5));
            }
            std::thread::sleep(std::time::Duration::from_millis(1000));
        }
    }
}

fn step(points: &[f64], mut c0: f64, mut c1: f64) -> (f64, f64) {
    for _ in 0..5 {
        let mut s0 = 0.0;
        let mut n0 = 0.0;
        let mut s1 = 0.0;
        let mut n1 = 0.0;
        for &p in points {
            if (p - c0).abs() <= (p - c1).abs() {
                s0 += p;
                n0 += 1.0;
            } else {
                s1 += p;
                n1 += 1.0;
            }
        }
        if n0 > 0.0 {
            c0 = s0 / n0;
        }
        if n1 > 0.0 {
            c1 = s1 / n1;
        }
    }
    (c0, c1)
}
