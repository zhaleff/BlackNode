from __future__ import annotations

import time

from ..context import NotificationContext
from ..envelope import NotificationEnvelope

POLL_SECONDS = 30
THRESHOLDS = (5, 10, 15, 20)


def _band(capacity: int) -> int | None:
    for threshold in THRESHOLDS:
        if capacity <= threshold:
            return threshold
    return None


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    capacity = ctx.get("capacity", 0)
    threshold = ctx.get("threshold", 0)
    critical = threshold <= 5
    return ctx.envelope(
        title="Low battery",
        body=f"{capacity}% remaining. Plug in the charger.",
        icon=ctx.icon("battery-low", "battery-critical"),
        urgency="critical" if critical else "normal",
        timeout=0 if critical else 8000,
        replace_id=2594,
        app_name="Battery",
    )


def run(service) -> None:
    from ...sensors.power import get_battery

    prev_band = None
    while True:
        capacity, status = get_battery()
        if capacity is not None and status is not None:
            status = status.lower()
            if status == "discharging":
                band = _band(capacity)
                if band is not None and band != prev_band and (prev_band is None or band < prev_band):
                    prev_band = band
                    service.notify("battery", capacity=capacity, threshold=band)
            else:
                prev_band = None
        time.sleep(POLL_SECONDS)