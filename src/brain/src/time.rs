//! Local-time helpers.
//!
//! The brain reasons about the user's day, so it must use local time, not
//! UTC. Centralized here so every stage agrees on "what hour is it".

use chrono::Timelike;

/// Current local hour in 0..24.
pub fn local_hour() -> u8 {
    chrono::Local::now().hour() as u8
}
