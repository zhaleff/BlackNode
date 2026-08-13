from __future__ import annotations
import json
import math
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Literal

Period = Literal["late", "dawn", "morning", "noon", "afternoon", "evening", "night"]

SOLAR_TERMINATORS: list[tuple[float, float, Period]] = [
    (0.0, 0.08, "late"),
    (0.08, 0.2, "dawn"),
    (0.2, 0.4, "morning"),
    (0.4, 0.55, "noon"),
    (0.55, 0.7, "afternoon"),
    (0.7, 0.88, "evening"),
    (0.88, 1.0, "night"),
]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def day_progress(now: datetime | None = None) -> float:
    now = now or utc_now()
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    elapsed = (now - start).total_seconds()
    return elapsed / 86400.0


def period_from_progress(progress: float) -> Period:
    p = progress % 1.0
    for lo, hi, period in SOLAR_TERMINATORS:
        if lo <= p < hi:
            return period
    return "night"


class CircadianClock:
    def now(self) -> datetime:
        return utc_now()

    def current_progress(self, at: datetime | None = None) -> float:
        return day_progress(at)

    def current_period(self, at: datetime | None = None) -> Period:
        p = self.current_progress(at)
        return period_from_progress(p)

    def period_name(self, period: Period | None = None) -> str:
        names = {
            "late": "Deep Night",
            "dawn": "First Light",
            "morning": "Morning",
            "noon": "Midday",
            "afternoon": "Afternoon",
            "evening": "Evening",
            "night": "Night",
        }
        return names.get(period or self.current_period(), "Unknown")

    def period_color(self, period: Period | None = None) -> str:
        colors = {
            "late": "#5b6ee1",
            "dawn": "#f5a25d",
            "morning": "#ffd166",
            "noon": "#ffb703",
            "afternoon": "#fb8500",
            "evening": "#9d4edd",
            "night": "#3a0ca3",
        }
        return colors.get(period or self.current_period(), "#ffffff")

    def is_silent_hours(self, at: datetime | None = None) -> bool:
        p = self.current_period(at)
        return p in ("late", "night")

    def seconds_until_next_period(self, at: datetime | None = None) -> float:
        now = at or utc_now()
        p = self.current_progress(now)
        for lo, hi, _ in SOLAR_TERMINATORS:
            if lo <= p < hi:
                target = hi
                break
        else:
            target = 1.0
        delta_progress = target - p
        return delta_progress * 86400.0

    def greeting(self, at: datetime | None = None) -> str:
        period = self.current_period(at)
        dow = (at or utc_now()).weekday()
        greetings = {
            "late": "Still going",
            "dawn": "Early start",
            "morning": "Good morning",
            "noon": "Midday",
            "afternoon": "Hey",
            "evening": "Good evening",
            "night": "Still at it",
        }
        base = greetings.get(period, "Hey")
        if dow >= 5:
            base = f"{base} — it's the weekend"
        return base

    def day_momentum(self, at: datetime | None = None) -> float:
        return self.current_progress(at)

    def day_of_week(self, at: datetime | None = None) -> int:
        return (at or utc_now()).weekday()

    def is_weekend(self, at: datetime | None = None) -> bool:
        return self.day_of_week(at) >= 5

    def hour_utc(self, at: datetime | None = None) -> int:
        return (at or utc_now()).hour


class RateLimiter:
    def __init__(self, window: float = 2.0, max_burst: int = 1):
        self.window = window
        self.max_burst = max_burst
        self._last: dict[str, float] = {}
        self._count: dict[str, int] = {}

    def allow(self, key: str, now: float | None = None) -> bool:
        t = now or time.time()
        last = self._last.get(key, 0.0)
        count = self._count.get(key, 0)
        if t - last < self.window:
            if count >= self.max_burst:
                return False
            self._count[key] = count + 1
        else:
            self._count[key] = 1
        self._last[key] = t
        return True

    def reset(self, key: str) -> None:
        self._last.pop(key, None)
        self._count.pop(key, None)


class NotificationHistory:
    def __init__(self, path: str = "~/.local/share/blacknode/notif_history.json"):
        self._path = Path(path).expanduser()
        self._path.parent.mkdir(parents=True, exist_ok=True)
        self._data: dict = self._load()

    def _load(self) -> dict:
        try:
            return json.loads(self._path.read_text())
        except (FileNotFoundError, json.JSONDecodeError):
            return {"last_seen": {}, "counts": {}, "cooldowns": {}, "streak": 0}

    def _save(self) -> None:
        self._path.write_text(json.dumps(self._data, indent=2))

    def was_recent(self, key: str, within: float = 300.0) -> bool:
        last = self._data["last_seen"].get(key, 0.0)
        return (time.time() - last) < within

    def mark_seen(self, key: str) -> None:
        self._data["last_seen"][key] = time.time()
        self._data["counts"][key] = self._data["counts"].get(key, 0) + 1
        self._save()

    def count(self, key: str) -> int:
        return self._data["counts"].get(key, 0)

    def count_today(self, key: str) -> int:
        self._maybe_rotate()
        return self._data["counts"].get(key, 0)

    def _maybe_rotate(self) -> None:
        pass

    def cooldown_active(self, key: str) -> bool:
        until = self._data["cooldowns"].get(key, 0.0)
        return time.time() < until

    def set_cooldown(self, key: str, seconds: float) -> None:
        self._data["cooldowns"][key] = time.time() + seconds
        self._save()
