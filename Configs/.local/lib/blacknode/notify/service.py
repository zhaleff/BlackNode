from __future__ import annotations

import logging

from ..psyche.core import PsychEngine
from .context import NotificationContext
from .engine import NotifEngine
from . import registry

log = logging.getLogger("blacknode.notify")


class NotificationService:
    def __init__(self, psyche: PsychEngine | None = None, notifier: NotifEngine | None = None):
        self.psyche = psyche or PsychEngine()
        self.notifier = notifier or NotifEngine()

    def context(self, domain: str, **data) -> NotificationContext:
        return NotificationContext(self.psyche, domain, data)

    def send(self, envelope) -> bool:
        return self.notifier.send(envelope)

    def notify(self, domain: str, **data) -> bool:
        handle = registry.get_handle(domain)
        if handle is None:
            log.error("no handler for domain %r", domain)
            return False
        try:
            envelope = handle(self.context(domain, **data))
        except Exception:
            log.exception("plugin %r crashed", domain)
            return False
        if envelope is None:
            return True
        return self.send(envelope)
