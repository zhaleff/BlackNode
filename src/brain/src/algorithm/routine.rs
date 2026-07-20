//! Routine learner: discovers "at hour H the user usually opens app A".
//!
//! Stateless translator between `window` signals and durable memory. Every
//! signal is written to [`Memory`] (which decays old habits), and once per
//! tick the most likely app for the current hour is published as `Knowledge`.
//! Nothing is kept in this struct: restart the brain and the routine is still
//! known, because it lives in memory, not here.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};
use crate::time::local_hour;
use std::sync::Arc;

pub struct Routine;

impl Routine {
    pub fn new() -> Box<Self> {
        Box::new(Routine)
    }
}

impl Algorithm for Routine {
    fn name(&self) -> &str {
        "routine"
    }
    fn run(self: Box<Self>, bus: Arc<Bus>) {
        let mem = bus.memory();
        let sig = bus.signal_rx();
        let mut last_pub = 0u64;
        loop {
            while let Ok(s) = sig.try_recv() {
                if s.kind == "window" {
                    mem.observe_window(&s.value, local_hour());
                }
            }
            let now = now_ms();
            if now - last_pub > 1000 {
                last_pub = now;
                let h = local_hour();
                if let Some((app, p)) = mem.routine_for(h) {
                    if p >= 0.4 {
                        let conf = (p * 0.9).min(0.95);
                        bus.publish_knowledge(Knowledge::new(
                            "routine",
                            &format!("routine:{}", app),
                            p,
                            conf,
                        ));
                    }
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(500));
        }
    }
}

fn now_ms() -> u64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}
