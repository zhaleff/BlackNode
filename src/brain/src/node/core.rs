use serde_json::Value;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NodeKind {
    Sensor,
    Context,
    Goal,
    Proposal,
    Decision,
    Action,
    Learning,
}

#[derive(Debug, Clone)]
pub struct Signal {
    pub source: String,
    pub kind: String,
    pub value: f64,
    pub confidence: f64,
    pub payload: Option<Value>,
}

impl Signal {
    pub fn new(source: &str, kind: &str, value: f64, confidence: f64) -> Self {
        Self { source: source.into(), kind: kind.into(), value, confidence, payload: None }
    }
    pub fn with_payload(mut self, payload: Value) -> Self {
        self.payload = Some(payload);
        self
    }
}

#[derive(Debug, Clone)]
pub struct WindowInfo {
    pub app: String,
    pub workspace: i64,
    pub fullscreen: bool,
}

#[derive(Debug, Clone)]
pub struct ContextSummary {
    pub activity: String,
    pub confidence: f64,
    pub focus: f64,
    pub idle_min: f64,
}

impl Default for ContextSummary {
    fn default() -> Self {
        Self { activity: "unknown".into(), confidence: 0.0, focus: 0.0, idle_min: 0.0 }
    }
}

#[derive(Debug, Clone)]
pub struct GoalState {
    pub id: String,
    pub priority: f64,
    pub label: String,
}

#[derive(Debug, Clone)]
pub struct ActionProposal {
    pub action: String,
    pub params: Value,
    pub benefit: f64,
    pub risk: f64,
    pub reason: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ActionState {
    Proposed,
    Executed,
    Rejected,
    Completed,
    Failed,
}

#[derive(Debug, Clone)]
pub struct ActionRecord {
    pub action: String,
    pub params: Value,
    pub state: ActionState,
    pub proposed_at: u64,
    pub executed_at: Option<u64>,
}

#[derive(Debug, Clone)]
pub struct BrainState {
    pub windows: Vec<WindowInfo>,
    pub active_window: String,
    pub active_workspace: i64,
    pub active_fullscreen: bool,
    pub context: ContextSummary,
    pub goals: Vec<GoalState>,
    pub idle_min: f64,
    pub on_battery: bool,
    pub battery_pct: f64,
    pub network: bool,
}

impl Default for BrainState {
    fn default() -> Self {
        Self {
            windows: vec![],
            active_window: String::new(),
            active_workspace: -1,
            active_fullscreen: false,
            context: ContextSummary::default(),
            goals: vec![],
            idle_min: 0.0,
            on_battery: false,
            battery_pct: -1.0,
            network: false,
        }
    }
}

pub trait Node: Send + 'static {
    fn id(&self) -> &str;
    fn kind(&self) -> NodeKind;
    fn process(&mut self, signals: &[Signal], state: &mut BrainState) -> Vec<Signal>;
}