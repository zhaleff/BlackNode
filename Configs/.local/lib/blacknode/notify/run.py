from __future__ import annotations

import os
import sys
import signal

sys.path.insert(0, os.path.expanduser("~/.local/lib"))

from .service import NotificationService
from . import registry


def main(argv: list[str] | None = None) -> int:
    args = list(argv) if argv is not None else sys.argv[1:]
    if not args:
        print(f"domains: {', '.join(registry.list_domains())}", file=sys.stderr)
        return 2
    domain = args[0]
    runner = registry.get_runner(domain)
    if runner is None:
        print(f"unknown domain: {domain}", file=sys.stderr)
        return 1
    service = NotificationService()
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    runner(service)
    return 0


if __name__ == "__main__":
    sys.exit(main())
