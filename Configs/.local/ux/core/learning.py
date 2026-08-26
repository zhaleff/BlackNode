from __future__ import annotations
import time
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any
from uuid import uuid4

from .context import WorldModel


class PatternKind(Enum):
    TIME_BASED = auto()
    SEQUENCE_BASED = auto()
    RESOURCE_BASED = auto()
    CONTEXT_BASED = auto()


@dataclass
class Pattern:
    id: str = field(default_factory=lambda: uuid4().hex[:8])
    name: str = ""
    kind: PatternKind = PatternKind.TIME_BASED
    description: str = ""
    frequency: float = 0.0
    confidence: float = 0.0
    occurrences: int = 0
    discovered_at: float = field(default_factory=time.time)
    last_seen: float = field(default_factory=time.time)
    evidence: list[str] = field(default_factory=list)


@dataclass
class Suggestion:
    id: str = field(default_factory=lambda: uuid4().hex[:8])
    description: str = ""
    proposed_actions: list[dict[str, Any]] = field(default_factory=list)
    confidence: float = 0.0
    evidence: list[str] = field(default_factory=list)
    accepted: bool | None = None
    created_at: float = field(default_factory=time.time)
    pattern_id: str = ""


@dataclass
class LearningConfig:
    enabled: bool = True
    min_occurrences: int = 3
    confidence_threshold: float = 0.6
    retention_days: int = 30
    max_patterns: int = 100
    max_suggestions: int = 20


class LearningLayer:
    def __init__(self, config: LearningConfig | None = None) -> None:
        self.config = config or LearningConfig()
        self.patterns: list[Pattern] = []
        self.suggestions: list[Suggestion] = []
        self._observations: list[dict[str, Any]] = []
        self._max_observations = 500

    def observe(self, world: WorldModel) -> None:
        if not self.config.enabled:
            return

        obs = {
            "timestamp": time.time(),
            "hour": time.localtime().tm_hour,
            "weekday": time.localtime().tm_wday,
            "focused_app": world.focused_app.name if world.focused_app else None,
            "app_class": world.focused_app.app_class.name if world.focused_app else None,
            "cpu": world.cpu.used_percent,
            "memory": world.memory.used_percent,
            "gpu": world.gpu.used_percent,
            "battery": world.battery_percent,
            "session_mode": world.session_mode.name,
            "display_count": world.display_count,
            "idle": world.idle,
            "gaming": world.gaming_detected,
        }
        self._observations.append(obs)
        if len(self._observations) > self._max_observations:
            self._observations = self._observations[-self._max_observations:]

    def analyze(self) -> list[Pattern]:
        if not self.config.enabled:
            return []

        new_patterns: list[Pattern] = []

        app_time = self._detect_app_time_patterns()
        new_patterns.extend(app_time)

        sequences = self._detect_sequences()
        new_patterns.extend(sequences)

        resources = self._detect_resource_patterns()
        new_patterns.extend(resources)

        for pattern in new_patterns:
            if pattern.confidence >= self.config.confidence_threshold:
                if not self._pattern_exists(pattern):
                    self.patterns.append(pattern)

        self._expire_old_patterns()
        return self.patterns

    def _detect_app_time_patterns(self) -> list[Pattern]:
        patterns: list[Pattern] = []
        app_hours: dict[str, dict[int, int]] = {}

        for obs in self._observations:
            app = obs.get("focused_app")
            hour = obs.get("hour", 0)
            if app:
                app_hours.setdefault(app, {})
                app_hours[app][hour] = app_hours[app].get(hour, 0) + 1

        for app, hours in app_hours.items():
            total = sum(hours.values())
            if total < self.config.min_occurrences:
                continue
            peak_hour = max(hours, key=hours.get)
            peak_count = hours[peak_hour]
            confidence = peak_count / total

            if confidence >= self.config.confidence_threshold:
                patterns.append(Pattern(
                    name=f"{app}_at_{peak_hour:02d}",
                    kind=PatternKind.TIME_BASED,
                    description=f"user uses {app} around {peak_hour}:00",
                    frequency=total / max(len(self._observations), 1),
                    confidence=confidence,
                    occurrences=total,
                    evidence=[f"{app} used {peak_count} times at {peak_hour}:00"],
                ))

        return patterns

    def _detect_sequences(self) -> list[Pattern]:
        patterns: list[Pattern] = []
        transitions: dict[str, dict[str, int]] = {}

        apps = [obs.get("focused_app") for obs in self._observations]
        apps = [a for a in apps if a]

        for i in range(len(apps) - 1):
            a, b = apps[i], apps[i + 1]
            if a != b:
                transitions.setdefault(a, {})
                transitions[a][b] = transitions[a].get(b, 0) + 1

        for source, targets in transitions.items():
            for target, count in targets.items():
                if count < self.config.min_occurrences:
                    continue
                total = sum(targets.values())
                confidence = count / total
                if confidence >= self.config.confidence_threshold:
                    patterns.append(Pattern(
                        name=f"{source}_then_{target}",
                        kind=PatternKind.SEQUENCE_BASED,
                        description=f"after {source}, user opens {target}",
                        frequency=count / max(len(self._observations), 1),
                        confidence=confidence,
                        occurrences=count,
                        evidence=[f"{source} → {target} happened {count} times"],
                    ))

        return patterns

    def _detect_resource_patterns(self) -> list[Pattern]:
        patterns: list[Pattern] = []
        app_resources: dict[str, list[float]] = {}

        for obs in self._observations:
            app = obs.get("focused_app")
            cpu = obs.get("cpu", 0)
            if app:
                app_resources.setdefault(app, [])
                app_resources[app].append(cpu)

        for app, cpu_values in app_resources.items():
            if len(cpu_values) < self.config.min_occurrences:
                continue
            avg = sum(cpu_values) / len(cpu_values)
            if avg > 60:
                patterns.append(Pattern(
                    name=f"{app}_high_cpu",
                    kind=PatternKind.RESOURCE_BASED,
                    description=f"{app} causes high CPU usage ({avg:.0f}%)",
                    frequency=len(cpu_values) / max(len(self._observations), 1),
                    confidence=min(avg / 100, 1.0),
                    occurrences=len(cpu_values),
                    evidence=[f"{app} avg CPU: {avg:.0f}%"],
                ))

        return patterns

    def _pattern_exists(self, new: Pattern) -> bool:
        for existing in self.patterns:
            if existing.name == new.name and existing.kind == new.kind:
                existing.occurrences += new.occurrences
                existing.frequency = new.frequency
                existing.confidence = max(existing.confidence, new.confidence)
                existing.last_seen = time.time()
                return True
        return False

    def _expire_old_patterns(self) -> None:
        cutoff = time.time() - (self.config.retention_days * 86400)
        self.patterns = [p for p in self.patterns if p.discovered_at > cutoff or p.last_seen > cutoff]

    def generate_suggestions(self) -> list[Suggestion]:
        suggestions: list[Suggestion] = []
        for pattern in self.patterns:
            if pattern.confidence < self.config.confidence_threshold:
                continue
            if pattern.occurrences < self.config.min_occurrences:
                continue
            if self._has_suggestion_for(pattern.id):
                continue

            suggestion = self._pattern_to_suggestion(pattern)
            if suggestion:
                suggestions.append(suggestion)
                self.suggestions.append(suggestion)

        return suggestions

    def _pattern_to_suggestion(self, pattern: Pattern) -> Suggestion | None:
        if pattern.kind == PatternKind.TIME_BASED:
            return Suggestion(
                description=f"I noticed you frequently use {pattern.description.split('uses ')[1] if 'uses ' in pattern.description else pattern.name}. Would you like me to optimize for this?",
                confidence=pattern.confidence,
                evidence=pattern.evidence,
                pattern_id=pattern.id,
            )
        elif pattern.kind == PatternKind.SEQUENCE_BASED:
            return Suggestion(
                description=f"I noticed a pattern: {pattern.description}. Would you like me to automate this transition?",
                confidence=pattern.confidence,
                evidence=pattern.evidence,
                pattern_id=pattern.id,
            )
        elif pattern.kind == PatternKind.RESOURCE_BASED:
            return Suggestion(
                description=f"I noticed {pattern.description}. Would you like me to optimize resources when this app is active?",
                confidence=pattern.confidence,
                evidence=pattern.evidence,
                pattern_id=pattern.id,
            )
        return None

    def _has_suggestion_for(self, pattern_id: str) -> bool:
        return any(s.pattern_id == pattern_id for s in self.suggestions)

    def accept_suggestion(self, suggestion_id: str) -> bool:
        for s in self.suggestions:
            if s.id == suggestion_id:
                s.accepted = True
                return True
        return False

    def reject_suggestion(self, suggestion_id: str) -> bool:
        for s in self.suggestions:
            if s.id == suggestion_id:
                s.accepted = False
                return True
        return False

    def pending_suggestions(self) -> list[Suggestion]:
        return [s for s in self.suggestions if s.accepted is None]

    def summary(self) -> dict[str, Any]:
        return {
            "patterns": len(self.patterns),
            "suggestions": len(self.suggestions),
            "pending": len(self.pending_suggestions()),
            "accepted": sum(1 for s in self.suggestions if s.accepted is True),
            "rejected": sum(1 for s in self.suggestions if s.accepted is False),
            "observations": len(self._observations),
        }
