//! Granular configuration. Every algorithm and every action can be toggled.
//!
//! Loaded from `~/.local/share/blacknode/brain/config.toml` (or defaults).
//! If the file is missing, defaults are used and written back so the user
//! can edit it. A user can turn the whole brain into a passive monitor by
//! setting `automation.enabled = false`.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub enabled: bool,
    pub automation: Automation,
    pub collectors: std::collections::HashMap<String, bool>,
    pub algorithms: std::collections::HashMap<String, bool>,
    pub actions: std::collections::HashMap<String, bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Automation {
    pub enabled: bool,
    pub hud: bool,
    pub dnd: bool,
    pub wallpaper: bool,
    pub brightness: bool,
    pub power_profile: bool,
    pub notifications: bool,
    pub profile: bool,
    pub launch_demo: bool,
}

impl Default for Config {
    fn default() -> Self {
        let mut algorithms = std::collections::HashMap::new();
        for a in ["ewma", "markov", "bayes", "kmeans", "anomaly", "context_graph", "reinforcement", "routine"] {
            algorithms.insert(a.to_string(), true);
        }
        let mut actions = std::collections::HashMap::new();
        for a in ["EnableDND", "DisableDND", "ChangeHUD", "PowerProfile", "Wallpaper", "Brightness", "ProfileSuggest", "Notify", "LaunchApp"] {
            actions.insert(a.to_string(), true);
        }
        let mut collectors = std::collections::HashMap::new();
        for a in ["hyprland", "behavior_file"] {
            collectors.insert(a.to_string(), true);
        }
        Config {
            enabled: true,
            automation: Automation {
                enabled: true,
                hud: true,
                dnd: true,
                wallpaper: false,
                brightness: false,
                power_profile: true,
                notifications: true,
                profile: true,
                launch_demo: false,
            },
            collectors,
            algorithms,
            actions,
        }
    }
}

impl Config {
    pub fn collector_on(&self, name: &str) -> bool {
        self.enabled && *self.collectors.get(name).unwrap_or(&true)
    }
    pub fn algorithm_on(&self, name: &str) -> bool {
        self.enabled && *self.algorithms.get(name).unwrap_or(&true)
    }
    pub fn action_on(&self, name: &str) -> bool {
        self.enabled && self.automation.enabled && *self.actions.get(name).unwrap_or(&true)
    }
    pub fn load_or_default(path: &std::path::Path) -> Self {
        if let Ok(s) = std::fs::read_to_string(path) {
            if let Ok(c) = toml::from_str::<Config>(&s) {
                return c;
            }
        }
        let c = Config::default();
        if let Ok(s) = toml::to_string_pretty(&c) {
            let _ = std::fs::write(path, s);
        }
        c
    }
}
