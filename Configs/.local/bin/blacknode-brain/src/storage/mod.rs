//! State persistence.
//!
//! Two stores:
//! - [`EventLog`]: append-only ring of recent raw events (bounded capacity,
//!   oldest dropped) for feature extraction windows.
//! - [`StateStore`]: compacted model state, written atomically (temp file +
//!   rename) so a crash mid-write never corrupts the on-disk state.
//!
//! All on-disk files live under `$HOME/.local/share/blacknode/brain/`.
//! Memory: event log is capacity-bounded; model state is fixed-size.

use crate::capture::Event;
use serde::Serialize;
use std::path::PathBuf;

pub fn brain_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join(".local/share/blacknode/brain")
}

/// Bounded append-only log. O(1) push, O(1) eviction, O(n) iteration.
/// Capacity fixed at construction: memory is bounded by `capacity`.
pub struct EventLog {
    buf: Vec<Event>,
    head: usize,
    len: usize,
    capacity: usize,
}

impl EventLog {
    pub fn with_capacity(capacity: usize) -> Self {
        EventLog {
            buf: Vec::with_capacity(capacity),
            head: 0,
            len: 0,
            capacity: capacity.max(1),
        }
    }

    pub fn push(&mut self, e: Event) {
        if self.len < self.capacity {
            self.buf.push(e);
            self.len += 1;
        } else {
            self.buf[self.head] = e;
            self.head = (self.head + 1) % self.capacity;
        }
    }

    pub fn iter(&self) -> impl Iterator<Item = &Event> {
        (0..self.len).map(move |i| {
            &self.buf[(self.head + i) % self.capacity]
        })
    }

    pub fn len(&self) -> usize {
        self.len
    }

    pub fn is_empty(&self) -> bool {
        self.len == 0
    }
}

/// Atomic write: serialize to a temp file then rename over the target.
/// Rename is atomic on POSIX, so readers never see a partial file.
pub fn atomic_write<T: Serialize>(path: &PathBuf, value: &T) -> std::io::Result<()> {
    let dir = path.parent().unwrap_or_else(|| std::path::Path::new("."));
    std::fs::create_dir_all(dir)?;
    let tmp = dir.join(format!(
        ".{}.tmp",
        path.file_name().and_then(|f| f.to_str()).unwrap_or("state")
    ));
    let data = serde_json::to_vec(value)?;
    std::fs::write(&tmp, data)?;
    std::fs::rename(&tmp, path)?;
    Ok(())
}

pub fn read_json<T: serde::de::DeserializeOwned>(path: &PathBuf) -> Option<T> {
    let data = std::fs::read(path).ok()?;
    serde_json::from_slice(&data).ok()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::capture::Event;

    #[test]
    fn event_log_bounded() {
        let mut log = EventLog::with_capacity(3);
        for i in 0..10 {
            log.push(Event::new("window", &format!("w{i}")));
        }
        assert_eq!(log.len(), 3);
        let vals: Vec<String> = log.iter().map(|e| e.value.clone()).collect();
        assert!(vals.contains(&"w9".to_string()));
        assert!(!vals.contains(&"w0".to_string()));
    }

    #[test]
    fn atomic_write_roundtrip() {
        let dir = std::env::temp_dir().join("bn_brain_test");
        let path = dir.join("state.json");
        atomic_write(&path, &vec![1u32, 2, 3]).unwrap();
        let back: Vec<u32> = read_json(&path).unwrap();
        assert_eq!(back, vec![1, 2, 3]);
        let _ = std::fs::remove_dir_all(&dir);
    }
}
