from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any

from .personality import PersonalityProfile, Period
from .timing import CircadianClock, RateLimiter, NotificationHistory
from .framing import MessageFramer
from ..notify.envelope import NotificationEnvelope


@dataclass
class PsychContext:
    event_type: str
    data: dict[str, Any] = field(default_factory=dict)
    previous: dict[str, Any] = field(default_factory=dict)
    period: Period = "afternoon"
    state: dict[str, Any] = field(default_factory=dict)


class PsychEngine:
    def __init__(
        self,
        personality: PersonalityProfile | None = None,
        clock: CircadianClock | None = None,
        history: NotificationHistory | None = None,
        rate_limiter: RateLimiter | None = None,
        dry_run: bool = False,
        debug: bool = False,
    ):
        self.personality = personality or PersonalityProfile()
        self.clock = clock or CircadianClock()
        self.history = history or NotificationHistory()
        self.rate_limiter = rate_limiter or RateLimiter()
        self.framer = MessageFramer(self.personality)
        self.dry_run = dry_run
        self.debug = debug

    def _make_context(self, event_type: str, data: dict, previous: dict | None = None) -> PsychContext:
        return PsychContext(
            event_type=event_type,
            data=data,
            previous=previous or {},
            period=self.clock.current_period(),
        )

    def _collapse(self, domain: str, period: Period | None = None, *, fallback: str = "", **kw) -> str:
        return self.framer.strategy_chain(domain, self._strategies_for(domain), period, fallback=fallback, **kw)

    def _strategies_for(self, domain: str) -> list[str]:
        MAP: dict[str, list[str]] = {
            "battery_discharging": ["loss", "scarcity", "identity", "ikea", "goal_gradient", "autonomy", "reciprocity"],
            "battery_charging": ["gain", "ikea", "goal_gradient", "zeigarnik", "reciprocity"],
            "battery_full": ["gain", "identity", "zeigarnik"],
            "volume": ["ikea", "ikea_identity", "anchor", "identity", "autonomy", "variable_reward"],
            "brightness": ["ikea", "ikea_identity", "anchor", "identity", "autonomy"],
            "mute_on": ["variable_reward", "identity"],
            "mute_off": ["variable_reward"],
            "media": ["identity", "variable_reward", "zeigarnik"],
            "wifi_connect": ["ikea", "ikea_identity", "reassurance", "identity", "gain"],
            "wifi_disconnect": ["companion", "loss", "reciprocity"],
            "device_add": ["ikea", "ikea_identity", "welcome", "identity", "companion"],
            "device_remove": ["loss", "companion", "reciprocity"],
            "package": ["identity", "zeigarnik", "social_proof", "autonomy"],
            "weather": ["identity", "variable_reward"],
            "weather_alert": ["scarcity"],
        }
        return MAP.get(domain, ["variable_reward"])
