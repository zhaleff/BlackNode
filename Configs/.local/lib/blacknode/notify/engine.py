from __future__ import annotations
import subprocess
import sys
from .envelope import NotificationEnvelope


DEFAULT_COLORS: dict[str, str] = {
    "late": "#5b6ee1",
    "dawn": "#f5a25d",
    "morning": "#ffd166",
    "noon": "#ffb703",
    "afternoon": "#fb8500",
    "evening": "#9d4edd",
    "night": "#3a0ca3",
}


class NotifEngine:
    def __init__(self, dry_run: bool = False, debug: bool = False):
        self.dry_run = dry_run
        self.debug = debug
        self._last_sent: dict[int, str] = {}

    def send(self, envelope: NotificationEnvelope) -> bool:
        cmd = envelope.render()
        if envelope.debug or self.debug:
            print(f"[bn-notify] {' '.join(cmd)}", file=sys.stderr)
        if self.dry_run:
            return True
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode != 0:
                print(
                    f"[bn-notify] dunstify error: {result.stderr.strip()}",
                    file=sys.stderr,
                )
                return False
            self._last_sent[envelope.notif_id] = envelope.body
            return True
        except FileNotFoundError:
            print(
                "[bn-notify] dunstify not found — is dunst installed?",
                file=sys.stderr,
            )
            return False
        except subprocess.TimeoutExpired:
            print("[bn-notify] dunstify timed out", file=sys.stderr)
            return False

    def progress_bar(
        self,
        value: int,
        title: str,
        *,
        icon: str = "",
        urgency: str = "normal",
        timeout: int = 2000,
        replace_id: int = 0,
        app_name: str = "BlackNode",
        body: str = "",
    ) -> NotificationEnvelope:
        hints = [("value", value)]
        return NotificationEnvelope(
            title=title,
            body=body or f"{value}%",
            icon=icon,
            urgency=urgency,
            timeout=timeout,
            replace_id=replace_id,
            notif_id=replace_id,
            hints=hints,
            app_name=app_name,
        )
