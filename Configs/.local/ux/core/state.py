from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Callable


class UXState(Enum):
    IDLE = auto()
    FIRST_BOOT = auto()
    DAILY_USE = auto()
    CUSTOMIZING = auto()
    GAMING = auto()
    LOW_POWER = auto()
    UPDATING = auto()
    ERROR = auto()
    RECOVERING = auto()
    DESTRUCTIVE_PENDING = auto()
    MAINTENANCE = auto()
    FOCUS = auto()
    PRESENTATION = auto()
    DOCKED = auto()
    UNDOCKED = auto()


_ANY = object()


@dataclass(frozen=True)
class Transition:
    source: UXState | object
    target: UXState
    trigger: str
    guard: str | None = None


@dataclass
class StateMachine:
    current: UXState = UXState.IDLE
    previous: UXState = UXState.IDLE
    _history: list[UXState] = field(default_factory=list)
    _transitions: list[Transition] = field(default_factory=list)
    _guards: dict[str, Callable[[], bool]] = field(default_factory=dict)

    def __post_init__(self) -> None:
        self._transitions = [
            Transition(_ANY, UXState.ERROR, "error"),
            Transition(UXState.IDLE, UXState.FIRST_BOOT, "boot", "is_first_boot"),
            Transition(UXState.IDLE, UXState.DAILY_USE, "boot", "not_first_boot"),
            Transition(UXState.DAILY_USE, UXState.CUSTOMIZING, "customize"),
            Transition(UXState.CUSTOMIZING, UXState.DAILY_USE, "done"),
            Transition(UXState.DAILY_USE, UXState.GAMING, "game_start"),
            Transition(UXState.GAMING, UXState.DAILY_USE, "game_end"),
            Transition(UXState.DAILY_USE, UXState.LOW_POWER, "battery_low"),
            Transition(UXState.LOW_POWER, UXState.DAILY_USE, "battery_ok"),
            Transition(UXState.DAILY_USE, UXState.UPDATING, "update_start"),
            Transition(UXState.UPDATING, UXState.DAILY_USE, "update_done"),
            Transition(UXState.ERROR, UXState.RECOVERING, "recover"),
            Transition(UXState.RECOVERING, UXState.DAILY_USE, "recovery_done"),
            Transition(UXState.DAILY_USE, UXState.DESTRUCTIVE_PENDING, "destruct"),
            Transition(UXState.DESTRUCTIVE_PENDING, UXState.DAILY_USE, "destruct_confirm"),
            Transition(UXState.DESTRUCTIVE_PENDING, UXState.DAILY_USE, "destruct_cancel"),
            Transition(UXState.DAILY_USE, UXState.MAINTENANCE, "maintenance_start"),
            Transition(UXState.MAINTENANCE, UXState.DAILY_USE, "maintenance_done"),
            Transition(UXState.DAILY_USE, UXState.FOCUS, "focus_start"),
            Transition(UXState.FOCUS, UXState.DAILY_USE, "focus_end"),
            Transition(UXState.DAILY_USE, UXState.PRESENTATION, "presentation_start"),
            Transition(UXState.PRESENTATION, UXState.DAILY_USE, "presentation_end"),
            Transition(UXState.DAILY_USE, UXState.DOCKED, "dock"),
            Transition(UXState.DOCKED, UXState.UNDOCKED, "undock"),
            Transition(UXState.UNDOCKED, UXState.DAILY_USE, "undock_done"),
        ]

    def set_guard(self, name: str, fn: Callable[[], bool]) -> None:
        self._guards[name] = fn

    def can(self, trigger: str) -> bool:
        return any(
            self._matches(t, trigger)
            and (not t.guard or self._guards.get(t.guard, lambda: True)())
            for t in self._transitions
        )

    def fire(self, trigger: str) -> UXState | None:
        for t in self._transitions:
            if self._matches(t, trigger):
                if t.guard and not self._guards.get(t.guard, lambda: True)():
                    continue
                self._history.append(self.current)
                self.previous = self.current
                self.current = t.target
                return self.current
        return None

    def _matches(self, t: Transition, trigger: str) -> bool:
        return t.trigger == trigger and (t.source is _ANY or t.source == self.current)

    @property
    def history(self) -> list[UXState]:
        return list(self._history)

    @property
    def available_triggers(self) -> list[str]:
        return [
            t.trigger
            for t in self._transitions
            if (t.source is _ANY or t.source == self.current)
        ]
