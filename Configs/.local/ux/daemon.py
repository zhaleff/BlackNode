#!/usr/bin/env python3
"""BlackNode UX Daemon — real-time adaptive system layer."""
from __future__ import annotations
import sys
import os
import signal
import time
import logging
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core.engine import UXEngine
from core.events import Event, EventKind
from core.plan import PlanBuilder, PlanStatus
from core.permission import PolicyDecision
from sensors.real import (
    PowerSensor, ThermalSensor, ResourceSensor,
    ApplicationSensor, DisplaySensor, NetworkSensor,
    InputSensor, TickSensor,
)
from executors.hyprland import HyprlandExecutor

LOG_DIR = Path.home() / ".local" / "state" / "blacknode"
LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
    handlers=[
        logging.FileHandler(LOG_DIR / "daemon.log"),
        logging.StreamHandler(),
    ],
)
log = logging.getLogger("blacknode.daemon")

running = True


def handle_signal(sig: int, frame: object) -> None:
    global running
    log.info(f"signal {sig} received, shutting down")
    running = False


signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)


class Daemon:
    def __init__(self) -> None:
        self.engine = UXEngine(debug="--debug" in sys.argv)
        self.executor = HyprlandExecutor()
        self.engine.executor.register_executor("default", self.executor)

        self.sensors = [
            PowerSensor(),
            ThermalSensor(),
            ResourceSensor(),
            ApplicationSensor(),
            DisplaySensor(),
            NetworkSensor(),
            InputSensor(),
            TickSensor(interval=10.0),
        ]

        self._last_poll: dict[int, float] = {}
        self._poll_intervals: dict[int, float] = {
            0: 30.0,   # PowerSensor: 30s
            1: 10.0,   # ThermalSensor: 10s
            2: 5.0,    # ResourceSensor: 5s
            3: 2.0,    # ApplicationSensor: 2s
            4: 30.0,   # DisplaySensor: 30s
            5: 15.0,   # NetworkSensor: 15s
            6: 30.0,   # InputSensor: 30s
            7: 10.0,   # TickSensor: 10s
        }

    def run(self) -> None:
        log.info("BlackNode daemon starting")
        self.engine.boot()
        log.info(f"boot complete, state={self.engine.state.current.name}")

        while running:
            self._poll_sensors()
            time.sleep(1)

        log.info("daemon stopped")

    def _poll_sensors(self) -> None:
        now = time.time()
        for i, sensor in enumerate(self.sensors):
            last = self._last_poll.get(i, 0)
            interval = self._poll_intervals.get(i, 10.0)
            if now - last < interval:
                continue

            self._last_poll[i] = now
            try:
                result = sensor.poll()
                for event in result.events:
                    self.engine.emit(event)
            except Exception as e:
                log.error(f"sensor {sensor.__class__.__name__} error: {e}")


def cmd_start(args: list[str]) -> None:
    daemon = Daemon()
    daemon.run()


def cmd_status(args: list[str]) -> None:
    from core.engine import UXEngine
    e = UXEngine()
    print(json.dumps(e.status(), indent=2))


def cmd_test(args: list[str]) -> None:
    from sensors.real import (
        PowerSensor, ThermalSensor, ResourceSensor,
        ApplicationSensor, DisplaySensor, NetworkSensor,
    )
    sensors = {
        "power": PowerSensor(),
        "thermal": ThermalSensor(),
        "resources": ResourceSensor(),
        "applications": ApplicationSensor(),
        "display": DisplaySensor(),
        "network": NetworkSensor(),
    }

    if args and args[0] in sensors:
        names = [args[0]]
    else:
        names = list(sensors.keys())

    for name in names:
        sensor = sensors[name]
        result = sensor.poll()
        print(f"\n=== {name} sensor ===")
        for event in result.events:
            safe_payload = {}
            for k, v in event.payload.items():
                if hasattr(v, "name"):
                    safe_payload[k] = v.name
                else:
                    safe_payload[k] = v
            print(f"  {event.kind.name}: {json.dumps(safe_payload, indent=4)}")
        if not result.events:
            print("  (no events)")


COMMANDS = {
    "start": cmd_start,
    "status": cmd_status,
    "test": cmd_test,
}


def main() -> None:
    args = sys.argv[1:]
    if not args or args[0] not in COMMANDS:
        print("usage: blacknode-ux-daemon <start|status|test> [args]")
        print(f"commands: {', '.join(COMMANDS)}")
        sys.exit(1)

    COMMANDS[args[0]](args[1:])


if __name__ == "__main__":
    main()
