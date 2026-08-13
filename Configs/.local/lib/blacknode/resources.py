from __future__ import annotations

import json
import sys
from pathlib import Path

ASSETS = Path.home() / ".config" / "dunst" / "assets"
SRC_DIR = ASSETS / "src"
FIXED_DIR = ASSETS / "fixed"
CACHE_DIR = Path("/tmp") / "blacknode-icons"
THEME_FILE = Path.home() / ".local" / "share" / "blacknode" / "theme_mode"
MATUGEN_ICONS = Path.home() / ".cache" / "matugen" / "icons.json"
DUNST_CONFIG = Path.home() / ".config" / "dunst" / "dunstrc"
DEFAULT_THEME = "dark"
VALID_THEMES = {"dark", "light"}
FALLBACK_FILLS = {"dark": "#ffffff", "light": "#1c274c"}
TOKEN = "{{fill}}"

_theme: str = DEFAULT_THEME
_theme_mtime: float = -1.0
_fill: str | None = None
_fill_mtime: float = -1.0


def current_theme() -> str:
    global _theme, _theme_mtime
    try:
        mtime = THEME_FILE.stat().st_mtime
        if mtime != _theme_mtime:
            _theme_mtime = mtime
            _theme = THEME_FILE.read_text(encoding="utf-8").strip().lower() or DEFAULT_THEME
        return _theme
    except OSError:
        return DEFAULT_THEME


def _matugen_fill() -> str | None:
    global _fill, _fill_mtime
    try:
        mtime = MATUGEN_ICONS.stat().st_mtime
        if mtime != _fill_mtime:
            _fill_mtime = mtime
            data = json.loads(MATUGEN_ICONS.read_text(encoding="utf-8"))
            _fill = data.get("on_surface")
        return _fill
    except OSError:
        return None
    except (json.JSONDecodeError, AttributeError):
        return None


def _dunst_fill() -> str | None:
    try:
        for line in DUNST_CONFIG.read_text(encoding="utf-8").splitlines():
            if line.strip().startswith("foreground"):
                import re

                m = re.search(r"#([0-9a-fA-F]{6})", line)
                if m:
                    return "#" + m.group(1)
        return None
    except OSError:
        return None


def _fill(theme: str) -> str:
    return _matugen_fill() or _dunst_fill() or FALLBACK_FILLS.get(theme, FALLBACK_FILLS[DEFAULT_THEME])


def _render(name: str, theme: str) -> str | None:
    src = SRC_DIR / f"{name}.svg"
    if not src.exists():
        return None
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    color = _fill(theme)
    tag = color.lstrip("#").lower()
    out = CACHE_DIR / f"{name}-{tag}.svg"
    if not out.exists():
        out.write_text(src.read_text(encoding="utf-8").replace(TOKEN, color), encoding="utf-8")
    return str(out)


def icon(name: str, theme: str | None = None) -> str:
    theme = (theme or current_theme()).lower()
    theme = theme if theme in VALID_THEMES else DEFAULT_THEME
    for ext in ("svg", "png"):
        f = FIXED_DIR / f"{name}.{ext}"
        if f.exists():
            return str(f)
    return _render(name, theme) or ""


def resolve(*names: str, theme: str | None = None) -> str:
    for name in names:
        found = icon(name, theme)
        if found:
            return found
    return ""


def main(argv: list[str] | None = None) -> None:
    args = list(argv if argv is not None else sys.argv[1:])
    if not args:
        raise SystemExit("uso: python -m blacknode.resources <icono>... [dark|light]")
    if args[-1].lower() in VALID_THEMES:
        theme = args.pop().lower()
    else:
        theme = current_theme()
    for name in args:
        print(icon(name, theme))


if __name__ == "__main__":
    main()