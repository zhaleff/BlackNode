//! Engine: owns the bus, config, context, and the four stages.
//!
//! This module wires Collectors -> Algorithms -> DecisionEngine ->
//! ActionEngine. Stages are registered at startup. The engine runs each
//! stage on its own thread and keeps the shared `Context` for inspection
//! (`blacknode brain status`).

use crate::bus::Bus;
use crate::collector::Collector;
use crate::algorithm::Algorithm;
use crate::decision::DecisionEngine;
use crate::action::Action;
use crate::config::Config;
use crate::context::Context;
use crate::memory::Memory;
use std::sync::{Arc, Mutex};

fn data_dir() -> std::path::PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
    let dir = std::path::Path::new(&home).join(".local/share/blacknode/brain");
    let _ = std::fs::create_dir_all(&dir);
    dir
}

fn decision_log_path() -> Option<std::path::PathBuf> {
    Some(data_dir().join("decisions.jsonl"))
}

pub struct Engine {
    pub bus: Arc<Bus>,
    pub config: Config,
    pub context: Arc<Mutex<Context>>,
    collectors: Vec<Box<dyn Collector>>,
    algorithms: Vec<Box<dyn Algorithm>>,
    decision: Option<Box<dyn DecisionEngine>>,
    actions: Vec<Box<dyn Action>>,
}

impl Engine {
    pub fn collector_on(&self, name: &str) -> bool {
        self.config.collector_on(name)
    }

    pub fn new(config: Config) -> Self {
        let memory = Arc::new(Memory::new(
            data_dir().join("memory.json"),
            config.learning.half_life_days,
        ));
        Engine {
            bus: Arc::new(Bus::new(memory)),
            config,
            context: Arc::new(Mutex::new(Context::default())),
            collectors: Vec::new(),
            algorithms: Vec::new(),
            decision: None,
            actions: Vec::new(),
        }
    }

    pub fn add_collector(&mut self, c: Box<dyn Collector>) {
        self.collectors.push(c);
    }
    pub fn add_algorithm(&mut self, a: Box<dyn Algorithm>) {
        self.algorithms.push(a);
    }
    pub fn set_decision(&mut self, d: Box<dyn DecisionEngine>) {
        self.decision = Some(d);
    }
    pub fn add_action(&mut self, a: Box<dyn Action>) {
        self.actions.push(a);
    }

    pub fn run(self) {
        let Engine {
            bus,
            config: _,
            context,
            collectors,
            algorithms,
            decision,
            actions,
        } = self;

        let ctx = Arc::clone(&context);
        let bus_ctx = Arc::clone(&bus);
        std::thread::spawn(move || crate::context::run(bus_ctx, ctx));

        // Durable-memory upkeep: persist and forget stale habits on a cadence
        // so knowledge stays current without any user intervention.
        let mem = bus.memory();
        std::thread::spawn(move || loop {
            std::thread::sleep(std::time::Duration::from_secs(60));
            mem.forget();
            mem.save();
        });

        for c in collectors {
            let bus = Arc::clone(&bus);
            std::thread::spawn(move || c.run(bus));
        }
        for a in algorithms {
            let bus = Arc::clone(&bus);
            std::thread::spawn(move || a.run(bus));
        }
        if let Some(d) = decision {
            let bus = Arc::clone(&bus);
            let ctx = Arc::clone(&context);
            std::thread::spawn(move || d.run(bus, ctx));
        }
        let actions = Arc::new(actions);
        let log_path = decision_log_path();
        std::thread::spawn(move || loop {
            if let Ok(dec) = bus.decision_rx().recv() {
                if let Ok(line) = serde_json::to_string(&dec) {
                    if let Some(p) = &log_path {
                        use std::io::Write;
                        let mut f = std::fs::OpenOptions::new()
                            .create(true)
                            .append(true)
                            .open(p)
                            .ok();
                        if let Some(f) = f.as_mut() {
                            let _ = f.write_all(format!("{}\n", line).as_bytes());
                        }
                    }
                }
                for act in actions.iter() {
                    if act.name() == dec.action {
                        act.execute(&dec);
                    }
                }
            }
        });
    }
}
