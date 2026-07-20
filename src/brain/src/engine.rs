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
use std::sync::{Arc, Mutex};

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
    pub fn new(config: Config) -> Self {
        Engine {
            bus: Arc::new(Bus::new()),
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
            std::thread::spawn(move || d.run(bus));
        }
        let actions = Arc::new(actions);
        std::thread::spawn(move || loop {
            if let Ok(dec) = bus.decision_rx().recv() {
                for act in actions.iter() {
                    if act.name() == dec.action {
                        act.execute(&dec);
                    }
                }
            }
        });
    }
}
