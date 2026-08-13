from __future__ import annotations

from ..context import NotificationContext
from ..envelope import NotificationEnvelope


def _volume_icon_names(value: int) -> tuple[str, ...]:
    if value == 0:
        return ("volume-cross", "volume-muted", "audio-volume-muted")
    if value <= 50:
        return ("volume-min", "audio-volume-low", "volume-low")
    return ("volume-loud", "audio-volume-high", "volume-high")


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    value = ctx.get("value", 0)
    body = ctx.collapse(fallback=f"{value}%", value=value, previous=value)
    return ctx.envelope(
        title="Volume",
        body=body,
        icon=ctx.icon(*_volume_icon_names(value)),
        urgency="low",
        timeout=2000,
        replace_id=2593,
        hints=[("value", value)],
    )


def run(service) -> None:
    from ...sensors.audio import get_sink_volume

    volume, _ = get_sink_volume()
    service.notify("volume", value=volume)