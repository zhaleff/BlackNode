from __future__ import annotations

from ..context import NotificationContext
from ..envelope import NotificationEnvelope


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    value = ctx.get("value", 0)
    body = ctx.collapse(fallback=f"{value}%", value=value, previous=value)
    return ctx.envelope(
        title="Brightness",
        body=body,
        icon=ctx.icon("brightness", "display-brightness"),
        urgency="low",
        timeout=2000,
        replace_id=2593,
        hints=[("value", value)],
    )


def run(service) -> None:
    from ...sensors.display import get_brightness

    service.notify("brightness", value=get_brightness())