from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Callable

from .context import WorldModel, PressureLevel, ThermalState, SessionMode, AppClass
from .intent import Intent


class SafetyLevel(Enum):
    SAFE = auto()
    MODERATE = auto()
    SENSITIVE = auto()
    CRITICAL = auto()


@dataclass
class Action:
    kind: str
    params: dict[str, Any] = field(default_factory=dict)
    description: str = ""

    def __hash__(self) -> int:
        return hash((self.kind, tuple(sorted(self.params.items()))))


@dataclass
class Condition:
    check: Callable[[WorldModel, list[Intent]], bool]
    description: str = ""

    def evaluate(self, world: WorldModel, intents: list[Intent]) -> bool:
        return self.check(world, intents)


@dataclass
class Policy:
    name: str
    conditions: list[Condition]
    actions: list[Action]
    priority: int = 100
    safety: SafetyLevel = SafetyLevel.SAFE
    enabled: bool = True
    description: str = ""

    def matches(self, world: WorldModel, intents: list[Intent]) -> PolicyMatch | None:
        if not self.enabled:
            return None
        met = sum(1 for c in self.conditions if c.evaluate(world, intents))
        total = len(self.conditions)
        if met == 0:
            return None
        relevance = met / total if total > 0 else 0.0
        return PolicyMatch(
            policy=self,
            relevance=relevance,
            conditions_met=met,
            conditions_total=total,
        )


@dataclass
class PolicyMatch:
    policy: Policy
    relevance: float
    conditions_met: int
    conditions_total: int


def intent_active(name: str) -> Condition:
    return Condition(
        check=lambda w, intents: any(i.name == name for i in intents),
        description=f"intent '{name}' active",
    )


def battery_below(percent: float) -> Condition:
    return Condition(
        check=lambda w, intents: (
            w.battery_percent is not None and w.battery_percent < percent
        ),
        description=f"battery < {percent}%",
    )


def battery_above(percent: float) -> Condition:
    return Condition(
        check=lambda w, intents: (
            w.battery_percent is not None and w.battery_percent > percent
        ),
        description=f"battery > {percent}%",
    )


def cpu_load_above(threshold: float) -> Condition:
    return Condition(
        check=lambda w, intents: w.cpu.used_percent > threshold,
        description=f"CPU > {threshold}%",
    )


def memory_pressure(min_level: PressureLevel) -> Condition:
    levels = list(PressureLevel)
    min_idx = levels.index(min_level)
    return Condition(
        check=lambda w, intents: levels.index(w.memory.pressure) >= min_idx,
        description=f"memory pressure >= {min_level.name}",
    )


def thermal_at_least(state: ThermalState) -> Condition:
    levels = list(ThermalState)
    min_idx = levels.index(state)
    return Condition(
        check=lambda w, intents: levels.index(w.thermal_state) >= min_idx,
        description=f"thermal >= {state.name}",
    )


def time_between(start_hour: int, end_hour: int) -> Condition:
    import time as _time
    return Condition(
        check=lambda w, intents: start_hour <= _time.localtime().tm_hour <= end_hour,
        description=f"time between {start_hour}:00 and {end_hour}:00",
    )


def weekday() -> Condition:
    import time as _time
    return Condition(
        check=lambda w, intents: _time.localtime().tm_wday < 5,
        description="weekday",
    )


def app_class_focused(app_class: AppClass) -> Condition:
    return Condition(
        check=lambda w, intents: (
            w.focused_app is not None and w.focused_app.app_class == app_class
        ),
        description=f"{app_class.name} focused",
    )


def display_count_at_least(n: int) -> Condition:
    return Condition(
        check=lambda w, intents: w.display_count >= n,
        description=f"displays >= {n}",
    )


def session_mode_is(mode: SessionMode) -> Condition:
    return Condition(
        check=lambda w, intents: w.session_mode == mode,
        description=f"session = {mode.name}",
    )


def network_metered() -> Condition:
    return Condition(
        check=lambda w, intents: w.network_metered,
        description="network metered",
    )


def idle_above(seconds: float) -> Condition:
    return Condition(
        check=lambda w, intents: w.idle_duration > seconds,
        description=f"idle > {seconds}s",
    )


def gaming_active() -> Condition:
    return Condition(
        check=lambda w, intents: w.gaming_detected,
        description="gaming detected",
    )


def not_state(state_name: str) -> Condition:
    from .state import UXState
    target = UXState[state_name]
    return Condition(
        check=lambda w, intents, t=target: w.get("ux_state") != t.name,
        description=f"state != {state_name}",
    )


def _builtin_policies() -> list[Policy]:
    return [
        Policy(
            name="gaming_performance",
            conditions=[intent_active("gaming")],
            actions=[
                Action("set_process_priority", {"target": "compositor", "priority": -10}, "raise compositor priority"),
                Action("set_process_priority", {"target": "game", "priority": -5}, "raise game priority"),
                Action("disable_effects", {"effects": ["blur", "shadows"]}, "disable visual effects"),
                Action("set_governor", {"mode": "performance"}, "set CPU governor to performance"),
            ],
            priority=200,
            safety=SafetyLevel.SAFE,
            description="optimize for gaming",
        ),
        Policy(
            name="battery_saver_moderate",
            conditions=[battery_below(30), not_state("GAMING")],
            actions=[
                Action("set_governor", {"mode": "powersave"}, "set CPU to powersave"),
                Action("disable_effects", {"effects": ["blur"]}, "disable blur"),
                Action("reduce_refresh_rate", {"rate": 60}, "reduce refresh rate"),
            ],
            priority=190,
            safety=SafetyLevel.SAFE,
            description="moderate battery saving",
        ),
        Policy(
            name="battery_critical",
            conditions=[battery_below(15), not_state("GAMING")],
            actions=[
                Action("set_governor", {"mode": "powersave"}, "set CPU to powersave"),
                Action("limit_cpu_percent", {"limit": 50.0}, "limit CPU to 50%"),
                Action("disable_effects", {"effects": ["blur", "shadows", "animations"]}, "disable all effects"),
                Action("reduce_refresh_rate", {"rate": 60}, "reduce refresh rate"),
                Action("suspend_service", {"service": "bluetooth"}, "suspend bluetooth"),
            ],
            priority=210,
            safety=SafetyLevel.MODERATE,
            description="critical battery saving",
        ),
        Policy(
            name="work_productivity",
            conditions=[
                intent_active("work"),
                app_class_focused(AppClass.IDE),
            ],
            actions=[
                Action("suppress_notifications", {"level": "non-critical"}, "suppress non-critical notifications"),
                Action("set_process_priority", {"target": "focused", "priority": -3}, "boost focused app"),
            ],
            priority=180,
            safety=SafetyLevel.SAFE,
            description="optimize for focused work",
        ),
        Policy(
            name="presentation_mode",
            conditions=[intent_active("presentation")],
            actions=[
                Action("suppress_notifications", {"level": "all"}, "suppress all notifications"),
                Action("disable_effects", {"effects": ["animations"]}, "disable animations"),
                Action("set_process_priority", {"target": "compositor", "priority": -5}, "boost compositor"),
            ],
            priority=170,
            safety=SafetyLevel.SAFE,
            description="optimize for presentations",
        ),
        Policy(
            name="dock_mode",
            conditions=[session_mode_is(SessionMode.DOCKED)],
            actions=[
                Action("set_display_config", {"mode": "extended"}, "extend displays"),
                Action("set_notification_volume", {"volume": 0.5}, "set notification volume"),
            ],
            priority=160,
            safety=SafetyLevel.SAFE,
            description="optimize for docked station",
        ),
        Policy(
            name="thermal_throttle",
            conditions=[thermal_at_least(ThermalState.HOT)],
            actions=[
                Action("set_governor", {"mode": "powersave"}, "throttle CPU"),
                Action("disable_effects", {"effects": ["blur"]}, "reduce GPU load"),
            ],
            priority=220,
            safety=SafetyLevel.SAFE,
            description="thermal protection",
        ),
        Policy(
            name="privacy_public_network",
            conditions=[intent_active("privacy"), network_metered()],
            actions=[
                Action("suppress_notifications", {"level": "all"}, "suppress notifications on public network"),
            ],
            priority=160,
            safety=SafetyLevel.SAFE,
            description="privacy on public networks",
        ),
        Policy(
            name="maintenance_idle",
            conditions=[intent_active("maintenance"), idle_above(1800)],
            actions=[
                Action("run_maintenance", {"tasks": ["cleanup", "optimize"]}, "run maintenance tasks"),
            ],
            priority=100,
            safety=SafetyLevel.MODERATE,
            description="maintenance during idle",
        ),
    ]


class PolicyEngine:
    def __init__(self) -> None:
        self.policies: list[Policy] = _builtin_policies()
        self._overrides: dict[str, bool] = {}

    def evaluate(self, world: WorldModel, intents: list[Intent]) -> list[PolicyMatch]:
        matches: list[PolicyMatch] = []
        for policy in self.policies:
            if policy.name in self._overrides and not self._overrides[policy.name]:
                continue
            match = policy.matches(world, intents)
            if match:
                matches.append(match)
        matches.sort(key=lambda m: (m.policy.priority, m.relevance), reverse=True)
        return matches

    def enable(self, name: str) -> None:
        self._overrides[name] = True

    def disable(self, name: str) -> None:
        self._overrides[name] = False

    def add(self, policy: Policy) -> None:
        self.policies.append(policy)
        self.policies.sort(key=lambda p: p.priority, reverse=True)

    def remove(self, name: str) -> bool:
        before = len(self.policies)
        self.policies = [p for p in self.policies if p.name != name]
        return len(self.policies) < before

    def get(self, name: str) -> Policy | None:
        for p in self.policies:
            if p.name == name:
                return p
        return None
