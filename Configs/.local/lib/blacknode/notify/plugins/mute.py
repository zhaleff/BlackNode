from __future__ import annotations

from ..context import NotificationContext
from ..envelope import NotificationEnvelope


def _volume_icon_names(value: int) -> tuple[str, ...]:
    if value == 0:
        return ("volume-cross", "volume-muted", "audio-volume-muted")
    if value <= 50:
        return ("volume-min", "audio-volume-low", "volume-low")
    if value <= 80:
        return ("volume-full", "audio-volume-medium", "volume-medium")
    return ("volume-loud", "audio-volume-high", "volume-high")


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    muted = ctx.get("muted", False)
    previous = ctx.get("previous", 0) or 0
    if muted:
        body = ctx.collapse(
            "mute_on",
            value=previous,
            was=previous,
            fallback="Muted",
        )
        title, icon = "Muted", ctx.icon("volume-cross", "audio-volume-muted")
    else:
        fallback = f"Unmuted — {previous}%" if previous else "Unmuted"
        body = ctx.collapse(
            "mute_off",
            value=previous,
            fallback=fallback,
        )
        title = "Unmuted"
        icon = ctx.icon(*_volume_icon_names(previous or 50))
    return ctx.envelope(
        title=title,
        body=body,
        icon=icon,
        urgency="low",
        timeout=2000,
        replace_id=2593,
    )


def run(service) -> None:
    from ...sensors.audio import get_sink_volume, toggle_mute

    previous, _ = get_sink_volume()
    toggle_mute()
    _, muted = get_sink_volume()
    service.notify("mute", muted=muted, previous=previous)