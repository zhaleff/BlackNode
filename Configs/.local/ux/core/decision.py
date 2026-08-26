from __future__ import annotations
import time
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any
from uuid import uuid4

from .context import WorldModel
from .intent import Intent
from .policy import PolicyMatch, Policy, Action


class ConflictSeverity(Enum):
    INCOMPATIBLE = auto()
    DEGRADING = auto()
    COSMETIC = auto()


@dataclass
class Conflict:
    policies: tuple[str, str]
    field: str
    severity: ConflictSeverity


class Resolution(Enum):
    SINGLE = auto()
    PRIORITY_BASED = auto()
    MERGED = auto()
    COMPROMISE = auto()
    DEFERRED = auto()
    REJECTED = auto()


@dataclass
class Explanation:
    decision_id: str
    timestamp: float
    reason: str
    contributing_factors: list[str] = field(default_factory=list)
    policies_applied: list[str] = field(default_factory=list)
    conflicts_resolved: list[str] = field(default_factory=list)
    safety_checks: list[str] = field(default_factory=list)


@dataclass
class Decision:
    id: str = field(default_factory=lambda: uuid4().hex[:12])
    timestamp: float = field(default_factory=time.time)
    context_snapshot: dict[str, Any] = field(default_factory=dict)
    active_intents: list[str] = field(default_factory=list)
    matched_policies: list[str] = field(default_factory=list)
    conflicts: list[Conflict] = field(default_factory=list)
    resolution: Resolution = Resolution.SINGLE
    actions: list[Action] = field(default_factory=list)
    explanation: Explanation | None = None


class DecisionEngine:
    def __init__(self) -> None:
        self.history: list[Decision] = []
        self.max_history = 100

    def decide(
        self,
        world: WorldModel,
        intents: list[Intent],
        matches: list[PolicyMatch],
    ) -> Decision:
        if not matches:
            return Decision(
                context_snapshot=world.snapshot(),
                active_intents=[i.name for i in intents],
                resolution=Resolution.REJECTED,
                explanation=Explanation(
                    decision_id="",
                    timestamp=time.time(),
                    reason="no matching policies",
                ),
            )

        conflicts = self._find_conflicts(matches)
        resolution = self._resolve_conflicts(matches, conflicts)
        actions = self._collect_actions(matches, conflicts, resolution)

        decision = Decision(
            context_snapshot=world.snapshot(),
            active_intents=[i.name for i in intents],
            matched_policies=[m.policy.name for m in matches],
            conflicts=conflicts,
            resolution=resolution,
            actions=actions,
        )

        decision.explanation = self._build_explanation(
            decision, world, intents, matches, conflicts, resolution
        )

        self.history.append(decision)
        if len(self.history) > self.max_history:
            self.history = self.history[-self.max_history:]

        return decision

    def _find_conflicts(self, matches: list[PolicyMatch]) -> list[Conflict]:
        conflicts: list[Conflict] = []
        for i, a in enumerate(matches):
            for b in matches[i + 1:]:
                conflict = self._check_pair(a, b)
                if conflict:
                    conflicts.append(conflict)
        return conflicts

    def _check_pair(self, a: PolicyMatch, b: PolicyMatch) -> Conflict | None:
        a_resources = self._extract_resources(a.policy)
        b_resources = self._extract_resources(b.policy)

        shared = set(a_resources.keys()) & set(b_resources.keys())
        for resource in shared:
            a_val = a_resources[resource]
            b_val = b_resources[resource]
            if a_val != b_val:
                severity = self._classify_conflict_severity(
                    a.policy, b.policy, resource, a_val, b_val
                )
                return Conflict(
                    policies=(a.policy.name, b.policy.name),
                    field=resource,
                    severity=severity,
                )
        return None

    def _extract_resources(self, policy: Policy) -> dict[str, str]:
        resources: dict[str, str] = {}
        for action in policy.actions:
            key = action.kind
            if action.kind == "set_governor":
                key = "cpu_governor"
            elif action.kind == "disable_effects":
                key = "effects"
            elif action.kind == "set_process_priority":
                key = f"priority_{action.params.get('target', '')}"
            elif action.kind == "suppress_notifications":
                key = "notifications"
            elif action.kind == "reduce_refresh_rate":
                key = "refresh_rate"
            elif action.kind == "limit_cpu_percent":
                key = "cpu_limit"
            resources[key] = str(action.params)
        return resources

    def _classify_conflict_severity(
        self,
        a: Policy,
        b: Policy,
        resource: str,
        a_val: str,
        b_val: str,
    ) -> ConflictSeverity:
        opposite_effects = (
            ("performance" in a_val and "powersave" in b_val)
            or ("powersave" in a_val and "performance" in b_val)
            or ("disable" in a_val and "enable" in b_val)
            or ("enable" in a_val and "disable" in b_val)
        )
        if opposite_effects:
            return ConflictSeverity.INCOMPATIBLE
        if abs(a.priority - b.priority) > 30:
            return ConflictSeverity.COSMETIC
        return ConflictSeverity.DEGRADING

    def _resolve_conflicts(
        self,
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
    ) -> Resolution:
        if not conflicts:
            if len(matches) == 1:
                return Resolution.SINGLE
            return Resolution.MERGED

        incompatible = [
            c for c in conflicts if c.severity == ConflictSeverity.INCOMPATIBLE
        ]
        if incompatible:
            return Resolution.PRIORITY_BASED

        return Resolution.MERGED

    def _collect_actions(
        self,
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
        resolution: Resolution,
    ) -> list[Action]:
        if resolution == Resolution.PRIORITY_BASED:
            return self._resolve_priority_based(matches, conflicts)
        elif resolution == Resolution.MERGED:
            return self._resolve_merged(matches, conflicts)
        elif resolution == Resolution.COMPROMISE:
            return self._resolve_compromise(matches, conflicts)
        else:
            return [a for m in matches for a in m.policy.actions]

    def _resolve_priority_based(
        self,
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
    ) -> list[Action]:
        losers: set[str] = set()
        for conflict in conflicts:
            name_a, name_b = conflict.policies
            match_a = next((m for m in matches if m.policy.name == name_a), None)
            match_b = next((m for m in matches if m.policy.name == name_b), None)
            if match_a and match_b:
                if match_a.policy.priority >= match_b.policy.priority:
                    losers.add(name_b)
                else:
                    losers.add(name_a)

        actions: list[Action] = []
        for m in matches:
            if m.policy.name not in losers:
                actions.extend(m.policy.actions)
        return actions

    def _resolve_merged(
        self,
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
    ) -> list[Action]:
        seen_resources: dict[str, str] = {}
        actions: list[Action] = []

        for m in matches:
            for action in m.policy.actions:
                resource = action.kind
                if resource not in seen_resources:
                    seen_resources[resource] = m.policy.name
                    actions.append(action)
        return actions

    def _resolve_compromise(
        self,
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
    ) -> list[Action]:
        return self._resolve_merged(matches, conflicts)

    def _build_explanation(
        self,
        decision: Decision,
        world: WorldModel,
        intents: list[Intent],
        matches: list[PolicyMatch],
        conflicts: list[Conflict],
        resolution: Resolution,
    ) -> Explanation:
        factors: list[str] = []

        if world.gaming_detected:
            factors.append("gaming detected")
        if world.battery_percent is not None and world.battery_percent < 30:
            factors.append(f"battery at {world.battery_percent:.0f}%")
        if world.thermal_state.value >= 2:
            factors.append(f"thermal state: {world.thermal_state.name}")
        if world.cpu.used_percent > 70:
            factors.append(f"CPU at {world.cpu.used_percent:.0f}%")
        if world.focused_app:
            factors.append(f"focused: {world.focused_app.name}")
        for intent in intents:
            factors.append(f"intent: {intent.name} (priority {intent.priority})")

        conflict_texts = [
            f"{c.policies[0]} vs {c.policies[1]} on {c.field} ({c.severity.name})"
            for c in conflicts
        ]

        safety_texts = []
        for m in matches:
            safety_texts.append(f"{m.policy.name}: {m.policy.safety.name}")

        reason = f"{resolution.name} resolution across {len(matches)} policies"
        if conflicts:
            reason += f", {len(conflicts)} conflicts resolved"

        return Explanation(
            decision_id=decision.id,
            timestamp=decision.timestamp,
            reason=reason,
            contributing_factors=factors,
            policies_applied=[m.policy.name for m in matches],
            conflicts_resolved=conflict_texts,
            safety_checks=safety_texts,
        )

    def explain(self, decision_id: str) -> Explanation | None:
        for d in self.history:
            if d.id == decision_id:
                return d.explanation
        return None

    def recent(self, n: int = 10) -> list[Decision]:
        return self.history[-n:]
