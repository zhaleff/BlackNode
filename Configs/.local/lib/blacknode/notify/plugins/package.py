from __future__ import annotations

from ..context import NotificationContext
from ..envelope import NotificationEnvelope


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    total = ctx.get("total", 0)
    official = ctx.get("official", 0)
    aur = ctx.get("aur", 0)
    body = ctx.collapse(
        fallback=f"{total} packages can be updated",
        count=total,
        official=official,
        aur=aur,
    )
    return ctx.envelope(
        title="Updates available",
        body=body,
        icon=ctx.icon("package", "software-update-available", "system-software-update"),
        urgency="normal",
        timeout=8000,
        replace_id=2598,
        app_name="Packages",
    )


def run(service) -> None:
    from ...sensors.packages import count_updates

    official, aur = count_updates()
    total = official + aur
    if total > 0:
        service.notify("package", total=total, official=official, aur=aur)