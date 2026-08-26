from __future__ import annotations
import json
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any

from ...ports.store import StorePort


class FsStore(StorePort):
    def __init__(self, base: Path | str | None = None) -> None:
        self._base = Path(base) if base else Path.home() / ".local" / "state" / "blacknode"
        self._base.mkdir(parents=True, exist_ok=True)

    def _path(self, key: str) -> Path:
        safe = key.replace("/", "_").replace(".", "_")
        return self._base / f"{safe}.json"

    def get(self, key: str, default: Any = None) -> Any:
        p = self._path(key)
        if not p.exists():
            return default
        try:
            return json.loads(p.read_text())
        except (json.JSONDecodeError, OSError):
            return default

    def put(self, key: str, value: Any) -> None:
        self._path(key).write_text(json.dumps(value, indent=2, default=str))

    def delete(self, key: str) -> None:
        p = self._path(key)
        if p.exists():
            p.unlink()

    def keys(self) -> list[str]:
        return [p.stem for p in self._base.glob("*.json")]

    def snapshot(self, label: str) -> Path:
        snap_dir = self._base / "backups" / datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        snap_dir.mkdir(parents=True, exist_ok=True)
        for f in self._base.glob("*.json"):
            shutil.copy2(f, snap_dir / f.name)
        (snap_dir / "label.txt").write_text(label)
        return snap_dir

    def restore(self, snapshot_id: str) -> bool:
        snap = self._base / "backups" / snapshot_id
        if not snap.exists():
            return False
        for f in snap.glob("*.json"):
            shutil.copy2(f, self._base / f.name)
        return True
