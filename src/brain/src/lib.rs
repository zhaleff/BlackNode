//! BlackNode Brain v2 — modular cognitive engine.
//!
//! Pipeline: Collector -> Algorithms -> DecisionEngine -> ActionEngine.
//! Each stage is a trait so it can be swapped or extended without touching
//! the core. All learning is incremental and local.

pub mod bus;
pub mod config;
pub mod context;
pub mod action;
pub mod algorithm;
pub mod collector;
pub mod decision;
pub mod engine;
pub mod memory;
pub mod time;
