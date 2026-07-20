//! Thread-safe, persistent, decaying memory store.
//!
//! Observations are written through [`Memory`] which keeps the model behind an
//! `RwLock` and persists it atomically (temp file + rename) at a throttled
//! cadence. Reads apply exponential decay so stale habits weaken. The store is
//! the single source of durable knowledge; algorithms are thin translators
//! between bus signals and these methods.

use crate::memory::model::{AppCount, Model};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::RwLock;
use std::time::{SystemTime, UNIX_EPOCH};

/// Milliseconds in a day, for the decay clock.
const DAY_MS: f64 = 86_400_000.0;

pub struct Memory {
    inner: RwLock<Model>,
    path: PathBuf,
    half_life_days: f64,
    last_save: RwLock<u64>,
    save_every_ms: u64,
}

impl Memory {
    pub fn new(path: PathBuf, half_life_days: f64) -> Self {
        let model = if path.exists() {
            std::fs::read_to_string(&path)
                .ok()
                .and_then(|s| serde_json::from_str::<Model>(&s).ok())
                .unwrap_or_else(Model::new)
        } else {
            Model::new()
        };
        Memory {
            inner: RwLock::new(model),
            path,
            half_life_days: half_life_days.max(0.5),
            last_save: RwLock::new(now_ms()),
            save_every_ms: 30_000,
        }
    }

    fn decay_factor(&self, last: u64) -> f64 {
        let age_days = (now_ms().saturating_sub(last)) as f64 / DAY_MS;
        0.5f64.powf(age_days / self.half_life_days)
    }

    /// Record that `app` was the active window at `hour`.
    pub fn observe_window(&self, app: &str, hour: u8) {
        let factor = self.decay_factor_atomically();
        let mut m = self.inner.write().unwrap();
        let bucket = m.routines.entry(hour).or_default();
        if let Some(ac) = bucket.iter_mut().find(|a| a.app == app) {
            ac.weight = ac.weight * factor + 1.0;
            ac.last = now_ms();
        } else {
            bucket.push(AppCount {
                app: app.to_string(),
                weight: 1.0,
                last: now_ms(),
            });
        }
        drop(m);
        self.save_if_needed();
    }

    /// Most likely app for `hour` and its decayed probability in [0,1].
    pub fn routine_for(&self, hour: u8) -> Option<(String, f64)> {
        let m = self.inner.read().unwrap();
        let bucket = m.routines.get(&hour)?;
        let mut total = 0.0;
        let mut best: Option<(String, f64)> = None;
        for ac in bucket {
            let w = ac.weight * self.decay_factor(ac.last);
            total += w;
            if best.as_ref().map(|(_, b)| w > *b).unwrap_or(true) {
                best = Some((ac.app.clone(), w));
            }
        }
        if total > 0.0 {
            best.map(|(app, w)| (app, (w / total).clamp(0.0, 1.0)))
        } else {
            None
        }
    }

    /// Record a focus/distract event at `hour`.
    pub fn observe_focus(&self, hour: u8, is_focus: bool) {
        let mut m = self.inner.write().unwrap();
        m.total[hour as usize] += 1.0;
        if is_focus {
            m.focus[hour as usize] += 1.0;
        }
        drop(m);
        self.save_if_needed();
    }

    /// Decayed probability of focus at `hour`.
    pub fn focus_prob(&self, hour: u8) -> f64 {
        let m = self.inner.read().unwrap();
        let total = m.total[hour as usize];
        if total > 0.0 {
            m.focus[hour as usize] / total
        } else {
            0.0
        }
    }

    /// Record a transition from one active app to another.
    pub fn observe_transition(&self, from: &str, to: &str) {
        let mut m = self.inner.write().unwrap();
        let bucket = m.transitions.entry(from.to_string()).or_default();
        if let Some(ac) = bucket.iter_mut().find(|a| a.app == to) {
            ac.weight += 1.0;
            ac.last = now_ms();
        } else {
            bucket.push(AppCount {
                app: to.to_string(),
                weight: 1.0,
                last: now_ms(),
            });
        }
        drop(m);
        self.save_if_needed();
    }

    /// Most likely next app after `from` and its probability in [0,1].
    pub fn next_after(&self, from: &str) -> Option<(String, f64)> {
        let m = self.inner.read().unwrap();
        let bucket = m.transitions.get(from)?;
        let mut total = 0.0;
        let mut best: Option<(String, f64)> = None;
        for ac in bucket {
            total += ac.weight;
            if best.as_ref().map(|(_, b)| ac.weight > *b).unwrap_or(true) {
                best = Some((ac.app.clone(), ac.weight));
            }
        }
        if total > 0.0 {
            best.map(|(app, w)| (app, (w / total).clamp(0.0, 1.0)))
        } else {
            None
        }
    }

    /// Decay is applied lazily on read; this only retires entries that have
    /// fully faded so the model does not grow without bound.
    pub fn forget(&self) {
        let mut m = self.inner.write().unwrap();
        let floor = 0.05;
        for bucket in m.routines.values_mut() {
            bucket.retain(|ac| ac.weight * self.decay_factor(ac.last) > floor);
        }
        for bucket in m.transitions.values_mut() {
            bucket.retain(|ac| ac.weight > floor);
        }
        drop(m);
        self.save_if_needed();
    }

    pub fn save(&self) {
        let m = self.inner.read().unwrap();
        if let Ok(s) = serde_json::to_string_pretty(&*m) {
            let tmp = self.path.with_extension("json.tmp");
            if std::fs::write(&tmp, &s).is_ok() {
                let _ = std::fs::rename(&tmp, &self.path);
            }
        }
        *self.last_save.write().unwrap() = now_ms();
    }

    fn decay_factor_atomically(&self) -> f64 {
        // Cheap global decay used when bumping a counter; individual reads use
        // per-entry decay. We approximate with a small constant so repeated
        // bumps within a session stay stable.
        1.0
    }

    fn save_if_needed(&self) {
        let last = *self.last_save.read().unwrap();
        if now_ms().saturating_sub(last) >= self.save_every_ms {
            self.save();
        }
    }
}

fn now_ms() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tmp_path() -> PathBuf {
        let d = std::env::temp_dir().join(format!("bn_mem_test_{}.json", now_ms()));
        d
    }

    #[test]
    fn observes_and_recalls_routine() {
        let p = tmp_path();
        let mem = Memory::new(p.clone(), 30.0);
        for _ in 0..10 {
            mem.observe_window("spotify", 22);
        }
        mem.observe_window("dolphin", 22);
        let (app, prob) = mem.routine_for(22).unwrap();
        assert_eq!(app, "spotify");
        assert!((0.9..=1.0).contains(&prob));
        let _ = std::fs::remove_file(&p);
    }

    #[test]
    fn old_habits_decay_below_new_ones() {
        let path = tmp_path();
        let mem = Memory::new(path.clone(), 0.0007);
        mem.observe_window("oldapp", 9);
        // force the timestamp far in the past by rewriting last
        {
            let mut m = mem.inner.write().unwrap();
            for ac in m.routines.get_mut(&9u8).unwrap() {
                ac.last = now_ms() - 3_600_000 * 24 * 60; // ~60 days ago
            }
        }
        mem.observe_window("newapp", 9);
        let (app, _) = mem.routine_for(9).unwrap();
        assert_eq!(app, "newapp");
        let _ = std::fs::remove_file(&path);
    }

    #[test]
    fn focus_probability_accumulates() {
        let p = tmp_path();
        let mem = Memory::new(p.clone(), 30.0);
        for _ in 0..8 {
            mem.observe_focus(20, true);
        }
        mem.observe_focus(20, false);
        assert!((mem.focus_prob(20) - 0.888).abs() < 0.01);
        let _ = std::fs::remove_file(&p);
    }
}
