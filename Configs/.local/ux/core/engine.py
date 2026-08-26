from __future__ import annotations
import time
from dataclasses import dataclass, field
from typing import Any, Callable

from .events import Event, EventBus, EventKind
from .state import UXState, StateMachine
from .context import WorldModel
from .intent import Intent, IntentSystem
from .policy import Policy, PolicyEngine, Action
from .decision import Decision, DecisionEngine, Explanation
from .plan import Plan, PlanBuilder, PlanExecutor, PlanStatus
from .permission import PermissionManager, PolicyDecision
from .learning import LearningLayer, LearningConfig, Suggestion


class UXEngine:
    def __init__(self, *, debug: bool = False) -> None:
        self.bus = EventBus()
        self.state = StateMachine()
        self.context = WorldModel()
        self.intents = IntentSystem()
        self.policies = PolicyEngine()
        self.decisions = DecisionEngine()
        self.executor = PlanExecutor()
        self.permissions = PermissionManager()
        self.learning = LearningLayer()
        self.debug = debug
        self._listeners: list[Callable] = []
        self._store: dict[str, Any] = {}
        self._wire_bus()
        self._register_executors()

    def _wire_bus(self) -> None:
        self.bus.on_all(self._on_event)

    def _on_event(self, event: Event) -> None:
        self.context.update_from_event(event)
        self.learning.observe(self.context)
        self._run_pipeline()

    def _run_pipeline(self) -> None:
        intents = self.intents.evaluate(self.context)
        matches = self.policies.evaluate(self.context, intents)
        decision = self.decisions.decide(self.context, intents, matches)

        if decision.actions:
            plan = PlanBuilder.from_decision(decision)
            allowed, need_ask = self.permissions.check_plan(
                [m.policy for m in matches]
            )

            if allowed == PolicyDecision.DENY:
                return

            if allowed == PolicyDecision.ASK:
                self._notify_pending(plan, need_ask)
                return

            self.executor.execute(plan)
            self._notify_listeners(decision, plan)

    def _notify_pending(self, plan: Plan, policies: list[Policy]) -> None:
        for listener in self._listeners:
            listener({
                "type": "permission_needed",
                "plan_id": plan.id,
                "policies": [p.name for p in policies],
                "actions": [a.action.description or a.action.kind for a in plan.actions],
            })

    def _notify_listeners(self, decision: Decision, plan: Plan) -> None:
        for listener in self._listeners:
            listener({
                "type": "decision",
                "decision_id": decision.id,
                "plan_id": plan.id,
                "resolution": decision.resolution.name,
                "actions": len(plan.actions),
                "status": plan.status.name,
            })

    def _register_executors(self) -> None:
        self.executor.register_executor("default", _DefaultExecutor())

    def on_update(self, fn: Callable) -> None:
        self._listeners.append(fn)

    def emit(self, event: Event) -> None:
        self.bus.emit(event)

    def boot(self) -> None:
        self.state.set_guard("is_first_boot", lambda: self._store.get("onboarding.done") is None)
        self.state.set_guard("not_first_boot", lambda: self._store.get("onboarding.done") is not None)
        self.state.fire("boot")
        self.bus.emit(Event(kind=EventKind.BOOT))

    def switch_theme(self, name: str) -> None:
        old = self._store.get("theme", "")
        self._store["theme"] = name
        self.bus.emit(Event(
            kind=EventKind.THEME_CHANGED,
            payload={"from": old, "to": name},
        ))

    def switch_profile(self, name: str) -> None:
        old = self._store.get("profile", "")
        self._store["profile"] = name
        self.bus.emit(Event(
            kind=EventKind.PROFILE_SWITCHED,
            payload={"from": old, "to": name},
        ))

    def enter_mode(self, mode: str) -> None:
        trigger = f"{mode}_start"
        if self.state.can(trigger):
            self.state.fire(trigger)
            self.bus.emit(Event(
                kind=EventKind.MODE_REQUESTED,
                payload={"mode": mode, "action": "enter"},
            ))

    def exit_mode(self, mode: str) -> None:
        trigger = f"{mode}_end"
        if self.state.can(trigger):
            self.state.fire(trigger)
            self.bus.emit(Event(
                kind=EventKind.MODE_REQUESTED,
                payload={"mode": mode, "action": "exit"},
            ))

    def request_intent(self, name: str, priority: int = 200) -> Intent:
        return self.intents.activate(name, priority)

    def cancel_intent(self, name: str) -> bool:
        return self.intents.deactivate(name)

    def approve_plan(self, plan_id: str) -> bool:
        plan = self.executor.status(plan_id)
        if plan is None:
            return False
        for action in plan.actions:
            pass
        self.executor.execute(plan)
        return True

    def deny_plan(self, plan_id: str) -> bool:
        return self.executor.cancel(plan_id)

    def approve_suggestion(self, suggestion_id: str) -> bool:
        return self.learning.accept_suggestion(suggestion_id)

    def reject_suggestion(self, suggestion_id: str) -> bool:
        return self.learning.reject_suggestion(suggestion_id)

    def explain(self, decision_id: str) -> Explanation | None:
        return self.decisions.explain(decision_id)

    def suggest(self) -> Suggestion | None:
        pending = self.learning.pending_suggestions()
        return pending[0] if pending else None

    def status(self) -> dict[str, Any]:
        return {
            "state": self.state.current.name,
            "previous": self.state.previous.name,
            "context": self.context.snapshot(),
            "active_intents": [i.name for i in self.intents.by_priority()],
            "active_policies": [
                m.policy.name
                for m in self.policies.evaluate(self.context, self.intents.by_priority())
            ],
            "recent_decisions": len(self.decisions.recent(5)),
            "learning": self.learning.summary(),
        }

    def get(self, key: str, default: Any = None) -> Any:
        return self._store.get(key, default)

    def put(self, key: str, value: Any) -> None:
        self._store[key] = value


class _DefaultExecutor:
    def execute(self, action: Action) -> bool:
        return True
