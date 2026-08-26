from __future__ import annotations
import time
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any
from uuid import uuid4

from .policy import Action, SafetyLevel
from .decision import Decision


class PlanStatus(Enum):
    PENDING = auto()
    EXECUTING = auto()
    COMPLETED = auto()
    FAILED = auto()
    ROLLED_BACK = auto()
    CANCELLED = auto()


class ActionStatus(Enum):
    PENDING = auto()
    EXECUTING = auto()
    COMPLETED = auto()
    FAILED = auto()
    SKIPPED = auto()
    ROLLED_BACK = auto()


@dataclass
class RollbackAction:
    action_kind: str
    params: dict[str, Any]
    original_value: str
    description: str = ""


@dataclass
class PlannedAction:
    action: Action
    id: str = field(default_factory=lambda: uuid4().hex[:8])
    depends_on: list[str] = field(default_factory=list)
    timeout: float | None = None
    max_retries: int = 0
    rollback: RollbackAction | None = None
    status: ActionStatus = ActionStatus.PENDING
    error: str | None = None


@dataclass
class Plan:
    id: str = field(default_factory=lambda: uuid4().hex[:12])
    created: float = field(default_factory=time.time)
    decision_id: str = ""
    actions: list[PlannedAction] = field(default_factory=list)
    status: PlanStatus = PlanStatus.PENDING
    started: float | None = None
    completed: float | None = None
    error: str | None = None

    @property
    def duration(self) -> float | None:
        if self.started is None:
            return None
        end = self.completed or time.time()
        return end - self.started

    @property
    def progress(self) -> float:
        if not self.actions:
            return 0.0
        done = sum(1 for a in self.actions if a.status in (ActionStatus.COMPLETED, ActionStatus.SKIPPED))
        return done / len(self.actions)


class PlanBuilder:
    @staticmethod
    def from_decision(decision: Decision) -> Plan:
        plan = Plan(decision_id=decision.id)
        for action in decision.actions:
            planned = PlannedAction(
                action=action,
                timeout=30.0,
                max_retries=1,
                rollback=PlanBuilder._make_rollback(action),
            )
            plan.actions.append(planned)
        return plan

    @staticmethod
    def _make_rollback(action: Action) -> RollbackAction | None:
        rollback_map = {
            "set_process_priority": RollbackAction(
                action_kind="set_process_priority",
                params={"target": action.params.get("target", ""), "priority": 0},
                original_value="0",
                description="restore default priority",
            ),
            "set_governor": RollbackAction(
                action_kind="set_governor",
                params={"mode": "balanced"},
                original_value="balanced",
                description="restore balanced governor",
            ),
            "disable_effects": RollbackAction(
                action_kind="enable_effects",
                params={"effects": action.params.get("effects", [])},
                original_value="enabled",
                description="re-enable effects",
            ),
            "suppress_notifications": RollbackAction(
                action_kind="unsuppress_notifications",
                params={},
                original_value="normal",
                description="restore notification level",
            ),
            "reduce_refresh_rate": RollbackAction(
                action_kind="set_refresh_rate",
                params={"rate": 0},
                original_value="auto",
                description="restore refresh rate",
            ),
            "limit_cpu_percent": RollbackAction(
                action_kind="limit_cpu_percent",
                params={"limit": 100.0},
                original_value="100",
                description="remove CPU limit",
            ),
            "suspend_service": RollbackAction(
                action_kind="resume_service",
                params={"service": action.params.get("service", "")},
                original_value="active",
                description="resume suspended service",
            ),
        }
        return rollback_map.get(action.kind)


class PlanExecutor:
    def __init__(self) -> None:
        self.active: dict[str, Plan] = {}
        self.completed: list[Plan] = []
        self._executors: dict[str, Any] = {}

    def register_executor(self, action_kind: str, executor: Any) -> None:
        self._executors[action_kind] = executor

    def execute(self, plan: Plan) -> Plan:
        plan.status = PlanStatus.EXECUTING
        plan.started = time.time()
        self.active[plan.id] = plan

        for planned in plan.actions:
            if plan.status == PlanStatus.CANCELLED:
                break

            if not self._dependencies_met(plan, planned):
                planned.status = ActionStatus.SKIPPED
                planned.error = "dependencies not met"
                continue

            success = self._execute_action(planned)
            if not success and planned.max_retries > 0:
                for attempt in range(planned.max_retries):
                    success = self._execute_action(planned)
                    if success:
                        break

            if not success:
                plan.status = PlanStatus.FAILED
                plan.error = f"action {planned.id} failed: {planned.error}"
                self._rollback_plan(plan)
                break

        if plan.status == PlanStatus.EXECUTING:
            plan.status = PlanStatus.COMPLETED
            plan.completed = time.time()

        del self.active[plan.id]
        self.completed.append(plan)
        return plan

    def _dependencies_met(self, plan: Plan, planned: PlannedAction) -> bool:
        for dep_id in planned.depends_on:
            dep = next((a for a in plan.actions if a.id == dep_id), None)
            if dep is None or dep.status != ActionStatus.COMPLETED:
                return False
        return True

    def _execute_action(self, planned: PlannedAction) -> bool:
        executor = self._executors.get(planned.action.kind)
        if executor is None:
            planned.status = ActionStatus.COMPLETED
            return True

        planned.status = ActionStatus.EXECUTING
        try:
            result = executor.execute(planned.action)
            if result:
                planned.status = ActionStatus.COMPLETED
                return True
            else:
                planned.status = ActionStatus.FAILED
                planned.error = "executor returned false"
                return False
        except Exception as e:
            planned.status = ActionStatus.FAILED
            planned.error = str(e)
            return False

    def _rollback_plan(self, plan: Plan) -> None:
        for planned in reversed(plan.actions):
            if planned.status == ActionStatus.COMPLETED and planned.rollback:
                self._rollback_action(planned)
                planned.status = ActionStatus.ROLLED_BACK
        plan.status = PlanStatus.ROLLED_BACK

    def _rollback_action(self, planned: PlannedAction) -> bool:
        if planned.rollback is None:
            return True
        executor = self._executors.get(planned.rollback.action_kind)
        if executor is None:
            return True
        try:
            action = Action(
                kind=planned.rollback.action_kind,
                params=planned.rollback.params,
                description=planned.rollback.description,
            )
            return executor.execute(action)
        except Exception:
            return False

    def cancel(self, plan_id: str) -> bool:
        plan = self.active.get(plan_id)
        if plan:
            plan.status = PlanStatus.CANCELLED
            return True
        return False

    def status(self, plan_id: str) -> Plan | None:
        if plan_id in self.active:
            return self.active[plan_id]
        for p in self.completed:
            if p.id == plan_id:
                return p
        return None
