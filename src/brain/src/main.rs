//! blacknode-brain v2: modular cognitive engine. Wires the stages and runs.

use blacknode_brain::{config::Config, engine::Engine};

fn main() {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    let cfg_path = std::path::Path::new(&home).join(".local/share/blacknode/brain/config.toml");
    let config = Config::load_or_default(&cfg_path);

    let engine = Engine::new(config);
    engine.run();

    loop {
        std::thread::sleep(std::time::Duration::from_secs(60));
    }
}
