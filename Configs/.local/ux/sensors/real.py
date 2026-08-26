"""Real system sensors for BlackNode daemon."""
from __future__ import annotations
import os
import time
import subprocess
import json
from dataclasses import dataclass
from typing import Any

from core.events import Event, EventKind, PowerState, ThermalState
from core.context import AppClass


@dataclass
class SensorResult:
    events: list[Event]
    context_updates: dict[str, Any]


class PowerSensor:
    def __init__(self) -> None:
        self._last_percent: float | None = None
        self._last_state: str | None = None

    def poll(self) -> SensorResult:
        events: list[Event] = []
        updates: dict[str, Any] = {}

        status = self._read_file("/sys/class/power_supply/BAT0/status")
        capacity = self._read_file("/sys/class/power_supply/BAT0/capacity")

        if status and capacity:
            try:
                pct = float(capacity)
                state = PowerState.BATTERY if status.strip() == "Discharging" else PowerState.AC

                if state != self._last_state or abs(pct - (self._last_percent or 0)) >= 1:
                    events.append(Event(
                        kind=EventKind.POWER_STATE_CHANGED,
                        payload={"state": state, "percent": pct},
                        source="power_sensor",
                    ))
                    self._last_percent = pct
                    self._last_state = status.strip()
            except (ValueError, TypeError):
                pass

        elif self._read_file("/sys/class/power_supply/AC/online"):
            if self._last_state != "AC":
                events.append(Event(
                    kind=EventKind.POWER_STATE_CHANGED,
                    payload={"state": PowerState.AC, "percent": None},
                    source="power_sensor",
                ))
                self._last_state = "AC"

        return SensorResult(events=events, context_updates=updates)

    def _read_file(self, path: str) -> str | None:
        try:
            with open(path) as f:
                return f.read().strip()
        except (FileNotFoundError, PermissionError):
            return None


class ThermalSensor:
    def __init__(self) -> None:
        self._last_state: ThermalState | None = None

    def poll(self) -> SensorResult:
        events: list[Event] = []
        temp = self._read_thermal()
        if temp is None:
            return SensorResult(events=[], context_updates={})

        if temp < 50:
            state = ThermalState.NORMAL
        elif temp < 70:
            state = ThermalState.WARM
        elif temp < 85:
            state = ThermalState.HOT
        else:
            state = ThermalState.CRITICAL

        if state != self._last_state:
            events.append(Event(
                kind=EventKind.THERMAL_STATE_CHANGED,
                payload={"state": state, "temp_celsius": temp},
                source="thermal_sensor",
            ))
            self._last_state = state

        return SensorResult(events=events, context_updates={})

    def _read_thermal(self) -> float | None:
        try:
            zones = sorted([
                d for d in os.listdir("/sys/class/thermal/")
                if d.startswith("thermal_zone")
            ])
            max_temp = 0.0
            for zone in zones:
                path = f"/sys/class/thermal/{zone}/temp"
                try:
                    with open(path) as f:
                        t = float(f.read().strip()) / 1000
                        max_temp = max(max_temp, t)
                except (ValueError, FileNotFoundError):
                    continue
            return max_temp if max_temp > 0 else None
        except (FileNotFoundError, PermissionError):
            return None


class ResourceSensor:
    def __init__(self) -> None:
        self._prev_cpu: dict[str, float] = {}
        self._prev_time: float = 0

    def poll(self) -> SensorResult:
        events: list[Event] = []
        updates: dict[str, Any] = {}

        cpu = self._read_cpu()
        mem = self._read_memory()
        gpu = self._read_gpu()

        if cpu is not None:
            events.append(Event(
                kind=EventKind.RESOURCE_USAGE_CHANGED,
                payload={"resource": "cpu", "value": cpu},
                source="resource_sensor",
            ))

        if mem is not None:
            events.append(Event(
                kind=EventKind.RESOURCE_USAGE_CHANGED,
                payload={"resource": "memory", "value": mem},
                source="resource_sensor",
            ))

        if gpu is not None:
            events.append(Event(
                kind=EventKind.RESOURCE_USAGE_CHANGED,
                payload={"resource": "gpu", "value": gpu},
                source="resource_sensor",
            ))

        return SensorResult(events=events, context_updates=updates)

    def _read_cpu(self) -> float | None:
        try:
            with open("/proc/stat") as f:
                line = f.readline()
            parts = line.split()
            idle = float(parts[4])
            total = sum(float(p) for p in parts[1:])
            idle_delta = idle - self._prev_cpu.get("idle", idle)
            total_delta = total - self._prev_cpu.get("total", total)
            self._prev_cpu = {"idle": idle, "total": total}

            if total_delta == 0:
                return None
            return max(0, min(100, (1 - idle_delta / total_delta) * 100))
        except (FileNotFoundError, ValueError, IndexError):
            return None

    def _read_memory(self) -> float | None:
        try:
            with open("/proc/meminfo") as f:
                lines = f.readlines()
            info = {}
            for line in lines:
                parts = line.split()
                if parts[0] in ("MemTotal:", "MemAvailable:"):
                    info[parts[0]] = int(parts[1])
            total = info.get("MemTotal:", 0)
            available = info.get("MemAvailable:", 0)
            if total > 0:
                return round((1 - available / total) * 100, 1)
        except (FileNotFoundError, ValueError, IndexError):
            pass
        return None

    def _read_gpu(self) -> float | None:
        try:
            result = subprocess.run(
                ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0:
                return float(result.stdout.strip())
        except (FileNotFoundError, subprocess.TimeoutExpired, ValueError):
            pass
        return None


class ApplicationSensor:
    def __init__(self) -> None:
        self._known_pids: set[int] = set()

    def poll(self) -> SensorResult:
        events: list[Event] = []
        updates: dict[str, Any] = {}

        try:
            result = subprocess.run(
                ["hyprctl", "clients", "-j"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode != 0:
                return SensorResult(events=[], context_updates={})

            clients = json.loads(result.stdout)
            current_pids = set()

            for client in clients:
                pid = client.get("pid", 0)
                if pid == 0:
                    continue
                current_pids.add(pid)

                app_class = self._classify(client.get("class", ""))
                focused = client.get("address", "") == self._get_focused_address()

                if pid not in self._known_pids:
                    events.append(Event(
                        kind=EventKind.APPLICATION_STARTED,
                        payload={
                            "pid": pid,
                            "name": client.get("class", "unknown"),
                            "class": app_class,
                            "focused": focused,
                            "fullscreen": client.get("fullscreen", 0) > 0,
                        },
                        source="application_sensor",
                    ))
                else:
                    events.append(Event(
                        kind=EventKind.APPLICATION_STATE_CHANGED,
                        payload={
                            "pid": pid,
                            "focused": focused,
                            "fullscreen": client.get("fullscreen", 0) > 0,
                        },
                        source="application_sensor",
                    ))

            closed = self._known_pids - current_pids
            for pid in closed:
                events.append(Event(
                    kind=EventKind.APPLICATION_CLOSED,
                    payload={"pid": pid},
                    source="application_sensor",
                ))

            self._known_pids = current_pids

        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            pass

        return SensorResult(events=events, context_updates=updates)

    def _get_focused_address(self) -> str:
        try:
            result = subprocess.run(
                ["hyprctl", "activewindow", "-j"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0:
                data = json.loads(result.stdout)
                return data.get("address", "")
        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            pass
        return ""

    def _classify(self, window_class: str) -> str:
        lower = window_class.lower()
        browsers = {"firefox", "chromium", "google-chrome", "brave", "vivaldi", "qutebrowser"}
        editors = {"neovide", "code", "code-oss", "zed"}
        ides = {"rustrover", "idea", "pycharm", "androidstudio", "nvim", "kate"}
        games = {"steam", "lutris", "heroic", "gamescope", "minecraft", "factorio"}
        media = {"mpv", "vlc", "spotify", "rhythmbox", "celluloid"}
        graphics = {"blender", "gimp", "inkscape", "krita", "kdenlive", "obsidian"}
        office = {"onlyoffice", "libreoffice", "thunderbird"}
        comm = {"discord", "telegram", "signal", "slack", "zoom"}

        if lower in browsers:
            return "BROWSER"
        if lower in editors:
            return "EDITOR"
        if lower in ides:
            return "IDE"
        if lower in games:
            return "GAME"
        if lower in media:
            return "MEDIA"
        if lower in graphics:
            return "GRAPHICS"
        if lower in office:
            return "OFFICE"
        if lower in comm:
            return "COMMUNICATION"
        return "UNKNOWN"


class DisplaySensor:
    def __init__(self) -> None:
        self._known_monitors: set[str] = set()

    def poll(self) -> SensorResult:
        events: list[Event] = []
        updates: dict[str, Any] = {}

        try:
            result = subprocess.run(
                ["hyprctl", "monitors", "-j"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode != 0:
                return SensorResult(events=[], context_updates={})

            monitors = json.loads(result.stdout)
            current = {m["name"] for m in monitors}

            connected = current - self._known_monitors
            disconnected = self._known_monitors - current

            for name in connected:
                events.append(Event(
                    kind=EventKind.DEVICE_CONNECTED,
                    payload={"id": name, "name": name, "kind": "display"},
                    source="display_sensor",
                ))

            for name in disconnected:
                events.append(Event(
                    kind=EventKind.DEVICE_DISCONNECTED,
                    payload={"id": name, "kind": "display"},
                    source="display_sensor",
                ))

            self._known_monitors = current

        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            pass

        return SensorResult(events=events, context_updates=updates)


class NetworkSensor:
    def __init__(self) -> None:
        self._last_connected: bool | None = None

    def poll(self) -> SensorResult:
        events: list[Event] = []
        updates: dict[str, Any] = {}

        try:
            result = subprocess.run(
                ["nmcli", "-t", "-f", "TYPE,STATE,NAME", "connection", "show", "--active"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode != 0:
                return SensorResult(events=[], context_updates={})

            connected = False
            interface = ""
            ssid = ""
            metered = False

            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue
                parts = line.split(":")
                if len(parts) >= 3:
                    conn_type = parts[0]
                    state = parts[1]
                    name = parts[2]
                    if state == "activated":
                        connected = True
                        if "wireless" in conn_type:
                            ssid = name
                        interface = name

            result2 = subprocess.run(
                ["nmcli", "-t", "-f", "connection.metered", "connection", "show", "id", ssid or interface],
                capture_output=True, text=True, timeout=5
            )
            if result2.returncode == 0:
                for line in result2.stdout.strip().split("\n"):
                    if "yes" in line.lower():
                        metered = True
                        break

            if connected != self._last_connected:
                events.append(Event(
                    kind=EventKind.NETWORK_STATE_CHANGED,
                    payload={
                        "connected": connected,
                        "interface": interface,
                        "ssid": ssid,
                        "metered": metered,
                    },
                    source="network_sensor",
                ))
                self._last_connected = connected

        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

        return SensorResult(events=events, context_updates=updates)


class InputSensor:
    def __init__(self) -> None:
        self._known_devices: set[str] = set()

    def poll(self) -> SensorResult:
        events: list[Event] = []

        try:
            result = subprocess.run(
                ["hyprctl", "devices", "-j"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode != 0:
                return SensorResult(events=[], context_updates={})

            data = json.loads(result.stdout)
            mics = data.get("mice", [])
            keyboards = data.get("keyboards", [])

            current: set[str] = set()
            for m in mics:
                name = m.get("name", "")
                if name:
                    current.add(f"mouse:{name}")
            for k in keyboards:
                name = k.get("name", "")
                if name:
                    current.add(f"keyboard:{name}")

            connected = current - self._known_devices
            disconnected = self._known_devices - current

            for dev in connected:
                kind, name = dev.split(":", 1)
                events.append(Event(
                    kind=EventKind.DEVICE_CONNECTED,
                    payload={"id": dev, "name": name, "kind": kind},
                    source="input_sensor",
                ))

            for dev in disconnected:
                kind, name = dev.split(":", 1)
                events.append(Event(
                    kind=EventKind.DEVICE_DISCONNECTED,
                    payload={"id": dev, "kind": kind},
                    source="input_sensor",
                ))

            self._known_devices = current

        except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
            pass

        return SensorResult(events=events, context_updates=updates)


class TickSensor:
    def __init__(self, interval: float = 10.0) -> None:
        self._interval = interval
        self._last_tick: float = 0

    def poll(self) -> SensorResult:
        now = time.time()
        if now - self._last_tick < self._interval:
            return SensorResult(events=[], context_updates={})

        self._last_tick = now
        return SensorResult(
            events=[Event(
                kind=EventKind.TIME_TICK,
                payload={"idle_duration": self._get_idle_time()},
                source="tick_sensor",
            )],
            context_updates={},
        )

    def _get_idle_time(self) -> float:
        try:
            result = subprocess.run(
                ["xprintidle"],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0:
                return float(result.stdout.strip()) / 1000
        except (subprocess.TimeoutExpired, FileNotFoundError, ValueError):
            pass
        return 0.0
