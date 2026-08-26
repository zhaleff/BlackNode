"""Core domain — behavioral logic, zero UI."""
from .engine import UXEngine
from .events import Event, EventBus, EventKind, PowerState, ThermalState
from .state import UXState, StateMachine
from .context import WorldModel, AppClass, SessionMode, Trend, PressureLevel
from .intent import Intent, IntentSystem, IntentSource
from .policy import Policy, PolicyEngine, Action, SafetyLevel
from .decision import Decision, DecisionEngine, Explanation, Resolution
from .plan import Plan, PlanBuilder, PlanExecutor, PlanStatus
from .permission import PermissionManager, PolicyDecision
from .learning import LearningLayer, Suggestion, Pattern

__all__ = [
    "UXEngine",
    "Event", "EventBus", "EventKind", "PowerState", "ThermalState",
    "UXState", "StateMachine",
    "WorldModel", "AppClass", "SessionMode", "Trend", "PressureLevel",
    "Intent", "IntentSystem", "IntentSource",
    "Policy", "PolicyEngine", "Action", "SafetyLevel",
    "Decision", "DecisionEngine", "Explanation", "Resolution",
    "Plan", "PlanBuilder", "PlanExecutor", "PlanStatus",
    "PermissionManager", "PolicyDecision",
    "LearningLayer", "Suggestion", "Pattern",
]
