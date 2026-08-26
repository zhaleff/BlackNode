from __future__ import annotations
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any


class StorePort(ABC):
    @abstractmethod
    def get(self, key: str, default: Any = None) -> Any: ...

    @abstractmethod
    def put(self, key: str, value: Any) -> None: ...

    @abstractmethod
    def delete(self, key: str) -> None: ...

    @abstractmethod
    def keys(self) -> list[str]: ...

    @abstractmethod
    def snapshot(self, label: str) -> Path: ...

    @abstractmethod
    def restore(self, snapshot_id: str) -> bool: ...
