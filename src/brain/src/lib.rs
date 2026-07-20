//! BlackNode Brain — local intelligence engine.
//!
//! Modular, model-free (no external models), learns only from local data via
//! EWMA, Markov chains, Bayesian update, KMeans clustering and anomaly
//! detection. See module docs for algorithm justifications and complexity.

pub mod api;
pub mod algorithms;
pub mod capture;
pub mod features;
pub mod predictor;
pub mod scheduler;
pub mod storage;

pub use api::{ActionSink, EngineApi, NullSink};
pub use capture::{ChannelSource, Event, HyprlandSource};
pub use predictor::{Prediction, Predictor};
pub use scheduler::Scheduler;
pub use storage::brain_dir;
