use serde_json::Value;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NodeKind {
    Sensor,
    Context,
    Memory,
    Learning,
    Decision,
    Action,
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

pub trait Node: Send + 'static {
    fn id(&self) -> &str;
    fn kind(&self) -> NodeKind;
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal>;
}

pub const PROPAGATION_DEPTH: usize = 4;
