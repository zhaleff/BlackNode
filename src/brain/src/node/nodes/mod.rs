use crate::node::core::*;
use crate::node::graph::NodeGraph;
use crate::memory::Memory;
use std::sync::Arc;
use std::time::{Duration, Instant};

pub fn register(graph: &mut NodeGraph, memory: Arc<Memory>) {
    graph.add(WindowWatcher::new());
    graph.add(SystemSensor::new());
    graph.add(BehaviorWatcher::new());
    graph.add(ContextNode::new());
    graph.add(RoutineLearner::new(Arc::clone(&memory)));
    graph.add(TransitionLearner::new(Arc::clone(&memory)));
    graph.add(FocusLearner::new(Arc::clone(&memory)));
    graph.add(DecisionNode::new());
    graph.add(ActionExecutor::new());
    graph.add(FeedbackLearner::new(Arc::clone(&memory)));
}

// ── WindowWatcher ──────────────────────────────────────────────────────────

use std::process::Command;

fn hyprctl(args: &[&str]) -> Option<String> {
    Command::new("hyprctl").args(args).output()
        .ok().and_then(|o| String::from_utf8(o.stdout).ok())
}

fn extract_class(json: &str) -> Option<String> {
    let start = json.find("\"class\"")?;
    let rest = &json[start + 8..];
    let q = rest.find('"')?;
    let end = rest[q + 1..].find('"')?;
    Some(rest[q + 1..q + 1 + end].to_string())
}

fn get_active_app() -> Option<String> {
    hyprctl(&["activewindow", "-j"]).and_then(|out| extract_class(&out))
}

pub struct WindowWatcher {
    last_poll: Instant,
    last_app: String,
}

impl WindowWatcher {
    pub fn new() -> Self {
        Self { last_poll: Instant::now(), last_app: String::new() }
    }
}

impl Node for WindowWatcher {
    fn id(&self) -> &str { "sensor/window" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, _signals: &[Signal]) -> Vec<Signal> {
        if self.last_poll.elapsed() < Duration::from_secs(1) {
            return Vec::new();
        }
        self.last_poll = Instant::now();
        let app = get_active_app().unwrap_or_default();
        if app == self.last_app || app.is_empty() {
            return Vec::new();
        }
        self.last_app = app.clone();
        vec![Signal::new("sensor/window", "sensor/window", 1.0, 1.0)
            .with_payload(serde_json::json!({ "app": app }))]
    }
}

// ── SystemSensor ───────────────────────────────────────────────────────────

pub struct SystemSensor {
    bat_poll: Instant,
    net_poll: Instant,
    idle_poll: Instant,
    last_window_ts: Instant,
}

impl SystemSensor {
    pub fn new() -> Self {
        Self {
            bat_poll: Instant::now(),
            net_poll: Instant::now(),
            idle_poll: Instant::now(),
            last_window_ts: Instant::now(),
        }
    }
}

fn read_battery() -> (f64, bool) {
    let cap = std::fs::read_to_string("/sys/class/power_supply/BAT0/capacity")
        .ok().and_then(|s| s.trim().parse::<f64>().ok()).unwrap_or(-1.0);
    let on_bat = std::fs::read_to_string("/sys/class/power_supply/BAT0/status")
        .ok().map(|s| s.trim() == "Discharging").unwrap_or(false);
    (cap, on_bat)
}

fn read_network() -> bool {
    std::fs::read_dir("/sys/class/net")
        .map(|entries| {
            entries.filter_map(|e| e.ok()).any(|e| {
                let name = e.file_name();
                let name = name.to_string_lossy();
                name != "lo"
                    && std::fs::read_to_string(e.path().join("operstate"))
                        .ok()
                        .map(|s| s.trim() == "up")
                        .unwrap_or(false)
            })
        })
        .unwrap_or(false)
}

impl Node for SystemSensor {
    fn id(&self) -> &str { "sensor/system" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        let mut out = Vec::new();
        for s in signals {
            if s.kind == "sensor/window" {
                self.last_window_ts = Instant::now();
            }
        }
        if self.bat_poll.elapsed() >= Duration::from_secs(10) {
            self.bat_poll = Instant::now();
            let (battery, on_battery) = read_battery();
            if battery >= 0.0 {
                out.push(Signal::new("sensor/system", "sensor/battery", battery / 100.0, 0.9)
                    .with_payload(serde_json::json!({ "percent": battery, "on_battery": on_battery })));
            }
        }
        if self.net_poll.elapsed() >= Duration::from_secs(30) {
            self.net_poll = Instant::now();
            let up = read_network();
            out.push(Signal::new("sensor/system", "sensor/network", if up { 1.0 } else { 0.0 }, 0.95)
                .with_payload(serde_json::json!({ "up": up })));
        }
        if self.idle_poll.elapsed() >= Duration::from_secs(5) {
            self.idle_poll = Instant::now();
            let idle_secs = self.last_window_ts.elapsed().as_secs_f64();
            out.push(Signal::new("sensor/system", "sensor/idle", (idle_secs / 300.0).min(1.0), 0.9)
                .with_payload(serde_json::json!({ "idle_secs": idle_secs })));
        }
        out
    }
}

// ── BehaviorWatcher ───────────────────────────────────────────────────────

fn read_behavior_len(p: &std::path::Path) -> u64 {
    std::fs::metadata(p).map(|m| m.len()).unwrap_or(0)
}

fn tail_behavior(p: &std::path::Path, from: u64) -> Option<String> {
    let data = std::fs::read(p).ok()?;
    let from = from.min(data.len() as u64) as usize;
    String::from_utf8(data[from..].to_vec()).ok()
}

pub struct BehaviorWatcher {
    path: std::path::PathBuf,
    last_len: u64,
}

impl BehaviorWatcher {
    pub fn new() -> Self {
        let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
        let path = std::path::Path::new(&home).join(".local/share/blacknode/behavior.json");
        let last_len = read_behavior_len(&path);
        Self { path, last_len }
    }
}

impl Node for BehaviorWatcher {
    fn id(&self) -> &str { "sensor/behavior" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, _signals: &[Signal]) -> Vec<Signal> {
        let cur = read_behavior_len(&self.path);
        if cur < self.last_len { self.last_len = cur; }
        if cur <= self.last_len { return Vec::new(); }
        let mut out = Vec::new();
        if let Some(tail) = tail_behavior(&self.path, self.last_len) {
            for line in tail.lines() {
                let kind = if line.contains("\"focus\"") {
                    "sensor/focus"
                } else if line.contains("\"distract\"") {
                    "sensor/distract"
                } else if line.contains("\"profile\"") {
                    "sensor/profile"
                } else {
                    continue;
                };
                out.push(Signal::new("sensor/behavior", kind, 1.0, 0.95));
            }
        }
        self.last_len = cur;
        out
    }
}

// ── ContextNode ────────────────────────────────────────────────────────────

const MEDIA_APPS: &[&str] = &["spotify", "vlc", "mpv", "youtube-music", "rhythmbox"];

pub struct ContextNode {
    top_app: String,
    last_window_ts: Instant,
    focus: f64,
    distract: f64,
    instability: f64,
    battery: f64,
    on_battery: bool,
    network: bool,
    last_emit: Instant,
}

impl ContextNode {
    pub fn new() -> Self {
        Self {
            top_app: String::new(),
            last_window_ts: Instant::now(),
            focus: 0.0,
            distract: 0.0,
            instability: 0.0,
            battery: -1.0,
            on_battery: false,
            network: false,
            last_emit: Instant::now(),
        }
    }
    fn infer(&self) -> (&'static str, f64) {
        let app = self.top_app.to_lowercase();
        if MEDIA_APPS.iter().any(|m| app.contains(m)) {
            return ("media", 0.9);
        }
        let idle_min = self.last_window_ts.elapsed().as_secs_f64() / 60.0;
        if idle_min > 5.0 {
            return ("idle", (0.6 + idle_min / 60.0).min(0.95));
        }
        if self.instability > 0.6 {
            return ("context_switching", self.instability);
        }
        if self.focus > 0.7 {
            return ("deep_work", self.focus);
        }
        if self.focus < 0.3 {
            return ("browsing", 1.0 - self.focus);
        }
        ("browsing", 0.4)
    }
}

impl Node for ContextNode {
    fn id(&self) -> &str { "context" }
    fn kind(&self) -> NodeKind { NodeKind::Context }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "sensor/window" => {
                    if let Some(p) = &s.payload {
                        if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                            self.top_app = app.to_string();
                            self.last_window_ts = Instant::now();
                        }
                    }
                }
                "sensor/focus" => self.focus = s.value,
                "sensor/distract" => self.distract = s.value,
                "sensor/battery" => {
                    if let Some(p) = &s.payload {
                        self.battery = p.get("percent").and_then(|v| v.as_f64()).unwrap_or(-1.0);
                        self.on_battery = p.get("on_battery").and_then(|v| v.as_bool()).unwrap_or(false);
                    }
                }
                "sensor/network" => {
                    if let Some(p) = &s.payload {
                        self.network = p.get("up").and_then(|v| v.as_bool()).unwrap_or(false);
                    }
                }
                _ => {}
            }
        }
        if self.last_emit.elapsed() < Duration::from_secs(1) {
            return Vec::new();
        }
        self.last_emit = Instant::now();
        let idle_min = self.last_window_ts.elapsed().as_secs_f64() / 60.0;
        let (activity, confidence) = self.infer();
        vec![Signal::new("context", "context", confidence, confidence)
            .with_payload(serde_json::json!({
                "activity": activity,
                "app": self.top_app,
                "idle_min": idle_min,
                "focus": self.focus,
                "battery": self.battery,
                "on_battery": self.on_battery,
                "network": self.network,
            }))]
    }
}

// ── RoutineLearner ─────────────────────────────────────────────────────────

use crate::time::local_hour;

pub struct RoutineLearner {
    memory: Arc<Memory>,
}

impl RoutineLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory }
    }
}

impl Node for RoutineLearner {
    fn id(&self) -> &str { "learner/routine" }
    fn kind(&self) -> NodeKind { NodeKind::Learning }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            if s.kind == "sensor/window" {
                if let Some(p) = &s.payload {
                    if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                        self.memory.observe_window(app, local_hour());
                    }
                }
            }
        }
        let h = local_hour();
        if let Some((app, p)) = self.memory.routine_for(h) {
            if p >= 0.4 {
                return vec![Signal::new("learner/routine", "learning/routine", p, (p * 0.9).min(0.95))
                    .with_payload(serde_json::json!({ "app": app }))];
            }
        }
        Vec::new()
    }
}

// ── FocusLearner ───────────────────────────────────────────────────────────

pub struct FocusLearner {
    memory: Arc<Memory>,
    last_pub: Instant,
}

impl FocusLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_pub: Instant::now() }
    }
}

impl Node for FocusLearner {
    fn id(&self) -> &str { "learner/focus" }
    fn kind(&self) -> NodeKind { NodeKind::Learning }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "sensor/focus" => self.memory.observe_focus(local_hour(), true),
                "sensor/distract" => self.memory.observe_focus(local_hour(), false),
                _ => {}
            }
        }
        if self.last_pub.elapsed() < Duration::from_secs(1) {
            return Vec::new();
        }
        self.last_pub = Instant::now();
        let h = local_hour();
        let p = self.memory.focus_prob(h);
        let conf = (self.memory.total_samples(h) / (self.memory.total_samples(h) + 10.0)).min(0.9);
        vec![Signal::new("learner/focus", "learning/focus_hour", p, conf)]
    }
}

// ── TransitionLearner ──────────────────────────────────────────────────────

pub struct TransitionLearner {
    memory: Arc<Memory>,
    last_app: String,
    last_pub: Instant,
}

impl TransitionLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_app: String::new(), last_pub: Instant::now() }
    }
}

impl Node for TransitionLearner {
    fn id(&self) -> &str { "learner/transition" }
    fn kind(&self) -> NodeKind { NodeKind::Learning }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            if s.kind == "sensor/window" {
                if let Some(p) = &s.payload {
                    if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                        if !self.last_app.is_empty() && self.last_app != app {
                            self.memory.observe_transition(&self.last_app, app);
                        }
                        self.last_app = app.to_string();
                    }
                }
            }
        }
        if self.last_pub.elapsed() < Duration::from_secs(3) {
            return Vec::new();
        }
        self.last_pub = Instant::now();
        if self.last_app.is_empty() {
            return Vec::new();
        }
        if let Some((next, p)) = self.memory.next_after(&self.last_app) {
            if p >= 0.3 {
                let conf = (p * 0.9).min(0.9);
                return vec![Signal::new("learner/transition", "learning/transition", p, conf)
                    .with_payload(serde_json::json!({ "app": next }))];
            }
        }
        Vec::new()
    }
}

// ── DecisionNode ───────────────────────────────────────────────────────────

pub struct DecisionNode {
    last_launch: String,
    last_dnd: bool,
}

impl DecisionNode {
    pub fn new() -> Self {
        Self { last_launch: String::new(), last_dnd: false }
    }
}

impl Node for DecisionNode {
    fn id(&self) -> &str { "decision" }
    fn kind(&self) -> NodeKind { NodeKind::Decision }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        let mut out = Vec::new();
        let mut context_activity = "unknown";
        let mut focus_belief = 0.0;
        let mut idle_min = 0.0;
        let mut routine_app = String::new();
        let mut routine_p = 0.0;
        let mut trans_app = String::new();
        let mut trans_p = 0.0;
        let mut on_battery = false;
        let mut battery_pct = 100.0;

        for s in signals {
            match s.kind.as_str() {
                "context" => {
                    if let Some(p) = &s.payload {
                        context_activity = p.get("activity").and_then(|v| v.as_str()).unwrap_or("unknown");
                        focus_belief = p.get("focus").and_then(|v| v.as_f64()).unwrap_or(0.0);
                        idle_min = p.get("idle_min").and_then(|v| v.as_f64()).unwrap_or(0.0);
                        on_battery = p.get("on_battery").and_then(|v| v.as_bool()).unwrap_or(false);
                        battery_pct = p.get("battery").and_then(|v| v.as_f64()).unwrap_or(100.0);
                    }
                }
                "learning/focus_hour" => focus_belief = focus_belief.max(s.value),
                "learning/routine" => {
                    if let Some(p) = &s.payload {
                        routine_app = p.get("app").and_then(|v| v.as_str()).unwrap_or("").to_string();
                        routine_p = s.value;
                    }
                }
                "learning/transition" => {
                    if let Some(p) = &s.payload {
                        trans_app = p.get("app").and_then(|v| v.as_str()).unwrap_or("").to_string();
                        trans_p = s.value;
                    }
                }
                _ => {}
            }
        }

        // LaunchApp from routine (hour-based)
        if !routine_app.is_empty() && routine_p >= 0.5 && routine_app != self.last_launch {
            self.last_launch = routine_app.clone();
            out.push(Signal::new("decision", "decision/launch", routine_p, routine_p.min(0.95))
                .with_payload(serde_json::json!({ "app": routine_app })));
        }

        // LaunchApp from transition (app→app sequence)
        if !trans_app.is_empty() && trans_p >= 0.5 && trans_app != self.last_launch {
            self.last_launch = trans_app.clone();
            out.push(Signal::new("decision", "decision/launch", trans_p, trans_p.min(0.95))
                .with_payload(serde_json::json!({ "app": trans_app })));
        }

        // DND from deep work
        let want_dnd = context_activity == "deep_work" || (focus_belief > 0.6 && idle_min < 5.0);
        if want_dnd && !self.last_dnd {
            self.last_dnd = true;
            out.push(Signal::new("decision", "decision/dnd", 1.0, focus_belief.max(0.6)));
        } else if !want_dnd && self.last_dnd {
            self.last_dnd = false;
            out.push(Signal::new("decision", "decision/dnd_off", 1.0, 0.6));
        }

        // Power profile
        if on_battery && battery_pct >= 0.0 && battery_pct < 20.0 {
            out.push(Signal::new("decision", "decision/power", 1.0, 0.9)
                .with_payload(serde_json::json!({ "profile": "power-saver" })));
        }

        out
    }
}

// ── ActionExecutor ────────────────────────────────────────────────────────

pub struct ActionExecutor;

impl ActionExecutor {
    pub fn new() -> Self {
        ActionExecutor
    }
    fn run(cmd: &str, args: &[&str]) {
        let _ = Command::new(cmd).args(args).spawn();
    }
}

impl Node for ActionExecutor {
    fn id(&self) -> &str { "action/exec" }
    fn kind(&self) -> NodeKind { NodeKind::Action }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "decision/launch" => {
                    if let Some(p) = &s.payload {
                        if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                            Self::run("hyprctl", &["dispatch", &format!("hl.dsp.exec_cmd(\"{}\")", app)]);
                            Self::run("notify-send", &["-t", "2000", "BlackNode", &format!("Opening {} (routine)", app)]);
                        }
                    }
                }
                "decision/dnd" => {
                    Self::run("dunstctl", &["set-paused", "true"]);
                    Self::run("notify-send", &["-t", "2000", "BlackNode", "DND enabled (focus mode)"]);
                }
                "decision/dnd_off" => {
                    Self::run("dunstctl", &["set-paused", "false"]);
                    Self::run("notify-send", &["-t", "2000", "BlackNode", "DND disabled"]);
                }
                "decision/power" => {
                    Self::run("powerprofilesctl", &["set", "power-saver"]);
                }
                _ => {}
            }
        }
        Vec::new()
    }
}

// ── FeedbackLearner ─────────────────────────────────────────────────────────

pub struct FeedbackLearner {
    memory: Arc<Memory>,
    last_decision: Option<(Instant, String)>,
}

impl FeedbackLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_decision: None }
    }
}

impl Node for FeedbackLearner {
    fn id(&self) -> &str { "learner/feedback" }
    fn kind(&self) -> NodeKind { NodeKind::Learning }
    fn process(&mut self, signals: &[Signal]) -> Vec<Signal> {
        for s in signals {
            if s.kind.starts_with("decision/") {
                if let Some(p) = &s.payload {
                    let app = p.get("app").and_then(|v| v.as_str()).unwrap_or("").to_string();
                    if !app.is_empty() {
                        self.last_decision = Some((Instant::now(), app));
                    }
                }
            }
        }
        if let Some((ts, ref app)) = self.last_decision {
            let elapsed = ts.elapsed();
            if elapsed > Duration::from_secs(60) {
                self.last_decision = None;
                return Vec::new();
            }
            for s in signals {
                if s.kind == "sensor/focus" && elapsed < Duration::from_secs(30) {
                    let h = local_hour();
                    self.memory.observe_window(app, h);
                } else if s.kind == "sensor/distract" && elapsed < Duration::from_secs(30) {
                    let h = local_hour();
                    self.memory.observe_window(app, h);
                }
            }
        }
        Vec::new()
    }
}
