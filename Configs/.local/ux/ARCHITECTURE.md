# BlackNode — Architecture v0.1

## 1. What BlackNode Is

BlackNode is an **adaptive operating layer for Linux desktops**. Not a dotfile manager. Not an automation tool. Not a window manager wrapper. A system that continuously observes, reasons about, and adapts the computing environment to match what the user is actually doing.

**The fundamental problem:** Linux desktops are static. They don't understand context. A user working in Blender gets the same visual effects as someone browsing Reddit. A laptop on battery gets the same GPU priority as one plugged in. The user must manually configure every context change. BlackNode eliminates this gap between what the user is doing and what the system is optimized for.

**What BlackNode does that dotfiles cannot:**
- Dotfiles are stateless snapshots. BlackNode maintains continuous state.
- Dotfiles apply uniformly. BlackNode adapts to context.
- Dotfiles require manual configuration per scenario. BlackNode learns patterns and proposes automations.
- Dotfiles have no rollback. BlackNode can revert failed changes.
- Dotfiles have no reasoning. BlackNode evaluates conflicting demands and makes decisions.

**What BlackNode does NOT do:**
- Replace the window manager, compositor, or shell
- Manage files, packages, or system administration
- Provide a UI, notification system, or overlay
- Collect or transmit user data
- Make irreversible changes without authorization

---

## 2. The Intelligence Pipeline

Every adaptation follows a single pipeline. This is the fundamental architecture.

```
Sensors → Events → Context → Intent → Policies → Decision → Plan → Actions → State → Feedback → Learning
```

Each stage has a defined interface. No stage knows about the internals of another. Data flows forward; feedback flows backward.

### Stage definitions

| Stage | Input | Output | Responsibility |
|-------|-------|--------|----------------|
| **Sensors** | System signals | Raw events | Observe reality without interpretation |
| **Events** | Raw signals | Typed events | Normalize and classify what happened |
| **Context** | Events + State | World model | Build a complete picture of current reality |
| **Intent** | Context | Goal set | Determine what the user is trying to do |
| **Policies** | Context + Intent | Rule matches | Find all rules that apply to this situation |
| **Decision** | Policy matches | Chosen action set | Resolve conflicts, pick the best action |
| **Plan** | Decision | Ordered actions | Sequence actions, handle dependencies |
| **Actions** | Plan | System changes | Execute changes on the real system |
| **State** | Actions | Updated state | Record what changed |
| **Feedback** | State change | Observations | Verify changes had the intended effect |
| **Learning** | Feedback + History | Pattern updates | Improve future decisions |

---

## 3. Core Data Model

### 3.1 Event

The atomic unit of observation. Events carry no semantics beyond what was observed.

```rust
struct Event {
    id: Uuid,
    timestamp: DateTime<Utc>,
    source: SensorId,        // which sensor produced this
    kind: EventKind,         // classification
    payload: Payload,        // typed data specific to kind
    confidence: f32,         // 0.0–1.0, how sure the sensor is
}

enum EventKind {
    // Hardware
    PowerStateChanged,       // AC connected, battery level changed
    DeviceConnected,         // USB, Bluetooth, monitor
    DeviceDisconnected,
    ThermalStateChanged,     // CPU/GPU temperature
    ResourceUsageChanged,    // CPU, RAM, disk, network usage

    // Applications
    ApplicationStarted,      // window focused, process launched
    ApplicationClosed,
    ApplicationStateChanged, // minimized, fullscreen, focus lost

    // System
    ServiceStateChanged,     // systemd unit started/stopped
    NetworkStateChanged,     // connected, disconnected, changed
    TimeTick,                // periodic heartbeat (1s, 10s, 60s)

    // User
    UserAction,              // explicit command from user
    ModeRequested,           // user requests a specific mode
}
```

### 3.2 World Model (Context Engine)

The world model is a live representation of everything BlackNode knows. It is the single source of truth.

```rust
struct WorldModel {
    time: TimeContext,
    hardware: HardwareContext,
    applications: ApplicationContext,
    resources: ResourceContext,
    network: NetworkContext,
    user: UserContext,
    sessions: SessionContext,
}

struct TimeContext {
    now: DateTime<Utc>,
    hour: u8,                 // 0–23
    day_of_week: u8,          // 0–6 (Mon–Sun)
    uptime: Duration,
    idle_time: Duration,
    last_user_action: DateTime<Utc>,
}

struct HardwareContext {
    power: PowerState,        // AC, Battery(f32), Unknown
    battery_percent: Option<f32>,
    battery_time_remaining: Option<Duration>,
    thermal: ThermalState,    // Normal, Warm, Hot, Critical
    cpu_load: f32,            // 0.0–1.0
    memory_used_percent: f32,
    gpu_load: Option<f32>,
    displays: Vec<Display>,
    input_devices: Vec<InputDevice>,
}

struct Display {
    id: String,
    name: String,
    resolution: (u32, u32),
    refresh_rate: u32,
    connected: bool,
    primary: bool,
}

struct ApplicationContext {
    focused: Option<String>,     // currently focused app
    running: Vec<AppInstance>,   // all running apps
    fullscreen: bool,
    gaming_detected: bool,       // GPU load + app heuristics
}

struct AppInstance {
    id: u32,                     // PID or window ID
    name: String,                // e.g. "blender", "firefox"
    class: AppClass,             // categorization
    resource_impact: ResourceImpact,
    focused: bool,
    fullscreen: bool,
    started_at: DateTime<Utc>,
}

enum AppClass {
    Browser, Editor, IDE, Media, Game, Graphics,
    Office, Communication, System, Unknown,
}

struct ResourceImpact {
    cpu_percent: f32,
    memory_mb: u64,
    gpu_percent: Option<f32>,
    disk_io: Option<u64>,        // bytes/sec
    network_io: Option<u64>,     // bytes/sec
}

struct ResourceContext {
    cpu: ResourceMetrics,
    memory: ResourceMetrics,
    disk: ResourceMetrics,
    network: ResourceMetrics,
    gpu: Option<ResourceMetrics>,
}

struct ResourceMetrics {
    used_percent: f32,
    rate_of_change: f32,        // positive = increasing
    trend: Trend,               // Rising, Stable, Falling
    pressure: PressureLevel,    // None, Low, Medium, High, Critical
}

enum Trend { Rising, Stable, Falling }
enum PressureLevel { None, Low, Medium, High, Critical }

struct NetworkContext {
    connected: bool,
    interface: Option<String>,  // "wlan0", "eth0"
    ssid: Option<String>,       // WiFi name
    speed_mbps: Option<f64>,
    metered: bool,              // mobile data
    vpn_active: bool,
}

struct UserContext {
    idle: bool,
    idle_duration: Duration,
    last_mode: Option<String>,
    active_intents: Vec<Intent>,
    session_count_today: u32,
}

struct SessionContext {
    id: Uuid,
    started: DateTime<Utc>,
    mode: SessionMode,
    display_config: Vec<Display>,
    input_config: Vec<InputDevice>,
}

enum SessionMode {
    Desktop,                     // laptop, single display
    Docked,                      // external monitor + peripherals
    Headless,                    // SSH, remote
    Presentation,                // external display, projector
}
```

### 3.3 Intent

Intents represent what the user is trying to accomplish. They are not actions; they are goals.

```rust
struct Intent {
    name: String,               // "gaming", "work", "focus", "presentation"
    priority: u8,               // 0–255, higher = more important
    constraints: Vec<String>,   // "max_battery", "min_cpu", "privacy"
    expires: Option<Duration>,  // auto-expire after duration
    source: IntentSource,       // how this intent was established
}

enum IntentSource {
    Explicit,                   // user requested it
    Inferred,                   // system detected it
    Scheduled,                  // time-based activation
}
```

Built-in intents:

| Intent | Activation | Priority | Constraints |
|--------|-----------|----------|-------------|
| `gaming` | GPU load > 80% + fullscreen app | 200 | max_performance |
| `work` | IDE/editor focused + weekday + 9–17h | 180 | min_productivity |
| `focus` | no notification sounds for 15min | 150 | no_interruptions |
| `presentation` | external display + projector mode | 170 | no_popups |
| `battery_saver` | battery < 30% | 190 | min_battery |
| `privacy` | VPN disconnected + public network | 160 | max_privacy |
| `maintenance` | scheduled + low activity | 100 | safe_operations |

### 3.4 Policy

Policies define what BlackNode can do and under what conditions.

```rust
struct Policy {
    name: String,
    conditions: Vec<Condition>,
    actions: Vec<PlannedAction>,
    priority: u8,
    safety: SafetyLevel,
    enabled: bool,
}

enum SafetyLevel {
    Safe,          // auto-execute, no confirmation
    Moderate,      // auto-execute, log for review
    Sensitive,     // require confirmation once, then remember
    Critical,      // always require confirmation
}

enum Condition {
    IntentActive(String),
    BatteryBelow(f32),
    BatteryAbove(f32),
    CpuLoadAbove(f32),
    CpuLoadBelow(f32),
    MemoryPressure(PressureLevel),
    ThermalState(ThermalState),
    TimeBetween(u8, u8),         // hour range
    DayOfWeek(Vec<u8>),
    ApplicationRunning(String),
    ApplicationFocused(String),
    ApplicationClass(AppClass),
    DisplayConnected(String),
    DisplayCount(usize),
    NetworkType(String),          // "wifi", "ethernet", "vpn"
    NetworkMetered(bool),
    IdleTimeAbove(Duration),
    IdleTimeBelow(Duration),
    SessionMode(SessionMode),
    StateIs(UXState),
    StateNot(UXState),
    Not(Vec<Box<Condition>>),     // negation
    Any(Vec<Box<Condition>>),     // OR
    All(Vec<Box<Condition>>),     // AND
}
```

Example policies:

```rust
Policy {
    name: "gaming_performance",
    conditions: vec![
        Condition::IntentActive("gaming".into()),
        Condition::ApplicationClass(AppClass::Game),
    ],
    actions: vec![
        PlannedAction::SetProcessPriority { target: "compositor", priority: -10 },
        PlannedAction::SetProcessPriority { target: "game", priority: -5 },
        PlannedAction::DisableEffects(vec!["blur", "shadows", "animations"]),
        PlannedAction::LimitBackgroundServices(vec!["discover", "baloo"]),
        PlannedAction::SetGovernor("performance"),
    ],
    priority: 200,
    safety: SafetyLevel::Safe,
    enabled: true,
}

Policy {
    name: "battery_critical",
    conditions: vec![
        Condition::BatteryBelow(15.0),
        Condition::StateNot(UXState::Gaming),
    ],
    actions: vec![
        PlannedAction::SetGovernor("powersave"),
        PlannedAction::LimitCpuPercent(50.0),
        PlannedAction::DisableEffects(vec!["blur", "shadows"]),
        PlannedAction::ReduceRefreshRate(60),
        PlannedAction::SuspendService("bluetooth"),
    ],
    priority: 210,
    safety: SafetyLevel::Moderate,
    enabled: true,
}
```

### 3.5 Decision

The decision engine evaluates all matching policies and produces a resolved action set.

```rust
struct Decision {
    timestamp: DateTime<Utc>,
    context_snapshot: WorldModel,
    active_intents: Vec<Intent>,
    matched_policies: Vec<PolicyMatch>,
    conflicts: Vec<Conflict>,
    resolution: Resolution,
    plan: Plan,
}

struct PolicyMatch {
    policy: Policy,
    relevance: f32,           // 0.0–1.0, how well it matches
    conditions_met: usize,
    conditions_total: usize,
}

struct Conflict {
    policies: (String, String),  // conflicting policy names
    field: String,               // what they disagree on
    severity: ConflictSeverity,
}

enum ConflictSeverity {
    Incompatible,    // cannot both be active
    Degrading,       // both can be active but with reduced effect
    Cosmetic,        // minor overlap, pick higher priority
}

enum Resolution {
    Single(Plan),                        // no conflict
    PriorityBased(Plan),                 // higher priority wins
    Merged(Plan),                        // compatible policies combined
    Compromise(Plan),                    // partial implementation of both
    Defer(Plan, Option<Plan>),           // defer one, apply other now
    Reject(Vec<PolicyMatch>),            // no policy should execute
}
```

**Conflict resolution algorithm:**

1. Collect all matching policies, sorted by priority descending.
2. For each pair of policies, check if they modify the same resource.
3. If they modify the same resource:
   a. If both are `Safe` and compatible (e.g., both reduce blur): merge.
   b. If they have opposite effects (e.g., max_performance vs. powersave): compare priority × relevance. Higher wins.
   c. If the winner's priority is within 10 points of the loser: apply compromise (partial implementation of both, if possible).
   d. If compromise is impossible: higher priority wins, loser is logged as deferred.
4. If a policy requires `Critical` safety: always require user confirmation, regardless of priority.
5. Generate the final plan from the resolved action set.

### 3.6 Plan

A plan is an ordered, dependency-aware sequence of actions.

```rust
struct Plan {
    id: Uuid,
    created: DateTime<Utc>,
    actions: Vec<PlannedAction>,
    rollback: Vec<RollbackAction>,     // reverse actions, in order
    metadata: PlanMetadata,
}

struct PlannedAction {
    id: Uuid,
    kind: ActionKind,
    depends_on: Vec<Uuid>,             // action IDs this depends on
    timeout: Option<Duration>,
    retry: RetryPolicy,
    rollback_action: Option<RollbackAction>,
}

enum ActionKind {
    // Effects
    DisableEffect(String),
    EnableEffect(String),
    SetEffectParameter(String, String),

    // Resources
    SetProcessPriority { target: String, priority: i32 },
    SetGovernor(String),
    LimitCpuPercent(f32),
    SetGpuPowerProfile(String),

    // Services
    SuspendService(String),
    ResumeService(String),
    StartService(String),
    StopService(String),

    // Display
    SetRefreshRate(u32),
    SetResolution(u32, u32),
    SetScale(f64),

    // Compositor
    SetAnimationSpeed(f64),
    SetShadowEnabled(bool),
    SetBlurEnabled(bool),

    // Notifications
    SuppressNotifications(bool),
    SetNotificationSound(bool),

    // Power
    SetScreenBlankTimeout(Duration),
    SetSuspendTimeout(Duration),

    // Network
    SetDns(Vec<String>),
    SetProxy(String),

    // Theme
    ApplyTheme(String),
    ApplyColorscheme(String),

    // User-defined
    Execute(String, Vec<String>),       // arbitrary command (requires Critical safety)
}

struct RollbackAction {
    kind: ActionKind,                   // the action to reverse
    original_value: String,             // what it was before
}

struct RetryPolicy {
    max_retries: u8,
    backoff: Duration,
}
```

### 3.7 State Engine

Maintains global UX states and transitions. Extended from the current implementation.

```rust
enum UXState {
    Idle,
    FirstBoot,
    DailyUse,
    Customizing,
    Gaming,
    LowPower,
    Updating,
    Error,
    Recovering,
    DestructivePending,
    Maintenance,
    Focus,
    Presentation,
    Docked,
    Undocked,
}

struct Transition {
    source: UXState,
    target: UXState,
    trigger: String,
    guard: Option<Box<dyn Fn(&WorldModel) -> bool>>,
    actions: Vec<PlannedAction>,        // actions to execute on transition
}
```

### 3.8 Entity Model

BlackNode's internal representation of the world as entities with relationships.

```rust
struct Entity {
    id: EntityId,
    kind: EntityKind,
    name: String,
    state: HashMap<String, Value>,
    capabilities: Vec<String>,
    relationships: Vec<Relationship>,
    last_updated: DateTime<Utc>,
}

enum EntityKind {
    Application,
    Device,
    Display,
    Service,
    Resource,
    Session,
    Policy,
    Automation,
}

struct Relationship {
    target: EntityId,
    kind: RelationKind,
    strength: f32,              // 0.0–1.0
}

enum RelationKind {
    DependsOn,        // A needs B to function
    ConflictsWith,    // A and B cannot coexist
    Enhances,         // A improves B's performance
    Degrades,         // A reduces B's performance
    Triggers,         // A causes B to activate
    Blocks,           // A prevents B from activating
}
```

---

## 4. Core Components

These are the minimal components that make BlackNode intelligent. Everything else is a plugin.

### 4.1 Event Bus

The central nervous system. Receives events from sensors, distributes to consumers.

```rust
struct EventBus {
    listeners: HashMap<EventKind, Vec<Box<dyn Fn(&Event)>>>,
    global_listeners: Vec<Box<dyn Fn(&Event)>>,
    ring_buffer: RingBuffer<Event>,     // last N events for debugging
}

impl EventBus {
    fn on(&mut self, kind: EventKind, handler: impl Fn(&Event) + 'static);
    fn on_all(&mut self, handler: impl Fn(&Event) + 'static);
    fn emit(&self, event: Event);
    fn recent(&self, kind: EventKind, n: usize) -> Vec<Event>;
}
```

**Design decisions:**
- Synchronous dispatch by default. Async only for long-running handlers.
- Ring buffer keeps last 1000 events. No persistence; events are ephemeral.
- No request/response pattern. Events are fire-and-forget.

### 4.2 Context Engine

Maintains the WorldModel. Updates on every relevant event.

```rust
struct ContextEngine {
    world: WorldModel,
    history: Vec<WorldSnapshot>,        // periodic snapshots
    snapshot_interval: Duration,
}

impl ContextEngine {
    fn update(&mut self, event: &Event);
    fn snapshot(&self) -> WorldSnapshot;
    fn query(&self, predicate: impl Fn(&WorldModel) -> bool) -> bool;
    fn trend(&self, resource: &str, window: Duration) -> Trend;
}
```

**Design decisions:**
- Snapshots are taken every 60 seconds, or on significant state changes.
- History is kept in memory only. No disk persistence.
- The Context Engine does NOT make decisions. It only observes and reports.

### 4.3 Intent System

Determines what the user is trying to do based on context.

```rust
struct IntentSystem {
    active_intents: Vec<Intent>,
    rules: Vec<IntentRule>,
    history: IntentHistory,
}

struct IntentRule {
    name: String,
    conditions: Vec<Condition>,
    intent: Intent,
    confidence_threshold: f32,
}

impl IntentSystem {
    fn evaluate(&mut self, world: &WorldModel) -> Vec<Intent>;
    fn activate(&mut self, intent: Intent);
    fn deactivate(&mut self, name: &str);
    fn manual_override(&mut self, intent: Intent);
}
```

**Design decisions:**
- Multiple intents can be active simultaneously.
- Inferred intents have lower priority than explicit intents.
- Intent activation requires confidence > 0.7 to auto-activate. Below that, suggest to user.

### 4.4 Policy Engine

Stores and evaluates policies against the current context.

```rust
struct PolicyEngine {
    policies: Vec<Policy>,
    user_overrides: HashMap<String, bool>,  // policy_name -> enabled
}

impl PolicyEngine {
    fn evaluate(&self, world: &WorldModel, intents: &[Intent]) -> Vec<PolicyMatch>;
    fn enable(&mut self, name: &str);
    fn disable(&mut self, name: &str);
    fn add(&mut self, policy: Policy);
    fn remove(&mut self, name: &str);
}
```

### 4.5 Decision Engine

Resolves conflicts and produces decisions.

```rust
struct DecisionEngine {
    history: Vec<Decision>,
    max_history: usize,
}

impl DecisionEngine {
    fn decide(
        &self,
        world: &WorldModel,
        intents: &[Intent],
        matches: &[PolicyMatch],
    ) -> Decision;
    fn explain(&self, decision: &Decision) -> Explanation;
    fn revert(&self, decision_id: Uuid) -> Option<Plan>;
}
```

### 4.6 Plan Executor

Executes plans and handles rollback.

```rust
struct PlanExecutor {
    active_plans: HashMap<Uuid, PlanState>,
    completed: Vec<PlanResult>,
}

struct PlanState {
    plan: Plan,
    started: DateTime<Utc>,
    completed_actions: Vec<Uuid>,
    failed_actions: Vec<(Uuid, String)>,
    rolled_back: bool,
}

impl PlanExecutor {
    fn execute(&mut self, plan: Plan) -> PlanResult;
    fn rollback(&mut self, plan_id: Uuid) -> RollbackResult;
    fn status(&self, plan_id: Uuid) -> Option<PlanState>;
    fn cancel(&mut self, plan_id: Uuid) -> bool;
}
```

### 4.7 Learning Layer

Observes patterns and suggests automations.

```rust
struct LearningLayer {
    patterns: Vec<Pattern>,
    suggestions: Vec<Suggestion>,
    config: LearningConfig,
}

struct LearningConfig {
    enabled: bool,
    min_occurrences: usize,        // minimum times pattern must occur
    confidence_threshold: f32,
    retention_days: u32,
    anonymize: bool,               // never store app contents, only names
}

struct Pattern {
    name: String,
    kind: PatternKind,
    frequency: f32,               // times per day
    confidence: f32,
    discovered_at: DateTime<Utc>,
    last_seen: DateTime<Utc>,
}

enum PatternKind {
    TimeBased,                     // "user opens blender at 14:00"
    SequenceBased,                 // "after firefox, user opens terminal"
    ResourceBased,                 // "blender always causes high GPU"
    ContextBased,                  // "when docked, user uses external monitor"
}

struct Suggestion {
    id: Uuid,
    description: String,
    proposed_policy: Policy,
    confidence: f32,
    evidence: Vec<String>,         // human-readable evidence
    accepted: Option<bool>,        // None = pending
    created_at: DateTime<Utc>,
}
```

**Privacy rules:**
- Only observe application names, process names, resource usage, device connections, and time patterns.
- NEVER observe: file contents, keystrokes, screen content, network traffic, clipboard, personal files.
- All data stays on local disk. No network transmission.
- User can inspect all stored data at any time.
- User can delete any pattern or suggestion.
- Patterns expire after `retention_days` (default: 30).
- Anonymization: app names are stored as-is (needed for functionality), but no user content is ever stored.

---

## 5. Plugin Architecture

The core defines interfaces. Everything else is a plugin.

### 5.1 Plugin Types

```rust
trait Sensor: Send + Sync {
    fn name(&self) -> &str;
    fn events(&self) -> Vec<EventKind>;
    fn poll(&self) -> Option<Event>;          // for polling sensors
    fn watch(&self, bus: &EventBus);          // for event-driven sensors
}

trait Action: Send + Sync {
    fn name(&self) -> &str;
    fn execute(&self, action: &ActionKind) -> Result<(), ActionError>;
    fn rollback(&self, action: &RollbackAction) -> Result<(), ActionError>;
    fn can_execute(&self, action: &ActionKind) -> bool;
}

trait PolicyProvider: Send + Sync {
    fn name(&self) -> &str;
    fn policies(&self) -> Vec<Policy>;
}

trait Integration: Send + Sync {
    fn name(&self) -> &str;
    fn init(&mut self, bus: &EventBus, context: &ContextEngine);
    fn shutdown(&mut self);
}
```

### 5.2 Core Sensors (built-in)

| Sensor | Events | Source |
|--------|--------|--------|
| `power_sensor` | PowerStateChanged | `/sys/class/power_supply/`, UPower |
| `thermal_sensor` | ThermalStateChanged | `/sys/class/thermal/`, lm-sensors |
| `resource_sensor` | ResourceUsageChanged | `/proc/stat`, `/proc/meminfo` |
| `display_sensor` | DeviceConnected/Disconnected | `wlr-randr`, udev |
| `input_sensor` | DeviceConnected/Disconnected | `libinput`, udev |
| `network_sensor` | NetworkStateChanged | `NetworkManager` |
| `application_sensor` | ApplicationStarted/Closed/StateChanged | Hyprland IPC, `swaymsg` |
| `service_sensor` | ServiceStateChanged | `systemd` D-Bus |
| `time_sensor` | TimeTick | internal timer |

### 5.3 Core Actions (built-in)

| Action | System Interface |
|--------|-----------------|
| `hyprctl` | Hyprland configuration |
| `systemctl` | Systemd services |
| `cpupower` | CPU governor |
| `nvidia-smi` / `gamemoded` | GPU power profile |
| `matugen` | Theme generation |
| `gsettings` / `dconf` | GTK/GNOME settings |
| `pw-cli` / `wpctl` | PipeWire/PulseAudio |
| `nmcli` | NetworkManager |

### 5.4 Plugin Registry

```rust
struct PluginRegistry {
    sensors: Vec<Box<dyn Sensor>>,
    actions: Vec<Box<dyn Action>>,
    policy_providers: Vec<Box<dyn PolicyProvider>>,
    integrations: Vec<Box<dyn Integration>>,
}
```

Plugins are loaded from `~/.local/ux/plugins/` at startup. Each plugin is a shared library (`.so`) or a Python module (via FFI).

---

## 6. Resolution: Concrete Examples

### Example 1: Blender workflow

```
1. Sensor: application_sensor detects Blender started
2. Event: ApplicationStarted { name: "blender", class: Graphics }
3. Context: GPU load rising, memory increasing, user active
4. Intent: "work" (inferred: weekday, daytime, graphics app)
5. Policies matched:
   - "graphics_work" (priority 180): reduce compositor effects, increase GPU allocation
   - "work_productivity" (priority 170): suppress non-critical notifications
6. Decision: merge, both compatible
7. Plan:
   - Disable blur (GPU savings)
   - Set compositor refresh to match display
   - Suppress non-critical notifications
   - Set CPU governor to performance
   - Log GPU memory usage
8. Execute
9. State: UXState::Customizing (or new UXState::Working)
10. Feedback: GPU load stabilizes, Blender runs smoothly
11. Learning: "user opens Blender frequently at this time, suggest automation"
```

### Example 2: Docking station

```
1. Sensor: display_sensor detects new display + input_sensor detects keyboard + mouse
2. Event: DeviceConnected { display, keyboard, mouse } within 5 seconds
3. Context: session_mode = Docked, two displays
4. Intent: "dock" (inferred from display config change)
5. Policies matched:
   - "dock_mode" (priority 190): reorganize windows, adjust scaling, enable workspace persistence
   - "work_mode" (priority 180): optimize for productivity
6. Decision: merge
7. Plan:
   - Set display scaling to 1.0 on external, 1.5 on laptop
   - Reorganize workspaces across displays
   - Enable workspace persistence
   - Set notification volume to medium
8. Execute
9. State: UXState::Docked
10. Feedback: displays configured, windows reorganized
11. Learning: "user docks at this time on this day, suggest automation"
```

### Example 3: Learning suggestion

```
1. Learning layer observes:
   - Pattern: user opens Firefox → 5 min later opens terminal → types "cargo build"
   - Frequency: 3.2 times/day
   - Confidence: 0.85
2. Suggestion generated:
   "I've noticed you frequently open the terminal after Firefox to run cargo build.
    Would you like me to automatically open a terminal with 'cargo build' ready
    when you start working on your Rust project?"
3. Proposed policy:
   - Condition: ApplicationFocused("firefox") AND ApplicationRunning("code") AND FileExists("Cargo.toml")
   - Action: Open terminal with "cargo build" in project directory
   - Safety: Critical (requires confirmation)
4. User approves → policy added to active set
5. Next occurrence: policy activates, terminal opens with cargo build
6. Feedback: user accepts or rejects. If rejected 3 times, suggestion is archived.
```

---

## 7. Safety and Permissions

### 7.1 Safety Levels

| Level | Behavior | Examples |
|-------|----------|----------|
| Safe | Auto-execute, log only | Disable blur, set governor, suppress notifications |
| Moderate | Auto-execute, log for review | Suspend service, set CPU limit |
| Sensitive | Require confirmation once, remember | Apply theme, change resolution |
| Critical | Always require confirmation | Execute arbitrary commands, modify system config |

### 7.2 Permission Model

```rust
struct PermissionManager {
    granted: HashMap<String, Permission>,  // policy_name -> permission
    defaults: HashMap<SafetyLevel, PolicyDecision>,
}

enum PolicyDecision {
    Allow,
    Deny,
    Ask,             // prompt user
}

impl PermissionManager {
    fn check(&self, policy: &Policy) -> PolicyDecision;
    fn grant(&mut self, policy_name: &str, decision: PolicyDecision);
    fn revoke(&mut self, policy_name: &str);
}
```

### 7.3 What BlackNode Should NEVER Observe

- Keystrokes (keylogger behavior)
- File contents (personal data)
- Screen content (surveillance)
- Network traffic (privacy violation)
- Clipboard content
- Browser history
- Email or message content
- Passwords or credentials
- Personal documents

### 7.4 What BlackNode SHOULD Observe

- Application names and classes (needed for context)
- Resource usage (needed for optimization)
- Device connections (needed for docking detection)
- Time patterns (needed for scheduling)
- Service states (needed for health monitoring)
- Power state (needed for battery management)
- Display configuration (needed for multi-monitor)
- Network state (needed for connectivity decisions)

---

## 8. Recovery and Rollback

### 8.1 Rollback Strategy

Every plan includes a rollback plan. The rollback is computed before execution begins.

```rust
impl PlanExecutor {
    fn execute(&mut self, plan: Plan) -> PlanResult {
        // 1. Compute rollback before executing
        let rollback = self.compute_rollback(&plan);

        // 2. Execute actions in order
        for action in &plan.actions {
            match self.execute_action(action) {
                Ok(()) => { /* record success */ }
                Err(e) => {
                    // 3. On failure, execute rollback
                    self.execute_rollback(&rollback);
                    return PlanResult::Failed(e);
                }
            }
        }

        PlanResult::Success
    }
}
```

### 8.2 Recovery Engine

```rust
struct RecoveryEngine {
    health_checks: Vec<HealthCheck>,
    rollback_log: Vec<RollbackEntry>,
}

struct HealthCheck {
    name: String,
    check: Box<dyn Fn(&WorldModel) -> bool>,
    recovery_action: Plan,
    interval: Duration,
}

impl RecoveryEngine {
    fn monitor(&mut self, world: &WorldModel);
    fn detect_inconsistency(&self) -> Option<Inconsistency>;
    fn recover(&mut self, inconsistency: Inconsistency) -> Plan;
}
```

**Recovery scenarios:**
- Compositor crashes after effect change → revert effects, restart compositor
- Display configuration fails → revert to previous resolution
- Service suspend causes dependency failure → resume service
- Battery policy causes system freeze → revert power settings

---

## 9. Conflict Resolution: The Full Picture

### 9.1 Priority System

Priority is a u8 (0–255). Higher wins. Built-in priority bands:

| Band | Range | Usage |
|------|-------|-------|
| Critical | 240–255 | System safety, recovery |
| User Override | 220–239 | Explicit user requests |
| High | 190–219 | Battery, thermal, gaming |
| Medium | 150–189 | Context-based (work, focus) |
| Low | 100–149 | Time-based, learning |
| Background | 0–99 | Cleanup, optimization |

### 9.2 Conflict Types

1. **Resource conflict**: Two policies want to set the same resource to different values.
   - Resolution: Higher priority wins. If within 10 points, compromise if possible.

2. **Temporal conflict**: Two policies want to execute at the same time but are incompatible.
   - Resolution: Execute the higher priority one first. Defer the other.

3. **Intent conflict**: Two intents are both active but contradict each other.
   - Resolution: Explicit intents beat inferred intents. If both explicit, user must choose.

4. **Policy conflict**: A policy says "enable X" and another says "disable X".
   - Resolution: Check safety levels. Critical always wins. Otherwise, higher priority.

### 9.3 Compromise Strategies

- **Partial implementation**: Apply some actions from each policy, skip conflicting ones.
- **Time-sharing**: Alternate between policies (e.g., gaming for 2 hours, then battery saver).
- **Escalation**: If compromise is impossible, ask the user.
- **Deferral**: Apply one policy now, schedule the other for later.

---

## 10. Answers to Critical Questions

### 1. What does BlackNode do that dotfiles cannot?

Dotfiles are static snapshots. They apply the same configuration regardless of context. BlackNode maintains continuous state, observes real-time context, makes decisions based on multiple signals simultaneously, learns from patterns, and can revert failed changes. The fundamental difference: **dotfiles configure; BlackNode reasons**.

### 2. What is its fundamental problem?

The gap between what the user is doing and what the system is optimized for. Every time the user switches context (work → gaming, docked → mobile, focused → distracted), the system should adapt. Currently, the user must do this manually.

### 3. What is its basic unit of intelligence?

The **context**. Not the event, not the intent, not the state. The context is the complete picture of reality at a moment in time. Events feed into context. Intent emerges from context. Policies are evaluated against context. Decisions are made based on context. Everything flows through the world model.

### 4. Which components belong to the core?

- Event Bus (communication)
- Context Engine (world model)
- State Machine (global states)
- Intent System (goal detection)
- Policy Engine (rule evaluation)
- Decision Engine (conflict resolution)
- Plan Executor (action execution + rollback)
- Permission Manager (safety)
- Learning Layer (pattern detection)
- History (decision log)

### 5. What must be plugins?

- All sensors (hardware-specific)
- All actions (tool-specific)
- Policy providers (domain-specific policies)
- Integrations (external tool connections)
- Theme generation (matugen-specific)

### 6. What decisions can BlackNode make autonomously?

- Visual effects (blur, shadows, animations)
- Process priorities
- CPU governor
- Notification suppression
- Screen blank timeout
- Background service management

### 7. What requires authorization?

- Arbitrary command execution
- System service changes
- Network configuration
- Power management that could cause data loss
- Any irreversible change

### 8. How does it learn without becoming spyware?

- Observe only: app names, resource usage, device connections, time patterns
- Never observe: file contents, keystrokes, screen content, network traffic
- Store data locally only, with expiration
- Let user inspect and delete any data
- Propose, never auto-apply learning-based policies
- Require explicit consent for learned automations

### 9. How does it avoid unpredictable behavior?

- Every decision is logged with reasoning
- Every plan has a rollback
- Safety levels limit auto-execution
- Health checks detect inconsistencies
- Recovery engine reverts failed changes
- User can override any decision
- Learning suggestions require approval

### 10. How does it explain every decision?

The Decision Engine produces an `Explanation` object:

```rust
struct Explanation {
    decision_id: Uuid,
    timestamp: DateTime<Utc>,
    reason: String,                    // "gaming mode activated"
    contributing_factors: Vec<String>, // ["GPU load 85%", "fullscreen app detected"]
    policies_applied: Vec<String>,     // ["gaming_performance", "notification_suppress"]
    conflicts_resolved: Vec<String>,   // ["work_mode deferred"]
    safety_checks: Vec<String>,        // ["all actions rated Safe"]
}
```

Accessible via `blacknode ux explain <decision_id>`.

### 11. How does it recover after a mistake?

- Every plan includes rollback actions
- On execution failure: automatic rollback
- Health checks run periodically
- Inconsistencies trigger recovery plans
- User can manually trigger `blacknode ux recover`
- State history allows rolling back to any previous state

### 12. How does it scale from small laptop to powerful desktop?

- Polling frequency adapts to available resources
- Decision complexity scales with available context
- Plugin loading is lazy (only load what's needed)
- Learning aggressiveness scales with available CPU
- On low-resource systems: fewer sensors, simpler policies, faster decisions
- On high-resource systems: more sensors, complex policies, deeper learning

---

## 11. Current State vs. Required State

### What exists now (in `~/.local/ux/`)

| Component | Status | Notes |
|-----------|--------|-------|
| EventBus | Partial | Works, but limited event types |
| StateMachine | Partial | Works, but states are incomplete |
| RuleEngine | Partial | Works, but rules are simplistic |
| History | Partial | Works, but analysis is basic |
| Engine | Partial | Orchestrates, but missing most stages |
| CLI | Partial | Basic commands work |
| Persistence | Minimal | JSON store exists |

### What needs to be built

| Component | Priority | Complexity |
|-----------|----------|------------|
| Context Engine | Critical | High |
| Intent System | Critical | Medium |
| Policy Engine | Critical | Medium |
| Decision Engine | Critical | High |
| Plan system | Critical | High |
| Permission Manager | Critical | Medium |
| Plugin system | Critical | High |
| Recovery Engine | High | Medium |
| Learning Layer | Medium | High |
| Entity model | Medium | Medium |
| Full sensor suite | High | Medium |
| Full action suite | High | Medium |

---

## 12. Implementation Strategy

### Phase 1: Foundation (weeks 1–3)
- Rewrite core data model in Rust
- Implement Event Bus, Context Engine, State Machine
- Build sensor framework
- Basic plugin loading

### Phase 2: Intelligence (weeks 4–6)
- Intent System
- Policy Engine with built-in policies
- Decision Engine with conflict resolution
- Plan system with rollback

### Phase 3: Actions (weeks 7–9)
- Action framework
- Hyprland integration plugin
- Systemd integration plugin
- Power management plugin

### Phase 4: Learning (weeks 10–12)
- Pattern detection
- Suggestion engine
- Privacy controls
- History and explanation

### Phase 5: Polish (weeks 13–16)
- Recovery engine
- Performance optimization
- Documentation
- Testing

---

## 13. What to Delete from Current Code

The current `~/.local/ux/` implementation has several issues:

1. **`suggest()` in engine.py** — String parsing with hardcoded delimiters. Delete entirely.
2. **`confirm_destructive()`** — Returns `True` without logic. Delete.
3. **`_update_service_health()`** — Stores data but never reacts. Redesign as sensor input.
4. **`History.patterns()`** — Counting payloads as strings is not pattern detection. Redesign.
5. **`History.times_between()`** — Niche utility, not core. Move to plugin or delete.
6. **`_MODE_TRIGGERS` mapping** — Fragile string mapping. Replace with proper intent system.
7. **Most of `engine.py`** — The orchestration logic is correct in concept but needs the full pipeline.
8. **`FsStore`** — JSON persistence is fine for MVP but needs proper schema.

### What to keep

1. **EventBus** — Concept is correct, expand event types
2. **StateMachine** — Concept is correct, expand states and transitions
3. **RuleEngine** — Concept is correct, expand to full Policy Engine
4. **Core architecture** — The hexagonal separation is correct
5. **CLI structure** — The command structure is reasonable

---

## 14. Open Questions

1. Should the Context Engine poll or react? (Polling is simpler; reaction is more efficient. Recommendation: react to events, poll for missing data.)
2. Should intents be mutually exclusive? (No. Multiple intents can be active. Conflict resolution handles overlaps.)
3. How deep should the entity model go? (Start shallow: apps, devices, services. Expand as needed.)
4. Should plugins be sandboxed? (Yes. Plugin crashes should not crash the core. Use process isolation or WASM.)
5. Should the learning layer use ML? (No. Rule-based pattern detection is sufficient and more explainable. ML is overkill for local patterns.)
6. What is the minimum viable product? (Context Engine + Policy Engine + Decision Engine + Hyprland integration. This alone enables context-aware configuration.)
