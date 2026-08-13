from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from ..psyche.timing import Period
from ..resources import resolve
from .envelope import NotificationEnvelope

_NOT_SET = object()


@dataclass
class NotificationContext:
    engine: Any
    domain: str
    data: dict[str, Any] = field(default_factory=dict)
    period: Period = "afternoon"

    def __post_init__(self) -> None:
        self.period = self.engine.clock.current_period()

    def get(self, key: str, default: Any = _NOT_SET) -> Any:
        if key in self.data:
            return self.data[key]
        if default is _NOT_SET:
            raise KeyError(key)
        return default

    def collapse(self, domain: str | None = None, *, fallback: str = "", **kw) -> str:
        return self.engine._collapse(domain or self.domain, self.period, fallback=fallback, **kw)

    def icon(self, *names: str) -> str:
        return resolve(*names)

    def envelope(
        self,
        *,
        title: str,
        body: str,
        icon: str = "",
        urgency: str = "normal",
        timeout: int = 5000,
        replace_id: int = 0,
        app_name: str = "BlackNode",
        hints: list[tuple[str, str | int]] | None = None,
    ) -> NotificationEnvelope:
        return NotificationEnvelope(
            title=title,
            body=body,
            icon=icon,
            urgency=urgency,
            timeout=timeout,
            replace_id=replace_id,
            app_name=app_name,
            hints=hints or [],
        )
