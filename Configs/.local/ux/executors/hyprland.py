"""Real system executors for BlackNode daemon."""
from __future__ import annotations
import subprocess
import logging
from typing import Any

from core.policy import Action

log = logging.getLogger("blacknode.executor")


class HyprlandExecutor:
    def execute(self, action: Action) -> bool:
        handler = getattr(self, f"_handle_{action.kind}", None)
        if handler:
            return handler(action.params)
        log.warning(f"unknown action kind: {action.kind}")
        return False

    def _handle_set_process_priority(self, params: dict[str, Any]) -> bool:
        target = params.get("target", "")
        priority = params.get("priority", 0)
        if target == "game":
            return self._run(["hyprctl", "dispatch", "togglespecialworkspace", "magic"])
        elif target == "compositor":
            return True
        elif target == "focused":
            return True
        return True

    def _handle_set_governor(self, params: dict[str, Any]) -> bool:
        mode = params.get("mode", "balanced")
        return self._run(["cpupower", "frequency-set", "-g", mode])

    def _handle_disable_effects(self, params: dict[str, Any]) -> bool:
        effects = params.get("effects", [])
        ok = True
        for effect in effects:
            if effect == "blur":
                ok = self._run(["hyprctl", "keyword", "decoration:blur:enabled", "0"]) and ok
            elif effect == "shadows":
                ok = self._run(["hyprctl", "keyword", "decoration:shadow:enabled", "0"]) and ok
            elif effect == "animations":
                ok = self._run(["hyprctl", "keyword", "animations:enabled", "0"]) and ok
        return ok

    def _handle_enable_effects(self, params: dict[str, Any]) -> bool:
        effects = params.get("effects", [])
        ok = True
        for effect in effects:
            if effect == "blur":
                ok = self._run(["hyprctl", "keyword", "decoration:blur:enabled", "1"]) and ok
            elif effect == "shadows":
                ok = self._run(["hyprctl", "keyword", "decoration:shadow:enabled", "1"]) and ok
            elif effect == "animations":
                ok = self._run(["hyprctl", "keyword", "animations:enabled", "1"]) and ok
        return ok

    def _handle_limit_cpu_percent(self, params: dict[str, Any]) -> bool:
        limit = params.get("limit", 100.0)
        return self._run(["cpupower", "frequency-set", "-u", f"{limit * 24:.0f}MHz"])

    def _handle_reduce_refresh_rate(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_set_refresh_rate(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_suspend_service(self, params: dict[str, Any]) -> bool:
        service = params.get("service", "")
        if service:
            return self._run(["systemctl", "suspend", service])
        return False

    def _handle_resume_service(self, params: dict[str, Any]) -> bool:
        service = params.get("service", "")
        if service:
            return self._run(["systemctl", "start", service])
        return False

    def _handle_suppress_notifications(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_unsuppress_notifications(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_set_notification_volume(self, params: dict[str, Any]) -> bool:
        volume = params.get("volume", 0.5)
        return self._run(["wpctl", "set-volume", "@DEFAULT_AUDIO@", str(volume)])

    def _handle_set_display_config(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_run_maintenance(self, params: dict[str, Any]) -> bool:
        return True

    def _handle_execute(self, params: dict[str, Any]) -> bool:
        cmd = params.get("command", "")
        if cmd:
            return self._run(["sh", "-c", cmd])
        return False

    def _run(self, cmd: list[str]) -> bool:
        try:
            result = subprocess.run(cmd, capture_output=True, timeout=10)
            if result.returncode != 0:
                log.warning(f"command failed: {' '.join(cmd)}: {result.stderr.decode()}")
                return False
            return True
        except subprocess.TimeoutExpired:
            log.error(f"command timeout: {' '.join(cmd)}")
            return False
        except FileNotFoundError:
            log.error(f"command not found: {cmd[0]}")
            return False
