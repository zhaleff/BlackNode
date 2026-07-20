//! Action trait: a concrete change applied to the desktop.
//!
//! Implement this to add a new capability (DND, HUD layout, wallpaper,
//! power profile, brightness, audio). The ActionEngine receives `Decision`s
//! and dispatches to the matching `Action`. Every action is independently
//! enable/disable-able via config.

use crate::bus::Decision;

pub trait Action: Send + Sync + 'static {
    /// Must match the `Decision.action` string.
    fn name(&self) -> &str;
    /// Execute the decision. `params` carry arguments. Errors are logged, not
    /// fatal — a failed action never crashes the engine.
    fn execute(&self, decision: &Decision);
}
