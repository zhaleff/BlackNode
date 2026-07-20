//! Collector trait: a source of raw signals.
//!
//! Implement this to add a new way to observe the user (hyprland windows,
//! behavior.json events, power state, time of day). Collectors run on their
//! own thread and publish to the bus.

pub trait Collector: Send {
    fn name(&self) -> &str;
    fn run(self: Box<Self>, bus: std::sync::Arc<crate::bus::Bus>);
}
