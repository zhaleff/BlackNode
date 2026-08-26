from __future__ import annotations
import time
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any

from .events import Event, EventKind, PowerState, ThermalState


class Trend(Enum):
    RISING = auto()
    STABLE = auto()
    FALLING = auto()


class PressureLevel(Enum):
    NONE = auto()
    LOW = auto()
    MEDIUM = auto()
    HIGH = auto()
    CRITICAL = auto()


class AppClass(Enum):
    BROWSER = "BROWSER"
    EDITOR = "EDITOR"
    IDE = "IDE"
    MEDIA = "MEDIA"
    GAME = "GAME"
    GRAPHICS = "GRAPHICS"
    OFFICE = "OFFICE"
    COMMUNICATION = "COMMUNICATION"
    SYSTEM = "SYSTEM"
    UNKNOWN = "UNKNOWN"


class SessionMode(Enum):
    DESKTOP = auto()
    DOCKED = auto()
    HEADLESS = auto()
    PRESENTATION = auto()


@dataclass
class ResourceMetrics:
    used_percent: float = 0.0
    rate_of_change: float = 0.0
    trend: Trend = Trend.STABLE
    pressure: PressureLevel = PressureLevel.NONE

    def update(self, new_value: float) -> None:
        old = self.used_percent
        self.used_percent = new_value
        self.rate_of_change = new_value - old
        if abs(self.rate_of_change) < 1.0:
            self.trend = Trend.STABLE
        elif self.rate_of_change > 0:
            self.trend = Trend.RISING
        else:
            self.trend = Trend.FALLING

        if new_value < 50:
            self.pressure = PressureLevel.NONE
        elif new_value < 70:
            self.pressure = PressureLevel.LOW
        elif new_value < 85:
            self.pressure = PressureLevel.MEDIUM
        elif new_value < 95:
            self.pressure = PressureLevel.HIGH
        else:
            self.pressure = PressureLevel.CRITICAL


@dataclass
class Display:
    id: str = ""
    name: str = ""
    width: int = 0
    height: int = 0
    refresh_rate: int = 60
    connected: bool = False
    primary: bool = False


@dataclass
class AppInstance:
    id: int = 0
    name: str = ""
    app_class: AppClass = AppClass.UNKNOWN
    cpu_percent: float = 0.0
    memory_mb: int = 0
    gpu_percent: float | None = None
    focused: bool = False
    fullscreen: bool = False
    started_at: float = field(default_factory=time.time)


@dataclass
class DeviceInfo:
    id: str = ""
    name: str = ""
    kind: str = ""  # "usb", "bluetooth", "display", "input"
    connected: bool = False


@dataclass
class WorldModel:
    timestamp: float = field(default_factory=time.time)

    power_state: PowerState = PowerState.UNKNOWN
    battery_percent: float | None = None
    battery_time_remaining: float | None = None
    thermal_state: ThermalState = ThermalState.NORMAL

    cpu: ResourceMetrics = field(default_factory=ResourceMetrics)
    memory: ResourceMetrics = field(default_factory=ResourceMetrics)
    disk: ResourceMetrics = field(default_factory=ResourceMetrics)
    gpu: ResourceMetrics = field(default_factory=ResourceMetrics)

    displays: list[Display] = field(default_factory=list)
    input_devices: list[DeviceInfo] = field(default_factory=list)
    applications: list[AppInstance] = field(default_factory=list)
    focused_app: AppInstance | None = None
    fullscreen_active: bool = False
    gaming_detected: bool = False

    network_connected: bool = False
    network_interface: str = ""
    network_ssid: str = ""
    network_metered: bool = False
    vpn_active: bool = False

    session_mode: SessionMode = SessionMode.DESKTOP
    display_count: int = 1

    idle: bool = False
    idle_duration: float = 0.0
    last_user_action: float = field(default_factory=time.time)

    store: dict[str, Any] = field(default_factory=dict)

    def get(self, key: str, default: Any = None) -> Any:
        return self.store.get(key, default)

    def put(self, key: str, value: Any) -> None:
        self.store[key] = value

    def update_from_event(self, event: Event) -> None:
        self.timestamp = time.time()
        p = event.payload

        if event.kind == EventKind.POWER_STATE_CHANGED:
            raw_state = p.get("state")
            if raw_state is not None:
                if isinstance(raw_state, PowerState):
                    self.power_state = raw_state
                elif isinstance(raw_state, int):
                    self.power_state = PowerState(raw_state)
                elif isinstance(raw_state, str):
                    self.power_state = PowerState[raw_state]
            if "percent" in p:
                self.battery_percent = p["percent"]
            if "time_remaining" in p:
                self.battery_time_remaining = p["time_remaining"]

        elif event.kind == EventKind.THERMAL_STATE_CHANGED:
            raw_state = p.get("state")
            if raw_state is not None:
                if isinstance(raw_state, ThermalState):
                    self.thermal_state = raw_state
                elif isinstance(raw_state, int):
                    self.thermal_state = ThermalState(raw_state)
                elif isinstance(raw_state, str):
                    self.thermal_state = ThermalState[raw_state]

        elif event.kind == EventKind.RESOURCE_USAGE_CHANGED:
            resource = p.get("resource", "")
            value = p.get("value", 0.0)
            if resource == "cpu":
                self.cpu.update(value)
            elif resource == "memory":
                self.memory.update(value)
            elif resource == "disk":
                self.disk.update(value)
            elif resource == "gpu":
                self.gpu.update(value)

        elif event.kind == EventKind.DEVICE_CONNECTED:
            device = DeviceInfo(
                id=p.get("id", ""),
                name=p.get("name", ""),
                kind=p.get("kind", ""),
                connected=True,
            )
            self.input_devices.append(device)
            self._detect_session_mode()

        elif event.kind == EventKind.DEVICE_DISCONNECTED:
            device_id = p.get("id", "")
            self.input_devices = [d for d in self.input_devices if d.id != device_id]
            self._detect_session_mode()

        elif event.kind == EventKind.APPLICATION_STARTED:
            app = AppInstance(
                id=p.get("pid", 0),
                name=p.get("name", ""),
                app_class=AppClass(p.get("class", "UNKNOWN")),
                focused=p.get("focused", False),
                fullscreen=p.get("fullscreen", False),
            )
            self.applications.append(app)
            if app.focused:
                self.focused_app = app
            self._update_gaming_detection()

        elif event.kind == EventKind.APPLICATION_CLOSED:
            pid = p.get("pid", 0)
            self.applications = [a for a in self.applications if a.id != pid]
            if self.focused_app and self.focused_app.id == pid:
                self.focused_app = None
            self._update_gaming_detection()

        elif event.kind == EventKind.APPLICATION_STATE_CHANGED:
            pid = p.get("pid", 0)
            for app in self.applications:
                if app.id == pid:
                    if "focused" in p:
                        app.focused = p["focused"]
                        if app.focused:
                            self.focused_app = app
                    if "fullscreen" in p:
                        app.fullscreen = p["fullscreen"]
                    if "cpu_percent" in p:
                        app.cpu_percent = p["cpu_percent"]
                    if "memory_mb" in p:
                        app.memory_mb = p["memory_mb"]
            self._update_gaming_detection()

        elif event.kind == EventKind.NETWORK_STATE_CHANGED:
            self.network_connected = p.get("connected", False)
            self.network_interface = p.get("interface", "")
            self.network_ssid = p.get("ssid", "")
            self.network_metered = p.get("metered", False)
            self.vpn_active = p.get("vpn", False)

        elif event.kind == EventKind.TIME_TICK:
            self.idle_duration = p.get("idle_duration", 0.0)
            self.idle = self.idle_duration > 300

    def _update_gaming_detection(self) -> None:
        has_game = any(a.app_class == AppClass.GAME for a in self.applications)
        high_gpu = self.gpu.used_percent > 80
        fullscreen_game = any(
            a.app_class == AppClass.GAME and a.fullscreen for a in self.applications
        )
        self.gaming_detected = has_game and (high_gpu or fullscreen_game)
        self.fullscreen_active = any(a.fullscreen for a in self.applications)

    def _detect_session_mode(self) -> None:
        display_count = sum(1 for d in self.input_devices if d.kind == "display")
        input_count = sum(1 for d in self.input_devices if d.kind == "input")
        self.display_count = max(display_count, 1)

        if display_count > 1 and input_count >= 2:
            self.session_mode = SessionMode.DOCKED
        elif display_count == 0:
            self.session_mode = SessionMode.HEADLESS
        else:
            self.session_mode = SessionMode.DESKTOP

    def snapshot(self) -> dict[str, Any]:
        return {
            "timestamp": self.timestamp,
            "power": {
                "state": self.power_state.name,
                "battery": self.battery_percent,
            },
            "thermal": self.thermal_state.name,
            "resources": {
                "cpu": self.cpu.used_percent,
                "memory": self.memory.used_percent,
                "gpu": self.gpu.used_percent,
            },
            "session_mode": self.session_mode.name,
            "display_count": self.display_count,
            "focused_app": self.focused_app.name if self.focused_app else None,
            "gaming_detected": self.gaming_detected,
            "idle": self.idle,
            "network": {
                "connected": self.network_connected,
                "metered": self.network_metered,
                "vpn": self.vpn_active,
            },
        }
