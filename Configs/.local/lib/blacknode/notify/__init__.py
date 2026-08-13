from .engine import NotifEngine
from .envelope import NotificationEnvelope
from .context import NotificationContext
from . import registry

__all__ = [
    "NotifEngine",
    "NotificationEnvelope",
    "NotificationContext",
    "NotificationService",
    "registry",
]


def __getattr__(name: str):
    if name == "NotificationService":
        from .service import NotificationService
        return NotificationService
    raise AttributeError(name)
