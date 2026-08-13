use std::env;
use std::fs;
use std::path::PathBuf;

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Position {
    #[serde(default)]
    pub chapter: usize,
    #[serde(default)]
    pub step: usize,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct State {
    #[serde(default)]
    pub completed: bool,
    #[serde(default)]
    pub seen: Vec<String>,
    #[serde(default)]
    pub nudged: bool,
    #[serde(default)]
    pub current: Position,
}

impl State {
    fn path() -> PathBuf {
        PathBuf::from(env::var("HOME").unwrap_or_else(|_| ".".into()))
            .join(".local/share/blacknode/tutorial.json")
    }

    pub fn load() -> State {
        fs::read_to_string(Self::path())
            .ok()
            .and_then(|raw| serde_json::from_str(&raw).ok())
            .unwrap_or_default()
    }

    pub fn save(&self) {
        let path = Self::path();
        if let Some(dir) = path.parent() {
            let _ = fs::create_dir_all(dir);
        }
        if let Ok(raw) = serde_json::to_string_pretty(self) {
            let _ = fs::write(path, raw);
        }
    }

    pub fn reset() {
        let _ = fs::remove_file(Self::path());
    }

    pub fn status(&self) -> &'static str {
        if self.completed {
            "completed"
        } else if self.seen.is_empty() && self.current.chapter == 0 && self.current.step == 0 {
            "new"
        } else {
            "in-progress"
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn status_is_new_before_any_use() {
        assert_eq!(State::default().status(), "new");
    }

    #[test]
    fn status_is_in_progress_after_movement() {
        let mut state = State::default();
        state.current.chapter = 1;
        assert_eq!(state.status(), "in-progress");
    }

    #[test]
    fn status_is_completed_when_finished() {
        let mut state = State::default();
        state.completed = true;
        assert_eq!(state.status(), "completed");
    }
}
