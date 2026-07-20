//! Internal API surface.
//!
//! Defines the [`EngineApi`] trait: the stable contract plugins implement to
//! hook into the brain without modifying the core. A plugin receives the
//! current [`Prediction`] each cycle and may emit actions (notifications,
//! ambient changes) through the provided [`ActionSink`].
//!
//! Adding a new behavior = implement [`EngineApi`] + register it in `main`.
//! Core modules are never touched.

use crate::predictor::Prediction;

/// A sink the engine calls to emit side effects (notify, ambient, etc.).
pub trait ActionSink: Send {
    fn notify(&self, title: &str, body: &str);
    fn ambient(&self, mode: &str);
}

/// A plugin. `on_predict` runs every cycle with the latest prediction.
pub trait EngineApi: Send {
    fn name(&self) -> &str;
    /// Called each cycle. `first_of_kind` lets the plugin avoid spamming
    /// (e.g. act once per day for a given key).
    fn on_predict(&mut self, p: &Prediction, sink: &dyn ActionSink, first_of_kind: &dyn Fn(&str) -> bool);
}

/// Default null sink (tests / headless).
pub struct NullSink;
impl ActionSink for NullSink {
    fn notify(&self, _: &str, _: &str) {}
    fn ambient(&self, _: &str) {}
}
