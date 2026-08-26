from __future__ import annotations
import time
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any

from .context import WorldModel, AppClass, SessionMode, PressureLevel, PowerState


class IntentSource(Enum):
    EXPLICIT = auto()
    INFERRED = auto()
    SCHEDULED = auto()


@dataclass
class Intent:
    name: str
    priority: int = 100
    constraints: list[str] = field(default_factory=list)
    source: IntentSource = IntentSource.INFERRED
    confidence: float = 0.0
    activated_at: float = field(default_factory=time.time)
    expires_in: float | None = None  # seconds, None = no expiry

    @property
    def is_active(self) -> bool:
        if self.expires_in is None:
            return True
        return (time.time() - self.activated_at) < self.expires_in

    @property
    def is_explicit(self) -> bool:
        return self.source == IntentSource.EXPLICIT


@dataclass
class IntentRule:
    name: str
    priority: int = 100
    constraints: list[str] = field(default_factory=list)
    source: IntentSource = IntentSource.INFERRED
    confidence_threshold: float = 0.7
    expires_in: float | None = None


class IntentSystem:
    def __init__(self) -> None:
        self.active: dict[str, Intent] = {}
        self._rules: list[IntentRule] = self._default_rules()

    def _default_rules(self) -> list[IntentRule]:
        return [
            IntentRule(
                name="gaming",
                priority=200,
                constraints=["max_performance"],
                confidence_threshold=0.7,
            ),
            IntentRule(
                name="work",
                priority=180,
                constraints=["min_productivity"],
                confidence_threshold=0.6,
            ),
            IntentRule(
                name="focus",
                priority=150,
                constraints=["no_interruptions"],
                confidence_threshold=0.7,
            ),
            IntentRule(
                name="presentation",
                priority=170,
                constraints=["no_popups"],
                confidence_threshold=0.8,
            ),
            IntentRule(
                name="battery_saver",
                priority=190,
                constraints=["min_battery"],
                confidence_threshold=0.8,
            ),
            IntentRule(
                name="privacy",
                priority=160,
                constraints=["max_privacy"],
                confidence_threshold=0.9,
            ),
            IntentRule(
                name="maintenance",
                priority=100,
                constraints=["safe_operations"],
                confidence_threshold=0.6,
            ),
        ]

    def evaluate(self, world: WorldModel) -> list[Intent]:
        inferred: list[Intent] = []

        for rule in self._rules:
            if rule.name in self.active:
                continue
            confidence = self._compute_confidence(rule, world)
            if confidence >= rule.confidence_threshold:
                inferred.append(Intent(
                    name=rule.name,
                    priority=rule.priority,
                    constraints=rule.constraints,
                    source=IntentSource.INFERRED,
                    confidence=confidence,
                    expires_in=rule.expires_in,
                ))

        for intent in inferred:
            self.active[intent.name] = intent

        expired = [n for n, i in self.active.items() if not i.is_active]
        for n in expired:
            del self.active[n]

        return list(self.active.values())

    def _compute_confidence(self, rule: IntentRule, world: WorldModel) -> float:
        if rule.name == "gaming":
            return self._gaming_confidence(world)
        elif rule.name == "work":
            return self._work_confidence(world)
        elif rule.name == "focus":
            return self._focus_confidence(world)
        elif rule.name == "presentation":
            return self._presentation_confidence(world)
        elif rule.name == "battery_saver":
            return self._battery_saver_confidence(world)
        elif rule.name == "privacy":
            return self._privacy_confidence(world)
        elif rule.name == "maintenance":
            return self._maintenance_confidence(world)
        return 0.0

    def _gaming_confidence(self, w: WorldModel) -> float:
        score = 0.0
        if w.gaming_detected:
            score += 0.5
        if w.fullscreen_active:
            score += 0.2
        if w.gpu.used_percent > 70:
            score += 0.2
        if w.focused_app and w.focused_app.app_class == AppClass.GAME:
            score += 0.3
        has_game = any(a.app_class == AppClass.GAME for a in w.applications)
        if has_game:
            score += 0.2
        return min(score, 1.0)

    def _work_confidence(self, w: WorldModel) -> float:
        score = 0.0
        work_apps = {AppClass.IDE, AppClass.EDITOR, AppClass.BROWSER}
        if w.focused_app and w.focused_app.app_class in work_apps:
            score += 0.4
        hour = time.localtime().tm_hour
        if 9 <= hour <= 17:
            score += 0.2
        weekday = time.localtime().tm_wday
        if weekday < 5:
            score += 0.1
        if not w.idle:
            score += 0.1
        return min(score, 1.0)

    def _focus_confidence(self, w: WorldModel) -> float:
        score = 0.0
        if w.idle_duration > 900:
            score += 0.3
        if w.focused_app and w.focused_app.app_class in {AppClass.IDE, AppClass.EDITOR}:
            score += 0.3
        if not w.fullscreen_active:
            score += 0.1
        return min(score, 1.0)

    def _presentation_confidence(self, w: WorldModel) -> float:
        score = 0.0
        if w.session_mode == SessionMode.PRESENTATION:
            score += 0.5
        if w.display_count > 1:
            score += 0.2
        if w.fullscreen_active:
            score += 0.2
        return min(score, 1.0)

    def _battery_saver_confidence(self, w: WorldModel) -> float:
        score = 0.0
        if w.power_state == PowerState.BATTERY:
            if w.battery_percent is not None:
                if w.battery_percent < 20:
                    score += 0.7
                elif w.battery_percent < 30:
                    score += 0.5
                elif w.battery_percent < 50:
                    score += 0.2
        return min(score, 1.0)

    def _privacy_confidence(self, w: WorldModel) -> float:
        score = 0.0
        if w.network_metered:
            score += 0.3
        if not w.vpn_active and w.network_connected:
            score += 0.2
        return min(score, 1.0)

    def _maintenance_confidence(self, w: WorldModel) -> float:
        score = 0.0
        hour = time.localtime().tm_hour
        if 2 <= hour <= 5:
            score += 0.4
        if w.idle_duration > 1800:
            score += 0.3
        if w.cpu.used_percent < 20:
            score += 0.1
        return min(score, 1.0)

    def activate(self, name: str, priority: int = 200, constraints: list[str] | None = None) -> Intent:
        intent = Intent(
            name=name,
            priority=priority,
            constraints=constraints or [],
            source=IntentSource.EXPLICIT,
            confidence=1.0,
        )
        self.active[name] = intent
        return intent

    def deactivate(self, name: str) -> bool:
        if name in self.active:
            del self.active[name]
            return True
        return False

    def has(self, name: str) -> bool:
        return name in self.active and self.active[name].is_active

    def by_priority(self) -> list[Intent]:
        return sorted(self.active.values(), key=lambda i: i.priority, reverse=True)
