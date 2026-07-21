//! BlackNode Brain — node-based cognitive engine.
//!
//! Everything is a Node: sensors produce signals, context/learning nodes
//! transform them, decision nodes combine, action nodes execute.
//! The NodeGraph propagates signals across nodes for several passes per tick.

pub mod config;
pub mod memory;
pub mod node;
pub mod time;
