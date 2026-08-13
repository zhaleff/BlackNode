from __future__ import annotations

import importlib
import logging
from pathlib import Path

log = logging.getLogger("blacknode.notify")

PACKAGE = "blacknode.notify.plugins"
_PLUGINS_DIR = Path(__file__).resolve().parent / "plugins"
_loaded: dict[str, object] = {}


def _load(domain: str) -> object | None:
    if domain in _loaded:
        return _loaded[domain]
    try:
        module = importlib.import_module(f"{PACKAGE}.{domain}")
    except Exception as exc:
        log.error("plugin %r failed to load: %s", domain, exc)
        return None
    _loaded[domain] = module
    return module


def get_handle(domain: str):
    module = _load(domain)
    if module is None:
        return None
    handle = getattr(module, "handle", None)
    return handle if callable(handle) else None


def get_runner(domain: str):
    module = _load(domain)
    if module is None:
        return None
    run = getattr(module, "run", None)
    return run if callable(run) else None


def list_domains() -> list[str]:
    return sorted(
        path.stem for path in _PLUGINS_DIR.glob("*.py") if path.stem != "__init__"
    )
