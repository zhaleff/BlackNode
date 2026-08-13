from __future__ import annotations
import random
from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal

Period = Literal["late", "dawn", "morning", "noon", "afternoon", "evening", "night"]


@dataclass(frozen=True)
class TraitProfile:
    warmth: float       # 0.0 = cold / utilitarian, 1.0 = warm / companionable
    directness: float   # 0.0 = subtle / suggestive, 1.0 = blunt / imperative
    formality: float    # 0.0 = casual / slangy, 1.0 = formal / proper
    humor: float        # 0.0 = serious, 1.0 = playful / witty
    verbosity: float    # 0.0 = terse, 1.0 = verbose / story-like


PERSONAS: dict[str, TraitProfile] = {
    "blacknode_default": TraitProfile(
        warmth=0.65, directness=0.55, formality=0.30,
        humor=0.40, verbosity=0.45,
    ),
    "blacknode_minimal": TraitProfile(
        warmth=0.20, directness=0.85, formality=0.15,
        humor=0.10, verbosity=0.10,
    ),
    "blacknode_guide": TraitProfile(
        warmth=0.75, directness=0.50, formality=0.40,
        humor=0.30, verbosity=0.60,
    ),
}


@dataclass
class PersonalityProfile:
    name: str = "blacknode_default"
    traits: TraitProfile = field(default_factory=lambda: PERSONAS["blacknode_default"])

    def modulate(self, period: Period) -> TraitProfile:
        t = self.traits
        if period in ("late", "night"):
            return TraitProfile(
                warmth=min(1.0, t.warmth * 1.3),
                directness=min(1.0, t.directness * 0.7),
                formality=t.formality,
                humor=max(0.0, t.humor * 0.3),
                verbosity=max(0.0, t.verbosity * 0.5),
            )
        if period in ("dawn", "morning"):
            return TraitProfile(
                warmth=min(1.0, t.warmth * 1.15),
                directness=t.directness,
                formality=t.formality,
                humor=min(1.0, t.humor * 1.2),
                verbosity=min(1.0, t.verbosity * 1.1),
            )
        if period == "evening":
            return TraitProfile(
                warmth=min(1.0, t.warmth * 1.2),
                directness=max(0.0, t.directness * 0.8),
                formality=max(0.0, t.formality * 0.7),
                humor=min(1.0, t.humor * 1.3),
                verbosity=min(1.0, t.verbosity * 1.2),
            )
        return t

    def pick(self, options: list[str], period: Period | None = None) -> str:
        tm = self.modulate(period) if period else self.traits
        idx = int((tm.warmth + tm.humor) / 2 * (len(options) - 1))
        idx = max(0, min(idx, len(options) - 1))
        if random.random() < 0.15:
            idx = random.randint(0, len(options) - 1)
        return options[idx]
