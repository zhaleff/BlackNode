//! DecisionEngine trait + default brain logic.
//!
//! The default engine is a *combiner*: it never decides from a single source.
//! Every tick it gathers `Evidence` from the knowledge stream and the shared
//! `Context`, fuses them into weighted beliefs (focus, instability, routine,
//! power), and emits `Decision`s whose `reason` and `evidence` fields make the
//! reasoning fully reconstructable. Tuning lives here and nowhere else.

use crate::bus::{Bus, Decision, Evidence, Knowledge};
use crate::context::{Activity, Context};
use std::sync::{Arc, Mutex};

mod engine_trait;
pub use engine_trait::DecisionEngine;

pub struct DefaultDecisionEngine {
    last_dnd: bool,
    last_hud: String,
    last_launch: String,
}

impl DefaultDecisionEngine {
    pub fn new() -> Box<Self> {
        Box::new(DefaultDecisionEngine {
            last_dnd: false,
            last_hud: String::new(),
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
        let kn = bus.knowledge_rx();
        loop {
            let mut knowledge = Vec::new();
            while let Ok(k) = kn.try_recv() {
                knowledge.push(k);
            }
            let context = ctx.lock().unwrap().clone();
            let decisions = eng.decide(&knowledge, &context);
            for d in decisions {
                bus.publish_decision(d);
            }
            std::thread::sleep(std::time::Duration::from_millis(1000));
        }
    }

    fn decide(&mut self, k: &[Knowledge], ctx: &Context) -> Vec<Decision> {
        let mut out = Vec::new();
        let evidence: Vec<Evidence> = k
            .iter()
            .map(|kk| Evidence {
                source: kk.source.clone(),
                claim: kk.claim.clone(),
                value: kk.value,
                confidence: kk.confidence,
            })
            .collect();

        // Weighted focus belief across every focus source we have.
        let focus = weighted_value(&evidence, &["focus", "focus_hour"]);

        // Routine + markov: what app should be open now.
        for e in &evidence {
            if let Some(app) = e.claim.strip_prefix("routine:") {
                if e.value >= 0.5 && self.last_launch != app {
                    self.last_launch = app.to_string();
                    out.push(
                        Decision::new("LaunchApp")
                            .param("app", app)
                            .because(&format!(
                                "learned routine: you usually open {} now (p={:.0}%)",
                                app,
                                e.value * 100.0
                            ))
                            .with_evidence(e.clone())
                            .confidence(e.value.min(0.95)),
                    );
                }
            }
        }

        // Do-Not-Disturb from fused focus belief + context.
        let want_dnd = matches!(ctx.activity, Activity::DeepWork)
            || (focus > 0.6 && ctx.idle_min < 5.0);
        if want_dnd && !self.last_dnd {
            self.last_dnd = true;
            out.push(
                Decision::new("EnableDND")
                    .because(&format!(
                        "focus belief {:.0}%, context {:?}",
                        focus * 100.0,
                        ctx.activity
                    ))
                    .with_evidence(Evidence {
                        source: "decision".into(),
                        claim: "focus_belief".into(),
                        value: focus,
                        confidence: 0.7,
                    })
                    .confidence(focus.max(0.6)),
            );
        } else if !want_dnd && self.last_dnd {
            self.last_dnd = false;
            out.push(
                Decision::new("DisableDND")
                    .because(&format!("context {:?}, focus {:.0}%", ctx.activity, focus * 100.0))
                    .confidence(0.6),
            );
        }

        // Dynamic HUD follows the context.
        if matches!(ctx.activity, Activity::DeepWork) {
            let hud = r#"{"layout":"coding","widgets":["focus","git","clock"]}"#;
            if hud != self.last_hud {
                self.last_hud = hud.to_string();
                out.push(
                    Decision::new("ChangeHUD")
                        .param("hud", hud)
                        .because("deep work context: show focus + git HUD")
                        .confidence(0.7),
                );
            }
        }

        // Power awareness: save battery when low and on battery.
        if ctx.on_battery && ctx.battery >= 0.0 && ctx.battery < 20.0 {
            out.push(
                Decision::new("PowerProfile")
                    .param("profile", "power-saver")
                    .because(&format!("on battery at {:.0}%", ctx.battery))
                    .with_evidence(Evidence {
                        source: "system".into(),
                        claim: "battery".into(),
                        value: ctx.battery,
                        confidence: 0.9,
                    })
                    .confidence(0.9),
            );
        }

        out
    }
}

/// Weighted average of `value` over evidence whose claim is in `claims`,
/// weighting by each piece's confidence. Returns 0 when no such evidence.
fn weighted_value(evidence: &[Evidence], claims: &[&str]) -> f64 {
    let mut num = 0.0;
    let mut den = 0.0;
    for e in evidence {
        if claims.contains(&e.claim.as_str()) {
            num += e.value * e.confidence;
            den += e.confidence;
        }
    }
    if den > 0.0 {
        num / den
    } else {
        0.0
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::bus::Knowledge;
    use crate::context::Context;

    fn kn(source: &str, claim: &str, value: f64) -> Knowledge {
        Knowledge::new(source, claim, value, value.min(0.95))
    }

    #[test]
    fn proposes_launch_from_routine() {
        let mut eng = DefaultDecisionEngine::new();
        let k = vec![kn("routine", "routine:spotify", 0.9)];
        let ctx = Context::default();
        let d = eng.decide(&k, &ctx);
        assert!(d.iter().any(|x| x.action == "LaunchApp" && x.params.get("app").map(|v| v == "spotify").unwrap_or(false)));
    }

    #[test]
    fn enables_dnd_on_deep_work() {
        let mut eng = DefaultDecisionEngine::new();
        let mut ctx = Context::default();
        ctx.activity = Activity::DeepWork;
        let k = vec![kn("ewma", "focus", 0.8)];
        let d = eng.decide(&k, &ctx);
        assert!(d.iter().any(|x| x.action == "EnableDND"));
    }

    #[test]
    fn no_dnd_when_browsing() {
        let mut eng = DefaultDecisionEngine::new();
        let ctx = Context::default();
        let k = vec![kn("ewma", "focus", 0.1)];
        let d = eng.decide(&k, &ctx);
        assert!(!d.iter().any(|x| x.action == "EnableDND"));
    }

    #[test]
    fn weighted_focus_combines_sources() {
        let e = vec![
            Evidence { source: "ewma".into(), claim: "focus".into(), value: 1.0, confidence: 0.6 },
            Evidence { source: "bayes".into(), claim: "focus_hour".into(), value: 0.0, confidence: 0.6 },
        ];
        assert!((weighted_value(&e, &["focus", "focus_hour"]) - 0.5).abs() < 1e-9);
    }
}
