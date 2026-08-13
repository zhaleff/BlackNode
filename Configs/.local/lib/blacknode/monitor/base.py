from __future__ import annotations
import signal
import sys
import time
import traceback
from typing import Any

from ..psyche.core import PsychEngine
from ..notify.engine import NotifEngine


class BaseMonitor:
    name: str = "base"
    poll_interval: float = 5.0

    def __init__(self, engine: PsychEngine | None = None, notifier: NotifEngine | None = None):
        self.engine = engine or PsychEngine()
        self.notifier = notifier or NotifEngine()
        self._running = True
        self._previous: Any = None
        signal.signal(signal.SIGTERM, self._handle_signal)
        signal.signal(signal.SIGINT, self._handle_signal)

    def _handle_signal(self, signum: int, _frame) -> None:
        self._running = False
        print(f"[{self.name}] received signal {signum}, shutting down", file=sys.stderr)

    def setup(self) -> None:
        pass

    def poll(self) -> Any:
        raise NotImplementedError

    def changed(self, current: Any, previous: Any) -> bool:
        return current != previous

    def should_notify(self, current: Any, previous: Any) -> bool:
        return True

    def handle(self, current: Any, previous: Any) -> None:
        raise NotImplementedError

    def teardown(self) -> None:
        pass

    def run(self) -> None:
        self.setup()
        while self._running:
            try:
                current = self.poll()
                if self.changed(current, self._previous):
                    if self._previous is not None:
                        self.handle(current, self._previous)
                    self._previous = current
                time.sleep(self.poll_interval)
            except Exception as exc:
                print(
                    f"[{self.name}] error: {exc}",
                    file=sys.stderr,
                )
                if self.engine.debug:
                    traceback.print_exc(file=sys.stderr)
                time.sleep(self.poll_interval * 2)
        self.teardown()
