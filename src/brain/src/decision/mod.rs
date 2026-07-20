//! DecisionEngine trait + default brain logic.
//!
//! The default engine watches the knowledge stream and the shared context,
//! and emits `Decision`s when evidence crosses a threshold. Every decision
//! carries a `reason` chain so `blacknode brain explain` can show *why*.
//! Threshold and action wiring are per-context and explicit here; this is the
//! one place the "beliefs -> actions" mapping lives.

use crate::bus::{Bus, Decision, Knowledge};
use crate::context::{Activity, Context};
use std::sync::{Arc, Mutex};

mod engine_trait;
pub use engine_trait::DecisionEngine;

pub struct DefaultDecisionEngine {
    last_dnd: bool,
    last_hud: String,
    launch_demo: bool,
    last_launch: String,
}

impl DefaultDecisionEngine {
    pub fn new(launch_demo: bool) -> Box<Self> {
        Box::new(DefaultDecisionEngine {
            last_dnd: false,
            last_hud: String::new(),
            launch_demo,
            last_launch: String::new(),
        })
    }
}

impl DecisionEngine for DefaultDecisionEngine {
    fn name(&self) -> &str {
        "default"
    }
    fn run(self: Box<Self>, bus: Arc<Bus>, ctx: Arc<Mutex<Context>>) {
        let mut eng = *self;
        let mut since_emit = 0u64;
        loop {
            let knowledge = eng.drain_knowledge(&bus);
            let context = ctx.lock().unwrap().clone();
            if !knowledge.is_empty() {
                since_emit = 0;
            } else {
                since_emit += 1;
            }
            if since_emit < 10 {
                let decisions = eng.decide(&knowledge, &context);
                for d in decisions {
                    bus.publish_decision(d);
                }
            }
            std::thread::sleep(std::time::Duration::from_millis(1000));
        }
    }

    fn decide(&mut self, k: &[Knowledge], ctx: &Context) -> Vec<Decision> {
        let mut out = Vec::new();
        let focus = latest(k, "focus");
        let instability = latest(k, "instability");

        for kk in k {
            if let Some(app) = kk.claim.strip_prefix("routine:") {
                if kk.value >= 0.5 && self.last_launch != app {
                    self.last_launch = app.to_string();
                    out.push(
                        Decision::new("LaunchApp")
                            .param("app", app)
                            .because(&format!("learned routine: you usually open {} now (p={:.0}%)", app, kk.value * 100.0))
                            .confidence(kk.value.min(0.95)),
                    );
                }
            }
        }

        match ctx.activity {
            Activity::DeepWork => {
                if !self.last_dnd {
                    self.last_dnd = true;
                    out.push(
                        Decision::new("EnableDND")
                            .because(&format!("deep work detected, focus={:.0}%", focus * 100.0))
                            .confidence(focus.max(0.6)),
                    );
                }
                let hud = hud_for("coding");
                if hud != self.last_hud {
                    self.last_hud = hud.clone();
                    out.push(
                        Decision::new("ChangeHUD")
                            .param("hud", &hud)
                            .because("context is coding, show focus + git HUD")
                            .confidence(0.7),
                    );
                }
            }
            Activity::ContextSwitching => {
                if self.last_dnd {
                    self.last_dnd = false;
                    out.push(
                        Decision::new("DisableDND")
                            .because(&format!("user is switching context, instability={:.0}%", instability * 100.0))
                            .confidence(0.6),
                    );
                }
            }
            Activity::Idle => {
                if self.last_dnd {
                    self.last_dnd = false;
                    out.push(Decision::new("DisableDND").because("user is idle").confidence(0.8));
                }
            }
            Activity::Media => {
                if self.launch_demo && self.last_launch != "spotify" {
                    self.last_launch = "spotify".to_string();
                    out.push(
                        Decision::new("LaunchApp")
                            .param("app", "spotify")
                            .because("media context detected, autonomously opening spotify")
                            .confidence(0.9),
                    );
                }
            }
            _ => {}
        }
        out
    }
}

fn latest(k: &[Knowledge], claim: &str) -> f64 {
    k.iter()
        .filter(|x| x.claim == claim)
        .last()
        .map(|x| x.value)
        .unwrap_or(0.0)
}

fn hud_for(kind: &str) -> String {
    match kind {
        "coding" => r#"{"layout":"coding","widgets":["focus","git","clock"]}"#.to_string(),
        _ => r#"{"layout":"default","widgets":["clock"]}"#.to_string(),
    }
}
