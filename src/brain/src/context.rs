//! Inferred context: the brain's current belief about what the user is doing.
//!
//! Algorithms feed evidence; the DecisionEngine reads this to decide. It is
//! the shared "working memory" of the engine, not a stored metric.

#[derive(Debug, Clone, Default, serde::Serialize, serde::Deserialize)]
pub struct Context {
    pub activity: Activity,
    pub confidence: f64,
    pub focus_min: f64,
    pub distract_pressure: f64,
    pub active_profile: String,
    pub top_app: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Default, serde::Serialize, serde::Deserialize)]
pub enum Activity {
    #[default]
    Unknown,
    DeepWork,
    Browsing,
    Media,
    Idle,
    ContextSwitching,
}

impl Context {
    pub fn describe(&self) -> String {
        format!(
            "activity={:?} conf={:.0}% focus_min={:.0} distract={:.1} profile={} app={}",
            self.activity, self.confidence * 100.0, self.focus_min, self.distract_pressure, self.active_profile, self.top_app
        )
    }
}
