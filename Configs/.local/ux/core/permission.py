from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any

from .policy import Policy, SafetyLevel


class PolicyDecision(Enum):
    ALLOW = auto()
    DENY = auto()
    ASK = auto()


@dataclass
class Permission:
    policy_name: str
    decision: PolicyDecision
    granted_at: float | None = None
    remember: bool = True


class PermissionManager:
    def __init__(self) -> None:
        self._permissions: dict[str, Permission] = {}
        self._defaults: dict[SafetyLevel, PolicyDecision] = {
            SafetyLevel.SAFE: PolicyDecision.ALLOW,
            SafetyLevel.MODERATE: PolicyDecision.ALLOW,
            SafetyLevel.SENSITIVE: PolicyDecision.ASK,
            SafetyLevel.CRITICAL: PolicyDecision.ASK,
        }
        self._pending: list[Policy] = []

    def check(self, policy: Policy) -> PolicyDecision:
        if policy.name in self._permissions:
            return self._permissions[policy.name].decision
        return self._defaults.get(policy.safety, PolicyDecision.ASK)

    def check_plan(self, policies: list[Policy]) -> tuple[PolicyDecision, list[Policy]]:
        need_ask: list[Policy] = []
        for policy in policies:
            decision = self.check(policy)
            if decision == PolicyDecision.DENY:
                return PolicyDecision.DENY, []
            if decision == PolicyDecision.ASK:
                need_ask.append(policy)
        if need_ask:
            return PolicyDecision.ASK, need_ask
        return PolicyDecision.ALLOW, []

    def grant(self, policy_name: str, remember: bool = True) -> None:
        import time
        self._permissions[policy_name] = Permission(
            policy_name=policy_name,
            decision=PolicyDecision.ALLOW,
            granted_at=time.time(),
            remember=remember,
        )

    def deny(self, policy_name: str, remember: bool = True) -> None:
        import time
        self._permissions[policy_name] = Permission(
            policy_name=policy_name,
            decision=PolicyDecision.DENY,
            granted_at=time.time(),
            remember=remember,
        )

    def revoke(self, policy_name: str) -> bool:
        if policy_name in self._permissions:
            del self._permissions[policy_name]
            return True
        return False

    def set_default(self, safety: SafetyLevel, decision: PolicyDecision) -> None:
        self._defaults[safety] = decision

    def list_permissions(self) -> list[Permission]:
        return list(self._permissions.values())

    def pending(self) -> list[Policy]:
        return list(self._pending)

    def clear_pending(self) -> None:
        self._pending.clear()

    def export(self) -> dict[str, Any]:
        return {
            name: {
                "decision": p.decision.name,
                "granted_at": p.granted_at,
                "remember": p.remember,
            }
            for name, p in self._permissions.items()
        }

    def import_permissions(self, data: dict[str, Any]) -> None:
        for name, info in data.items():
            self._permissions[name] = Permission(
                policy_name=name,
                decision=PolicyDecision[info["decision"]],
                granted_at=info.get("granted_at"),
                remember=info.get("remember", True),
            )
