use crate::node::core::*;
use crate::node::graph::NodeGraph;
use crate::memory::Memory;
use std::sync::Arc;
use std::time::{Duration, Instant};
use std::process::Command;

pub fn register(graph: &mut NodeGraph, memory: Arc<Memory>) {
    graph.add(WindowWatcher::new());
    graph.add(WindowScanner::new());
    graph.add(SystemSensor::new());
    graph.add(BehaviorWatcher::new());
    graph.add(ContextNode::new());
    graph.add(FocusLearner::new(Arc::clone(&memory)));
    graph.add(RoutineProposer::new(Arc::clone(&memory)));
    graph.add(TransitionProposer::new(Arc::clone(&memory)));
    graph.add(DecisionNode::new(Arc::clone(&memory)));
    graph.add(ActionExecutor::new(Arc::clone(&memory)));
    graph.add(FeedbackLearner::new(Arc::clone(&memory)));
}

// ── helpers ─────────────────────────────────────────────────────────────────

fn hyprctl(args: &[&str]) -> Option<String> {
    Command::new("hyprctl").args(args).output()
        .ok().and_then(|o| String::from_utf8(o.stdout).ok())
}

fn parse_active_window(json: &str) -> Option<(String, i64, bool)> {
    let v: serde_json::Value = serde_json::from_str(json).ok()?;
    let app = v.get("class")?.as_str()?.to_string();
    let ws = v.get("workspace")?.get("id")?.as_i64().unwrap_or(-1);
    let fs = v.get("fullscreen").and_then(|v| v.as_bool()).unwrap_or(false);
    Some((app, ws, fs))
}

fn parse_clients(json: &str) -> Vec<(String, i64, bool)> {
    let v: Vec<serde_json::Value> = serde_json::from_str(json).unwrap_or_default();
    v.iter().filter_map(|c| {
        let app = c.get("class")?.as_str()?.to_string();
        let ws = c.get("workspace")?.get("id")?.as_i64().unwrap_or(-1);
        let fs = c.get("fullscreen").and_then(|v| v.as_bool()).unwrap_or(false);
        Some((app, ws, fs))
    }).collect()
}

// ── WindowWatcher (Sensor) ──────────────────────────────────────────────────

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
    fn process(&mut self, _signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        if self.last_poll.elapsed() < Duration::from_secs(1) {
            return vec![];
        }
        self.last_poll = Instant::now();
        let json = match hyprctl(&["activewindow", "-j"]) {
            Some(j) => j,
            None => return vec![],
        };
        let (app, ws, fs) = match parse_active_window(&json) {
            Some(x) => x,
            None => return vec![],
        };
        state.active_window = app.clone();
        state.active_workspace = ws;
        state.active_fullscreen = fs;
        if app == self.last_app {
            return vec![];
        }
        self.last_app = app.clone();
        vec![Signal::new("sensor/window", "sensor/window", 1.0, 1.0)
            .with_payload(serde_json::json!({ "app": app, "workspace_id": ws, "fullscreen": fs }))]
    }
}

// ── WindowScanner (Sensor) ───────────────────────────────────────────────────

pub struct WindowScanner {
    last_poll: Instant,
}

impl WindowScanner {
    pub fn new() -> Self {
        Self { last_poll: Instant::now() }
    }
}

impl Node for WindowScanner {
    fn id(&self) -> &str { "sensor/scanner" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, _signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        if self.last_poll.elapsed() < Duration::from_secs(5) {
            return vec![];
        }
        self.last_poll = Instant::now();
        let json = match hyprctl(&["clients", "-j"]) {
            Some(j) => j,
            None => return vec![],
        };
        let clients = parse_clients(&json);
        state.windows = clients.iter().map(|(a, w, f)| WindowInfo {
            app: a.clone(),
            workspace: *w,
            fullscreen: *f,
        }).collect();
        vec![]
    }
}

// ── BehaviorWatcher (Sensor) ───────────────────────────────────────────────────

pub struct BehaviorWatcher {
    path: String,
    last_len: usize,
}

impl BehaviorWatcher {
    pub fn new() -> Self {
        let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
        Self { path: format!("{}/.local/share/blacknode/brain/behavior.json", home), last_len: 0 }
    }
}

impl Node for BehaviorWatcher {
    fn id(&self) -> &str { "sensor/behavior" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, _signals: &[Signal], _state: &mut BrainState) -> Vec<Signal> {
        let content = match std::fs::read_to_string(&self.path) {
            Ok(c) => c,
            Err(_) => return vec![],
        };
        let lines: Vec<&str> = content.lines().collect();
        let cur = lines.len();
        if cur <= self.last_len {
            return vec![];
        }
        let mut out = vec![];
        for line in &lines[self.last_len..] {
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
        self.last_len = cur;
        out
    }
}

// ── SystemSensor (Sensor) ───────────────────────────────────────────────────

pub struct SystemSensor {
    bat_poll: Instant,
    net_poll: Instant,
}

impl SystemSensor {
    pub fn new() -> Self {
        Self { bat_poll: Instant::now(), net_poll: Instant::now() }
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
        .map(|e| e.filter_map(|e| e.ok()).any(|e| {
            std::fs::read_to_string(e.path().join("operstate"))
                .ok().map(|s| s.trim() == "up").unwrap_or(false)
        })).unwrap_or(false)
}

impl Node for SystemSensor {
    fn id(&self) -> &str { "sensor/system" }
    fn kind(&self) -> NodeKind { NodeKind::Sensor }
    fn process(&mut self, _signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        if self.bat_poll.elapsed() >= Duration::from_secs(30) {
            self.bat_poll = Instant::now();
            let (pct, on_bat) = read_battery();
            state.on_battery = on_bat;
            state.battery_pct = pct;
        }
        if self.net_poll.elapsed() >= Duration::from_secs(10) {
            self.net_poll = Instant::now();
            state.network = read_network();
        }
        vec![]
    }
}

// ── ContextNode (Context) ────────────────────────────────────────────────────

const MEDIA_APPS: &[&str] = &["spotify", "vlc", "mpv", "youtube-music", "rhythmbox"];
const CODE_APPS: &[&str] = &["code", "neovim", "vim", "emacs", "zed", "cursor", "helix"];
const GAME_APPS: &[&str] = &["steam", "lutris", "heroic", "bottles"];
const TERM_APPS: &[&str] = &["kitty", "alacritty", "wezterm", "ghostty", "foot", "terminal"];

pub struct ContextNode {
    last_emit: Instant,
    instability: f64,
    prev_windows: Vec<String>,
    window_history: Vec<String>,
    history_idx: usize,
}

impl ContextNode {
    pub fn new() -> Self {
        Self {
            last_emit: Instant::now(),
            instability: 0.0,
            prev_windows: vec![],
            window_history: vec![""; 10].into_iter().map(|s| s.to_string()).collect(),
            history_idx: 0,
        }
    }
    fn infer(&self, state: &BrainState) -> (String, f64) {
        let active = state.active_window.to_lowercase();
        let all: Vec<&str> = state.windows.iter().map(|w| w.app.as_str()).collect();

        // Check idle first
        let idle_min = state.idle_min;
        if idle_min > 5.0 {
            return ("idle".into(), (0.6 + idle_min / 60.0).min(0.95));
        }

        // Gaming: steam/lutris open + fullscreen app OR game launcher focused
        let has_game_launcher = all.iter().any(|a| GAME_APPS.iter().any(|g| a.to_lowercase().contains(g)));
        if has_game_launcher || (state.active_fullscreen && !active.is_empty() && !CODE_APPS.iter().any(|c| active.contains(c))) {
            return ("gaming".into(), 0.85);
        }

        // Deep work / coding: code/neovim focused + high focus
        if CODE_APPS.iter().any(|c| active.contains(c)) && state.context.focus > 0.6 {
            return ("deep_work".into(), state.context.focus);
        }

        // Terminal work
        if TERM_APPS.iter().any(|t| active.contains(t)) && state.context.focus > 0.6 {
            return ("deep_work".into(), state.context.focus.max(0.7));
        }

        // Context switching: many different windows recently
        if self.instability > 0.5 {
            return ("context_switching".into(), self.instability);
        }

        // Media
        if MEDIA_APPS.iter().any(|m| active.contains(m)) {
            return ("media".into(), 0.9);
        }

        // Browsing (default when active window exists)
        if !active.is_empty() {
            return ("browsing".into(), 0.5);
        }

        ("unknown".into(), 0.1)
    }
}

impl Node for ContextNode {
    fn id(&self) -> &str { "context" }
    fn kind(&self) -> NodeKind { NodeKind::Context }
    fn process(&mut self, signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "sensor/window" => {
                    self.window_history[self.history_idx % 10] = s.payload.as_ref()
                        .and_then(|p| p.get("app").and_then(|v| v.as_str())).unwrap_or("").to_string();
                    self.history_idx += 1;
                    if self.history_idx > 10 {
                        // Track window switches for instability
                        let unique: std::collections::HashSet<&String> = self.window_history.iter().collect();
                        self.instability = 1.0 - (unique.len() as f64 / 10.0);
                    }
                }
                _ => {}
            }
        }
        if self.last_emit.elapsed() < Duration::from_secs(1) {
            return vec![];
        }
        self.last_emit = Instant::now();

        state.context.idle_min = state.idle_min;
        let (activity, confidence) = self.infer(state);
        state.context.activity = activity.clone();
        state.context.confidence = confidence;

        vec![Signal::new("context", "context", confidence, confidence)
            .with_payload(serde_json::json!({
                "activity": activity,
                "confidence": confidence,
                "focus": state.context.focus,
                "idle_min": state.idle_min,
            }))]
    }
}

// ── FocusLearner (Context) ───────────────────────────────────────────────────

pub struct FocusLearner {
    memory: Arc<Memory>,
}

impl FocusLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory }
    }
}

impl Node for FocusLearner {
    fn id(&self) -> &str { "learner/focus" }
    fn kind(&self) -> NodeKind { NodeKind::Context }
    fn process(&mut self, signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "sensor/focus" => {
                    state.context.focus = (state.context.focus + 1.0).min(1.0);
                    let h = crate::time::local_hour();
                    self.memory.observe_focus(h, true);
                }
                "sensor/distract" => {
                    state.context.focus = (state.context.focus - 0.3).max(0.0);
                    let h = crate::time::local_hour();
                    self.memory.observe_focus(h, false);
                }
                _ => {}
            }
        }
        vec![]
    }
}

// ── RoutineProposer (Proposal) ──────────────────────────────────────────────

pub struct RoutineProposer {
    memory: Arc<Memory>,
    last_propose: Instant,
}

impl RoutineProposer {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_propose: Instant::now() }
    }
}

impl Node for RoutineProposer {
    fn id(&self) -> &str { "proposer/routine" }
    fn kind(&self) -> NodeKind { NodeKind::Proposal }
    fn process(&mut self, _signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        if self.last_propose.elapsed() < Duration::from_secs(30) {
            return vec![];
        }
        self.last_propose = Instant::now();
        let h = crate::time::local_hour();
        let (app, prob) = match self.memory.routine_for(h) {
            Some(x) => x,
            None => return vec![],
        };
        if prob < 0.5 {
            return vec![];
        }
        let benefit = prob * 15.0;
        let risk = 5.0;
        vec![Signal::new("proposer/routine", "proposal/launch", benefit, prob)
            .with_payload(serde_json::json!({
                "app": app,
                "benefit": benefit,
                "risk": risk,
                "reason": format!("routine at hour {} ({:.0}%)", h, prob * 100.0),
            }))]
    }
}

// ── TransitionProposer (Proposal) ────────────────────────────────────────────

pub struct TransitionProposer {
    memory: Arc<Memory>,
    last_propose: Instant,
}

impl TransitionProposer {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_propose: Instant::now() }
    }
}

impl Node for TransitionProposer {
    fn id(&self) -> &str { "proposer/transition" }
    fn kind(&self) -> NodeKind { NodeKind::Proposal }
    fn process(&mut self, _signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        if state.active_window.is_empty() {
            return vec![];
        }
        let (next, prob) = match self.memory.next_after(&state.active_window) {
            Some(x) => x,
            None => return vec![],
        };
        if prob < 0.3 {
            return vec![];
        }
        let benefit = prob * 12.0;
        let risk = 7.0;
        vec![Signal::new("proposer/transition", "proposal/launch", benefit, prob)
            .with_payload(serde_json::json!({
                "app": next,
                "benefit": benefit,
                "risk": risk,
                "reason": format!("transition from {} ({:.0}%)", state.active_window, prob * 100.0),
            }))]
    }
}

// ── DecisionNode (Decision) ──────────────────────────────────────────────────

pub struct DecisionNode {
    memory: Arc<Memory>,
    last_launch: String,
    last_launch_ts: Instant,
    last_dnd: bool,
    last_dnd_ts: Instant,
}

impl DecisionNode {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self {
            memory,
            last_launch: String::new(),
            last_launch_ts: Instant::now(),
            last_dnd: false,
            last_dnd_ts: Instant::now(),
        }
    }
    fn is_app_open(&self, app: &str, state: &BrainState) -> bool {
        let al = app.to_lowercase();
        state.windows.iter().any(|w| w.app.to_lowercase() == al)
    }
    fn propose_dnd(&self, state: &BrainState) -> Option<ActionProposal> {
        let ctx = &state.context;
        if ctx.activity == "deep_work" || ctx.activity == "gaming" {
            let benefit = 20.0 + ctx.confidence * 10.0;
            let risk = 3.0;
            return Some(ActionProposal {
                action: "dnd".into(),
                params: serde_json::json!({}),
                benefit,
                risk,
                reason: format!("{} activity (conf {:.0}%)", ctx.activity, ctx.confidence * 100.0),
            });
        }
        if ctx.focus > 0.6 && ctx.idle_min < 5.0 {
            let benefit = ctx.focus * 15.0;
            let risk = 5.0;
            return Some(ActionProposal {
                action: "dnd".into(),
                params: serde_json::json!({}),
                benefit,
                risk,
                reason: format!("high focus ({:.0}%)", ctx.focus * 100.0),
            });
        }
        None
    }
    fn propose_power(&self, state: &BrainState) -> Option<ActionProposal> {
        if state.on_battery && state.battery_pct >= 0.0 && state.battery_pct < 20.0 {
            Some(ActionProposal {
                action: "power".into(),
                params: serde_json::json!({ "profile": "power-saver" }),
                benefit: 30.0,
                risk: 1.0,
                reason: format!("battery {:.0}%", state.battery_pct),
            })
        } else if state.on_battery && state.battery_pct < 50.0 {
            Some(ActionProposal {
                action: "power".into(),
                params: serde_json::json!({ "profile": "balanced" }),
                benefit: 10.0,
                risk: 1.0,
                reason: format!("battery {:.0}%", state.battery_pct),
            })
        } else {
            None
        }
    }
    fn propose_launch(&self, proposal: &ActionProposal, state: &BrainState) -> ActionProposal {
        let app = proposal.params.get("app").and_then(|v| v.as_str()).unwrap_or("");

        // Precondition 1: already open?
        let already_open = self.is_app_open(app, state);

        // Precondition 2: recently rejected?
        let recent_reject = false; // TODO: check action_history in memory

        // Precondition 3: context compatibility
        let ctx = &state.context;
        let context_risk = match ctx.activity.as_str() {
            "deep_work" => 20.0,
            "gaming" => 15.0,
            "context_switching" => 5.0,
            "browsing" => 2.0,
            "idle" => 1.0,
            _ => 10.0,
        };

        let mut p = proposal.clone();
        if already_open {
            p.benefit = 0.0;
            p.risk = 100.0;
            p.reason = format!("{} already open", app);
        } else if recent_reject {
            p.benefit *= 0.1;
            p.risk += 30.0;
            p.reason = format!("{} recently rejected", app);
        } else {
            p.reason = proposal.reason.clone();
        }
        p.risk += context_risk;
        p
    }
}

impl Node for DecisionNode {
    fn id(&self) -> &str { "decision" }
    fn kind(&self) -> NodeKind { NodeKind::Decision }
    fn process(&mut self, signals: &[Signal], state: &mut BrainState) -> Vec<Signal> {
        // Collect launch proposals from signals
        let mut candidates: Vec<ActionProposal> = vec![];

        // Add internally-generated proposals (dnd, power)
        if let Some(p) = self.propose_dnd(state) {
            candidates.push(p);
        }
        if let Some(p) = self.propose_power(state) {
            candidates.push(p);
        }

        // Add launch proposals from signals
        for s in signals {
            if s.kind == "proposal/launch" {
                if let Some(p) = &s.payload {
                    let app = p.get("app").and_then(|v| v.as_str()).unwrap_or("").to_string();
                    let benefit = p.get("benefit").and_then(|v| v.as_f64()).unwrap_or(0.0);
                    let risk = p.get("risk").and_then(|v| v.as_f64()).unwrap_or(10.0);
                    let reason = p.get("reason").and_then(|v| v.as_str()).unwrap_or("").to_string();
                    let proposal = ActionProposal {
                        action: "launch".into(),
                        params: serde_json::json!({ "app": app }),
                        benefit,
                        risk,
                        reason,
                    };
                    let scored = self.propose_launch(&proposal, state);
                    candidates.push(scored);
                }
            }
        }

        if candidates.is_empty() {
            return vec![];
        }

        // Score and rank: score = benefit - risk
        candidates.sort_by(|a, b| {
            let sa = a.benefit - a.risk;
            let sb = b.benefit - b.risk;
            sb.partial_cmp(&sa).unwrap_or(std::cmp::Ordering::Equal)
        });

        let best = &candidates[0];
        let score = best.benefit - best.risk;
        let cooldown = Duration::from_secs(5);

        // Only act if score is positive and action hasn't been done recently
        match best.action.as_str() {
            "launch" => {
                let app = best.params.get("app").and_then(|v| v.as_str()).unwrap_or("");
                if score > 0.0 && app != self.last_launch && self.last_launch_ts.elapsed() >= cooldown {
                    self.last_launch = app.to_string();
                    self.last_launch_ts = Instant::now();
                    return vec![Signal::new("decision", "decision/launch", best.benefit, best.benefit.min(0.95))
                        .with_payload(serde_json::json!({
                            "app": app,
                            "reason": best.reason,
                            "score": score,
                        }))];
                }
            }
            "dnd" => {
                if score > 0.0 && !self.last_dnd {
                    self.last_dnd = true;
                    self.last_dnd_ts = Instant::now();
                    return vec![Signal::new("decision", "decision/dnd", 1.0, 0.75)
                        .with_payload(serde_json::json!({ "reason": best.reason, "score": score }))];
                }
            }
            "power" => {
                if score > 0.0 {
                    return vec![Signal::new("decision", "decision/power", 1.0, 0.9)
                        .with_payload(serde_json::json!({ "profile": "power-saver" }))];
                }
            }
            _ => {}
        }

        // DND off when context no longer warrants it
        let dnd_off_score = {
            let ctx = &state.context;
            if ctx.activity == "deep_work" || ctx.activity == "gaming" { 0.0 }
            else if ctx.focus < 0.4 && self.last_dnd && self.last_dnd_ts.elapsed() >= Duration::from_secs(30) { 5.0 }
            else { 0.0 }
        };
        if dnd_off_score > 0.0 {
            self.last_dnd = false;
            return vec![Signal::new("decision", "decision/dnd_off", 1.0, 0.6)];
        }

        vec![]
    }
}

// ── ActionExecutor (Action) ──────────────────────────────────────────────────

pub struct ActionExecutor {
    memory: Arc<Memory>,
    last_exec: std::collections::HashMap<String, Instant>,
}

impl ActionExecutor {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, last_exec: std::collections::HashMap::new() }
    }
    fn is_app_class_open(app: &str) -> bool {
        let al = app.to_lowercase();
        hyprctl(&["clients", "-j"]).and_then(|json| {
            let v: Vec<serde_json::Value> = serde_json::from_str(&json).ok()?;
            Some(v.iter().any(|c| {
                c.get("class").and_then(|v| v.as_str()).map(|s| s.to_lowercase() == al).unwrap_or(false)
            }))
        }).unwrap_or(false)
    }
    fn exec(cmd: &str, args: &[&str]) {
        let _ = Command::new(cmd).args(args).spawn();
    }
    fn launch_app(app: &str) -> bool {
        if Self::is_app_class_open(app) {
            return false;
        }
        Self::exec("hyprctl", &["dispatch", "exec", app]);
        true
    }
}

impl Node for ActionExecutor {
    fn id(&self) -> &str { "action/exec" }
    fn kind(&self) -> NodeKind { NodeKind::Action }
    fn process(&mut self, signals: &[Signal], _state: &mut BrainState) -> Vec<Signal> {
        for s in signals {
            match s.kind.as_str() {
                "decision/launch" => {
                    if let Some(p) = &s.payload {
                        if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                            let now = Instant::now();
                            let cooldown = self.last_exec.get(app).map(|t| t.elapsed()).unwrap_or(Duration::from_secs(999));
                            if cooldown < Duration::from_secs(10) {
                                continue;
                            }
                            // Final precondition check: is app already open?
                            if Self::is_app_class_open(app) {
                                continue;
                            }
                            self.last_exec.insert(app.to_string(), now);
                            if Self::launch_app(app) {
                                Self::exec("notify-send", &["BlackNode", &format!("→ {}", app)]);
                            }
                        }
                    }
                }
                "decision/dnd" => {
                    Self::exec("dunstctl", &["set-paused", "true"]);
                    Self::exec("notify-send", &["BlackNode", "DND ON"]);
                }
                "decision/dnd_off" => {
                    Self::exec("dunstctl", &["set-paused", "false"]);
                    Self::exec("notify-send", &["BlackNode", "DND OFF"]);
                }
                "decision/power" => {
                    Self::exec("powerprofilesctl", &["set", "power-saver"]);
                    Self::exec("notify-send", &["BlackNode", "Power saver ON"]);
                }
                _ => {}
            }
        }
        vec![]
    }
}

// ── FeedbackLearner (Learning) ──────────────────────────────────────────────

pub struct FeedbackLearner {
    memory: Arc<Memory>,
    launched_app: Option<(String, Instant)>,
    last_window: String,
}

impl FeedbackLearner {
    pub fn new(memory: Arc<Memory>) -> Self {
        Self { memory, launched_app: None, last_window: String::new() }
    }
}

impl Node for FeedbackLearner {
    fn id(&self) -> &str { "learner/feedback" }
    fn kind(&self) -> NodeKind { NodeKind::Learning }
    fn process(&mut self, signals: &[Signal], _state: &mut BrainState) -> Vec<Signal> {
        // Observe natural window transitions → learn routines + transitions
        for s in signals {
            if s.kind == "sensor/window" {
                if let Some(p) = &s.payload {
                    if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                        let h = crate::time::local_hour();
                        self.memory.observe_window(app, h);
                        if !self.last_window.is_empty() && self.last_window != app {
                            self.memory.observe_transition(&self.last_window, app);
                        }
                        self.last_window = app.to_string();
                    }
                }
            }
        }

        // Track when we launch something
        for s in signals {
            if s.kind == "decision/launch" {
                if let Some(p) = &s.payload {
                    if let Some(app) = p.get("app").and_then(|v| v.as_str()) {
                        self.launched_app = Some((app.to_string(), Instant::now()));
                    }
                }
            }
        }

        // If we launched something, check if it appeared (accepted)
        if let Some((ref app, ts)) = self.launched_app {
            if ts.elapsed() > Duration::from_secs(3) {
                let is_open = ActionExecutor::is_app_class_open(app);
                if !is_open {
                    // App didn't appear → user rejected it (closed it, or it failed to launch)
                    // Reduce the transition weight
                }
                self.launched_app = None;
            }
        }

        vec![]
    }
}