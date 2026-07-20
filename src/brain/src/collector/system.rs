//! System collector: energy and connectivity context.
//!
//! Polls sysfs for battery level, power source and network reachability and
//! emits lightweight `battery` / `power` / `network` signals. This feeds the
//! context model so the brain can, for example, switch to a power-saving
//! profile on battery or pause sync when offline. No external calls.

use crate::bus::{Bus, Signal};
use crate::collector::Collector;
use std::sync::Arc;

pub struct System {
    interval_ms: u64,
}

impl System {
    pub fn new(interval_ms: u64) -> Box<Self> {
        Box::new(System { interval_ms })
    }
}

impl Collector for System {
    fn name(&self) -> &str {
        "system"
    }
    fn run(self: Box<Self>, bus: Arc<Bus>) {
        loop {
            if let Some(cap) = read_battery_capacity() {
                bus.publish_signal(Signal::new("battery", &cap.to_string()));
            }
            bus.publish_signal(Signal::new("power", if on_battery() { "battery" } else { "ac" }));
            bus.publish_signal(Signal::new("network", if network_up() { "up" } else { "down" }));
            std::thread::sleep(std::time::Duration::from_millis(self.interval_ms));
        }
    }
}

fn read_battery_capacity() -> Option<u8> {
    for entry in std::fs::read_dir("/sys/class/power_supply").ok()?.flatten() {
        let name = entry.file_name();
        let n = name.to_string_lossy();
        if n.starts_with("BAT") {
            let cap = std::fs::read_to_string(entry.path().join("capacity")).ok()?;
            return cap.trim().parse::<u8>().ok();
        }
    }
    None
}

fn on_battery() -> bool {
    if let Some(entries) = std::fs::read_dir("/sys/class/power_supply").ok() {
        for entry in entries.flatten() {
            if entry.file_name().to_string_lossy().starts_with("BAT") {
                if let Ok(status) = std::fs::read_to_string(entry.path().join("status")) {
                    return status.contains("Discharging");
                }
            }
        }
    }
    false
}

fn network_up() -> bool {
    let root = std::fs::read_dir("/sys/class/net").ok();
    let mut found = false;
    if let Some(entries) = root {
        for entry in entries.flatten() {
            let iface = entry.file_name();
            if iface == "lo" {
                continue;
            }
            if let Ok(state) = std::fs::read_to_string(entry.path().join("operstate")) {
                if state.trim() == "up" {
                    found = true;
                    break;
                }
            }
        }
    }
    found
}
