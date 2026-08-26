from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Callable
from uuid import uuid4


class EventKind(Enum):
    # Hardware
    POWER_STATE_CHANGED = auto()
    DEVICE_CONNECTED = auto()
    DEVICE_DISCONNECTED = auto()
    THERMAL_STATE_CHANGED = auto()
    RESOURCE_USAGE_CHANGED = auto()

    # Applications
    APPLICATION_STARTED = auto()
    APPLICATION_CLOSED = auto()
    APPLICATION_STATE_CHANGED = auto()

    # System
    SERVICE_STATE_CHANGED = auto()
    NETWORK_STATE_CHANGED = auto()
    TIME_TICK = auto()

    # User
    USER_ACTION = auto()
    MODE_REQUESTED = auto()

    # Legacy compatibility
    BOOT = auto()
    SHUTDOWN = auto()
    THEME_CHANGED = auto()
    PROFILE_SWITCHED = auto()
    DESTRUCTIVE_ACTION = auto()
    ERROR = auto()
    RECOVERY = auto()


class PowerState(Enum):
    AC = auto()
    BATTERY = auto()
    UNKNOWN = auto()


class ThermalState(Enum):
    NORMAL = auto()
    WARM = auto()
    HOT = auto()
    CRITICAL = auto()


@dataclass(frozen=True)
class Event:
    kind: EventKind
    payload: dict[str, Any] = field(default_factory=dict)
    source: str = ""
    id: str = field(default_factory=lambda: uuid4().hex[:12])
    confidence: float = 1.0

    @property
    def timestamp(self) -> float:
        import time
        return time.time()


Listener = Callable[[Event], None]


class EventBus:
    def __init__(self) -> None:
        self._by_kind: dict[EventKind, list[Listener]] = {}
        self._global: list[Listener] = []
        self._ring: list[Event] = []
        self._ring_max = 1000

    def on(self, kind: EventKind, fn: Listener) -> None:
        self._by_kind.setdefault(kind, []).append(fn)

    def on_all(self, fn: Listener) -> None:
        self._global.append(fn)

    def emit(self, event: Event) -> None:
        self._ring.append(event)
        if len(self._ring) > self._ring_max:
            self._ring = self._ring[-self._ring_max:]
        for fn in self._global:
            fn(event)
        for fn in self._by_kind.get(event.kind, []):
            fn(event)

    def recent(self, kind: EventKind, n: int = 10) -> list[Event]:
        return [e for e in reversed(self._ring) if e.kind == kind][:n]

    def clear(self) -> None:
        self._ring.clear()
