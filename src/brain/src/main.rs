//! blacknode-brain v2: modular cognitive engine entry point.

use blacknode_brain::{action, algorithm, collector, config::Config, decision, engine::Engine};
use std::sync::Arc;

fn main() {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    let dir = std::path::Path::new(&home).join(".local/share/blacknode/brain");
    let _ = std::fs::create_dir_all(&dir);
    let cfg_path = dir.join("config.toml");
    let config = Config::load_or_default(&cfg_path);

    let mut engine = Engine::new(config);

    if engine.collector_on("hyprland") {
        engine.add_collector(collector::Hyprland::new(1000));
    }
    if engine.collector_on("behavior_file") {
        engine.add_collector(collector::BehaviorFile::new());
    }
    for a in algorithm::register(&engine.config) {
        engine.add_algorithm(a);
    }
    engine.set_decision(decision::DefaultDecisionEngine::new(engine.config.automation.launch_demo));
    for a in action::register(&engine.config) {
        engine.add_action(a);
    }

    let ctx = Arc::clone(&engine.context);
    let state_path = dir.join("state.json");
    std::thread::spawn(move || loop {
        std::thread::sleep(std::time::Duration::from_secs(30));
        if let Ok(s) = serde_json::to_string(&*ctx.lock().unwrap()) {
            let _ = std::fs::write(&state_path, s);
        }
    });

    engine.run();
    loop {
        std::thread::sleep(std::time::Duration::from_secs(60));
    }
}
