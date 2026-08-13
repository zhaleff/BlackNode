from __future__ import annotations
import random
import re
from .personality import PersonalityProfile, Period

DOMAIN_NORMALIZE = re.compile(r"_(add|remove|connect|disconnect|charging|discharging|full|on|off|alert)$")

IKEA_TEMPLATES = {
    "volume": [
        "You set it to {value}%. Feels right.",
        "You dialed it to {value}%. Your ears, your call.",
        "You chose {value}%. Good level.",
    ],
    "brightness": [
        "You tuned it to {value}%. Looks good.",
        "You set the brightness to {value}%. Easy on the eyes.",
        "Your eyes say {value}%. Who am I to argue.",
    ],
    "device": [
        "You plugged in {device}. It works. Nice.",
        "You connected {device}. Recognized and ready.",
        "{device} is live \u2014 because you connected it.",
    ],
    "wifi": [
        "You're on {ssid}. You made the connection.",
        "{ssid} \u2014 you picked the right network.",
    ],
    "battery": [
        "You plugged it in. Now it's charging at {value}%.",
        "You disconnected the charger. {value}% to work with.",
    ],
}

COMPANION_TEMPLATES = {
    "battery": [
        "I've got my eye on it. {value}%, all good.",
        "I'll watch the battery. Currently {value}%.",
        "Battery at {value}%. I'll let you know if it changes.",
    ],
    "wifi": [
        "I'll keep scanning. You'll be back online soon.",
        "WiFi's gone. I'll tell you when it's back.",
    ],
    "device": [
        "{device} is here. I'll keep an eye on it.",
        "{device} ready. Holler if you need anything.",
    ],
}

IDENTITY_TEMPLATES = {
    "battery": [
        "You keep your gear alive. {value}% and counting.",
        "Field-agent mode below 20%. You've got this.",
        "You're the kind of person who stays powered. {value}%.",
    ],
    "package": [
        "You maintain a clean system. {count} updates ready.",
        "Ship shape \u2014 {count} packages have new versions.",
        "You're on top of maintenance. {count} updates waiting.",
    ],
    "device": [
        "Your system recognized {device}. It knows its tools.",
        "You build a setup that works. {device} just fits.",
        "{device} connected. Your rig keeps growing.",
    ],
    "volume": [
        "You know your levels. {value}% is the sweet spot.",
        "You have good audio instincts. {value}% sounds right.",
    ],
    "brightness": [
        "You know what looks right. {value}% is perfect.",
        "Your display, your preference. {value}%.",
    ],
    "wifi": [
        "{ssid} \u2014 you're connected because you set it up right.",
        "You built a network that works. {ssid} is live.",
    ],
    "media": [
        "You have great taste. {title} is a solid pick.",
        "Your playlist says a lot. {title} \u2014 good choice.",
        "You know good music. {title} by {artist}.",
    ],
    "mute_on": [
        "You value focus. Muted is the right call.",
        "You chose silence. Smart move.",
    ],
    "weather": [
        "{desc} out there. You know how to prepare for it.",
        "You've seen {desc} before. You know what to do.",
    ],
}

IKEA_IDENTITY_TEMPLATES = {
    "volume": [
        "You tuned it yourself. {value}% \u2014 that's your level.",
        "You set it to {value}%. Because you know what works.",
    ],
    "brightness": [
        "{value}% \u2014 you dialed it in. Just right.",
        "You adjusted it to {value}%. Your eyes decided.",
    ],
    "device": [
        "You plugged in {device}. You made your setup better.",
        "You added {device}. That's initiative right there.",
    ],
    "wifi": [
        "You connected to {ssid}. Your network, your choice.",
        "You're on {ssid}. Because you set it up.",
    ],
    "battery": [
        "You chose when to charge. Now at {value}%.",
        "You decided to unplug. {value}% to own the day.",
    ],
}

ZEIGARNIK_TEMPLATES = {
    "battery": [
        "Charging at {value}%. Still {remaining}% to full. I'll check back.",
        "{value}% charged. To be continued until 100%.",
    ],
    "package": [
        "{count} updates pending. They'll be here when you're ready.",
        "{count} packages waiting. No rush \u2014 they're not going anywhere.",
    ],
    "media": [
        "{title} \u2014 {artist}. Good track. Wonder what's next.",
        "Now playing: {title}. The queue keeps going.",
    ],
    "device": [
        "{device} is connected. Ready when you are.",
    ],
}

LOSS_TEMPLATES = {
    "battery": [
        "{value}% left. Every percent counts.",
        "Down to {value}%.",
        "You're at {value}%.",
    ],
    "wifi": [
        "You're offline. I'll wait with you.",
        "Connection dropped. The net will be back.",
        "WiFi went down. No rush \u2014 it happens.",
    ],
    "device": [
        "{device} disconnected. Your setup just got lighter.",
        "{device} left. It was good while it lasted.",
    ],
}

GAIN_TEMPLATES = {
    "battery": [
        "Climbing \u2014 {value}% now. {gained}% recovered.",
        "Charging at {value}%. On track to full.",
        "Juice coming back. {value}% and rising.",
    ],
    "brightness": [
        "Brightness at {value}%. Looks good.",
        "Screen at {value}%. Easy on the eyes.",
    ],
    "wifi": [
        "You're back on {ssid}. Welcome back.",
        "Reconnected to {ssid}. You're online again.",
    ],
}

SCARCITY_TEMPLATES = {
    "battery": [
        "Under {threshold}% \u2014 that's reserve territory.",
        "Single-digit battery. Every action costs.",
        "{value}% left. You're in the red zone.",
    ],
}

GOAL_GRADIENT_TEMPLATES = {
    "battery_charge": [
        "{value}% \u2014 {remaining}% to full. Almost there.",
        "Charging: {value}%. The home stretch starts at 80%.",
        "{value}%. Getting closer to full.",
    ],
    "battery_drain": [
        "{value}% \u2014 you've used {used}% since last charge.",
    ],
}

ANCHOR_TEMPLATES = {
    "volume": [
        "{value}% (was {previous}%)",
        "Volume: {value}% from {previous}%",
        "{previous}% \u2192 {value}%",
    ],
    "brightness": [
        "{value}% (was {previous}%)",
        "Brightness: {value}% from {previous}%",
        "{previous}% \u2192 {value}%",
    ],
}

SOCIAL_PROOF_TEMPLATES = {
    "package": [
        "Most users update within 48 hours. You have {count} pending.",
        "Regular maintainers check daily. You have {count}.",
        "Fellow users updated. {count} left on your machine.",
    ],
}

AUTONOMY_TEMPLATES = {
    "battery": [
        "At {value}%. Plug in when it makes sense.",
        "Battery at {value}%. Your call \u2014 no pressure.",
        "{value}%. You decide when to charge.",
    ],
    "package": [
        "{count} updates available. Your schedule, your choice.",
        "Update at your own pace. {count} waiting.",
    ],
    "volume": [
        "{value}%. Set it where you want it.",
        "Volume at {value}%. You're in control.",
    ],
    "brightness": [
        "{value}%. However you like it.",
        "Brightness at {value}%. Your eyes decide.",
    ],
}

RECIPROCITY_TEMPLATES = {
    "battery": [
        "I'll keep watching it. Currently {value}%.",
        "Eyes on the battery. It's at {value}%.",
    ],
    "wifi": [
        "I'll let you know when you're back online.",
        "I'll keep scanning for networks.",
    ],
    "device": [
        "I saw {device} leave. I'll be here when it's back.",
    ],
}

VARIABLE_REWARDS_POOL = {
    "media": [
        "Now playing: {title} \u2014 {artist}",
        "{title} by {artist}",
        "\u266a {title} \u2014 {artist}",
        "Listening to {title}",
        "Track changed: {title}",
        "You're listening to {title} by {artist}",
    ],
    "weather": [
        "{desc}, {temp}°C outside.",
        "It's {desc} and {temp}°C.",
        "Looking out: {desc}, {temp}°C.",
    ],
    "mute_off": [
        "Unmuted. Volume at {value}%.",
        "Sound is back. {value}%.",
        "Audio restored at {value}%.",
        "No longer silent. {value}%.",
        "Sound returns at {value}%.",
    ],
    "mute_on": [
        "Muted. Your focus zone.",
        "Silenced. {value}% was the last level.",
        "Audio off. Quiet mode engaged.",
        "Sound off. Peace achieved.",
    ],
}

REASSURANCE_TEMPLATES = {
    "wifi": [
        "Connected to {ssid}. Link is stable.",
        "{ssid} \u2014 you're online and solid.",
        "Network: {ssid}. All clear.",
        "{ssid} locked. You're good.",
    ],
    "device": [
        "{device} ready. Good to go.",
        "{device} detected and recognized.",
    ],
}

WELCOME_TEMPLATES = {
    "device": [
        "{device} joined your setup.",
        "{device} connected.",
        "Hey there, {device}.",
        "{device} is in the house.",
    ],
}


class MessageFramer:
    def __init__(self, personality: PersonalityProfile):
        self.personality = personality

    def _pick(self, pool: list[str], period: Period | None = None) -> str:
        return self.personality.pick(pool, period)

    def _format(self, template: str, **kwargs) -> str:
        try:
            return template.format(**kwargs)
        except KeyError:
            return template

    def _domain(self, raw: str) -> str:
        return DOMAIN_NORMALIZE.sub("", raw)

    def _match(self, pool: dict, raw_domain: str, period: Period | None, **kw) -> str | None:
        d = self._domain(raw_domain)
        templates = pool.get(d) or pool.get(raw_domain)
        if not templates:
            return None
        tpl = self._pick(templates, period)
        return self._format(tpl, **kw)

    def ikea(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(IKEA_TEMPLATES, domain, period, **kw)

    def companion(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(COMPANION_TEMPLATES, domain, period, **kw)

    def zeigarnik(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(ZEIGARNIK_TEMPLATES, domain, period, **kw)

    def ikea_identity(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(IKEA_IDENTITY_TEMPLATES, domain, period, **kw)

    def loss(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(LOSS_TEMPLATES, domain, period, **kw)

    def gain(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(GAIN_TEMPLATES, domain, period, **kw)

    def scarcity(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(SCARCITY_TEMPLATES, domain, period, **kw)

    def identity(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(IDENTITY_TEMPLATES, domain, period, **kw)

    def goal_gradient(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(GOAL_GRADIENT_TEMPLATES, domain, period, **kw)

    def anchor(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(ANCHOR_TEMPLATES, domain, period, **kw)

    def social_proof(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(SOCIAL_PROOF_TEMPLATES, domain, period, **kw)

    def autonomy(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(AUTONOMY_TEMPLATES, domain, period, **kw)

    def reciprocity(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(RECIPROCITY_TEMPLATES, domain, period, **kw)

    def variable_reward(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(VARIABLE_REWARDS_POOL, domain, period, **kw)

    def reassurance(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(REASSURANCE_TEMPLATES, domain, period, **kw)

    def welcome(self, domain: str, period: Period | None, **kw) -> str | None:
        return self._match(WELCOME_TEMPLATES, domain, period, **kw)

    def strategy_chain(self, domain: str, strategies: list[str], period: Period | None = None, **kw) -> str:
        for s in strategies:
            fn = getattr(self, s, None)
            if fn:
                result = fn(domain, period, **kw)
                if result:
                    return result
        return kw.get("fallback", "")