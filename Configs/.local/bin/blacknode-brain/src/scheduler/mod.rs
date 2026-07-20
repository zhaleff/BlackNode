//! Scheduler: concurrent event loop.
//!
//! Owns the capture channel receiver and the predictor. On each tick it
//! drains available events, pushes them into the bounded [`EventLog`], runs
//! incremental inference, and periodically persists. Runs on its own thread
//! so the rest of the system is never blocked by capture.
//!
//! Concurrency: a single owner thread; models are not `Sync`-shared, which
//! avoids locks entirely (ownership-based concurrency). Memory bounded by the
//! log capacity.

use crate::capture::ChannelSource;
use crate::predictor::Predictor;
use crate::storage::{brain_dir, EventLog};
use std::time::Duration;

pub struct Scheduler {
    source: ChannelSource,
    predictor: Predictor,
    log: EventLog,
    tick_ms: u64,
    save_every: u64,
}

impl Scheduler {
    pub fn new(source: ChannelSource, log_capacity: usize, tick_ms: u64, save_every: u64) -> Self {
        let dir = brain_dir();
        let mut predictor = Predictor::new();
        predictor.load(&dir);
        Scheduler {
            source,
            predictor,
            log: EventLog::with_capacity(log_capacity),
            tick_ms,
            save_every,
        }
    }

    /// Run the loop on the current thread (call from a dedicated thread).
    pub fn run(&mut self) {
        let dir = brain_dir();
        let mut ticks = 0u64;
        loop {
            while let Ok(e) = self.source.receiver().try_recv() {
                self.log.push(e.clone());
                self.predictor.ingest(&e, &self.log, crate::capture::now_ms());
            }
            ticks += 1;
            if ticks % self.save_every == 0 {
                self.predictor.save(&dir);
            }
            std::thread::sleep(Duration::from_millis(self.tick_ms));
        }
    }

    pub fn predict(&self) -> crate::predictor::Prediction {
        self.predictor.predict()
    }
}
