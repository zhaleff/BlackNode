use blacknode_brain::{config::Config, node, memory::Memory};
use node::graph::NodeGraph;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

fn now_ms() -> u64 {
    SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_millis() as u64).unwrap_or(0)
}

fn main() {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    let dir = std::path::Path::new(&home).join(".local/share/blacknode/brain");
    let _ = std::fs::create_dir_all(&dir);
    let cfg_path = dir.join("config.toml");
    let config = Config::load_or_default(&cfg_path);
    let decisions_path = dir.join("decisions.jsonl");

    let memory_path = dir.join("memory.json");
    let memory = Arc::new(Memory::new(memory_path, config.learning.half_life_days));

    let mut graph = NodeGraph::new();
    node::nodes::register(&mut graph, Arc::clone(&memory));

    // Upkeep thread: forget + save memory every 60s
    let mem_upkeep = Arc::clone(&memory);
    std::thread::spawn(move || loop {
        std::thread::sleep(Duration::from_secs(60));
        mem_upkeep.forget();
        mem_upkeep.save();
    });

    let state_path = dir.join("state.json");

    loop {
        let result = graph.tick();
        let signals = result.signals;
        let decisions = result.decisions;
        let state = result.state;

        let _ = std::fs::write(&state_path, serde_json::to_string_pretty(&serde_json::json!({
            "activity": state.context.activity,
            "confidence": state.context.confidence,
            "active_window": state.active_window,
            "active_workspace": state.active_workspace,
            "focus": state.context.focus,
            "idle_min": state.idle_min,
            "windows_count": state.windows.len(),
            "on_battery": state.on_battery,
            "battery_pct": state.battery_pct,
        })).unwrap());

        for s in &decisions {
            let entry = serde_json::json!({
                "action": s.kind.strip_prefix("decision/").unwrap_or(&s.kind),
                "params": s.payload.as_ref().unwrap_or(&serde_json::json!({})),
                "value": s.value,
                "confidence": s.confidence,
                "evidence": [{
                    "source": &s.source,
                    "claim": &s.kind,
                    "value": s.value,
                    "confidence": s.confidence,
                }],
                "ts": now_ms(),
            });
            if let Ok(line) = serde_json::to_string(&entry) {
                let _ = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(&decisions_path)
                    .and_then(|f| {
                        use std::io::Write;
                        writeln!(&f, "{}", line)
                    });
            }
        }

        std::thread::sleep(Duration::from_millis(800));
    }
}