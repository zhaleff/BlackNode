//! Algorithm trait and module registry.
//!
//! An algorithm subscribes to the bus, updates an incremental model, and
//! publishes `Knowledge` claims. Each algorithm lives in its own file under
//! this directory. Adding one = new file + one line in `register`.

use crate::bus::{Bus, Knowledge, Signal};

pub trait Algorithm: Send {
    fn name(&self) -> &str;
    fn run(self: Box<Self>, bus: std::sync::Arc<Bus>);
}

impl dyn Algorithm {
    pub fn emit(&self, bus: &Bus, source: &str, claim: &str, value: f64, confidence: f64) {
        bus.publish_knowledge(Knowledge::new(source, claim, value, confidence));
    }
}

mod anomaly;
mod bayes;
mod ewma;
mod kmeans;
mod markov;

pub use anomaly::Anomaly;
pub use bayes::Bayes;
pub use ewma::Ewma;
pub use kmeans::Kmeans;
pub use markov::Markov;

use crate::config::Config;

/// Build the enabled algorithm set from config.
pub fn register(config: &Config) -> Vec<Box<dyn Algorithm>> {
    let mut out: Vec<Box<dyn Algorithm>> = Vec::new();
    if config.algorithm_on("ewma") {
        out.push(Ewma::new(0.1));
    }
    if config.algorithm_on("anomaly") {
        out.push(Anomaly::new());
    }
    if config.algorithm_on("markov") {
        out.push(Markov::new());
    }
    if config.algorithm_on("bayes") {
        out.push(Bayes::new());
    }
    if config.algorithm_on("kmeans") {
        out.push(Kmeans::new());
    }
    out
}
