from __future__ import annotations
from dataclasses import dataclass, field


@dataclass
class NotificationEnvelope:
    title: str
    body: str
    icon: str = ""
    urgency: str = "normal"
    timeout: int = 5000
    notif_id: int = 0
    category: str = ""
    replace_id: int = 0
    hints: list[tuple[str, str | int]] = field(default_factory=list)
    app_name: str = "BlackNode"
    debug: bool = False

    def render(self) -> list[str]:
        cmd = ["dunstify", "-a", self.app_name]
        if self.urgency:
            cmd.extend(["-u", self.urgency])
        if self.timeout:
            cmd.extend(["-t", str(self.timeout)])
        if self.icon:
            cmd.extend(["-i", self.icon])
        if self.replace_id:
            cmd.extend(["-r", str(self.replace_id)])
        for hint_key, hint_val in self.hints:
            if isinstance(hint_val, int):
                cmd.extend(["-h", f"int:{hint_key}:{hint_val}"])
            else:
                cmd.extend(["-h", f"string:{hint_key}:{hint_val}"])
        cmd.append(self.title)
        cmd.append(self.body)
        return cmd
