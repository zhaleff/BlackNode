//! Markov transition model over active applications.
//!
//! Observes app->app transitions into durable [`Memory`] and publishes, for
//! the current app, the most likely next app as `Knowledge`. Persistent: the
//! chain of habits survives restarts and decays with disuse.

use crate::algorithm::Algorithm;
use crate::bus::{Bus, Knowledge};
use std::sync::Arc;

pub struct Markov;

impl Markov {
    pub fn new() -> Box<Self> {
        Box::new(Markov)
    }
}

impl Algorithm for Markov {
    fn name(&self) -> &str {
        "markov"
    }
    fn run(self: Box<Self>, bus: Arc<Bus>) {
        let mem = bus.memory();
        let sig = bus.signal_rx();
        let mut prev: Option<String> = None;
        let mut last_pub = 0u64;
        loop {
            while let Ok(s) = sig.try_recv() {
                if s.kind == "window" {
                    let app = s.value.clone();
                    if let Some(p) = prev.take() {
                        mem.observe_transition(&p, &app);
                    }
                    prev = Some(app);
                }
            }
            let now = now_ms();
            if now - last_pub > 1000 {
                last_pub = now;
                if let Some(cur) = prev.clone() {
                    if let Some((to, p)) = mem.next_after(&cur) {
                        if p >= 0.4 && to != cur {
                            bus.publish_knowledge(Knowledge::new(
                                "markov",
                                &format!("next:{}", to),
                                p,
                                p,
                            ));
                        }
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
