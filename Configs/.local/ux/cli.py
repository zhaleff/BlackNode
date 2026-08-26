#!/usr/bin/env python3
"""BlackNode UX CLI — behavioral engine interface."""
from __future__ import annotations
import sys
import json
from .core.engine import UXEngine
from .core.events import Event, EventKind
from .core.state import UXState
from .core.policy import Action


def _engine(*, debug: bool = False) -> UXEngine:
    return UXEngine(debug=debug)


def cmd_boot(_: list[str]) -> None:
    e = _engine()
    e.boot()
    print(json.dumps({
        "state": e.state.current.name,
        "first_boot": e.get("onboarding.done") is None,
    }))


def cmd_theme(args: list[str]) -> None:
    if not args:
        print("usage: blacknode ux theme <name>")
        return
    e = _engine()
    e.switch_theme(args[0])
    print(json.dumps({
        "theme": args[0],
        "state": e.state.current.name,
    }))


def cmd_profile(args: list[str]) -> None:
    if not args:
        print("usage: blacknode ux profile <name>")
        return
    e = _engine()
    e.switch_profile(args[0])
    print(json.dumps({
        "profile": args[0],
        "state": e.state.current.name,
    }))


def cmd_mode(args: list[str]) -> None:
    if not args:
        print("usage: blacknode ux mode <gaming|lowpower|normal>")
        return
    e = _engine()
    mode = args[0]
    if mode == "normal":
        current = e.state.current
        if current == UXState.GAMING:
            e.exit_mode("gaming")
        elif current == UXState.LOW_POWER:
            e.exit_mode("low_power")
    else:
        e.enter_mode(mode)
    print(json.dumps({
        "mode": mode,
        "state": e.state.current.name,
    }))


def cmd_status(_: list[str]) -> None:
    e = _engine()
    print(json.dumps(e.status(), indent=2))


def cmd_intents(args: list[str]) -> None:
    e = _engine()
    if not args:
        intents = e.intents.by_priority()
        print(json.dumps([{
            "name": i.name,
            "priority": i.priority,
            "source": i.source.name,
            "confidence": i.confidence,
        } for i in intents], indent=2))
    elif args[0] == "activate" and len(args) > 1:
        e.request_intent(args[1])
        print(json.dumps({"activated": args[1]}))
    elif args[0] == "deactivate" and len(args) > 1:
        e.cancel_intent(args[1])
        print(json.dumps({"deactivated": args[1]}))


def cmd_policies(_: list[str]) -> None:
    e = _engine()
    matches = e.policies.evaluate(e.context, e.intents.by_priority())
    print(json.dumps([{
        "name": m.policy.name,
        "priority": m.policy.priority,
        "safety": m.policy.safety.name,
        "relevance": m.relevance,
        "conditions_met": f"{m.conditions_met}/{m.conditions_total}",
    } for m in matches], indent=2))


def cmd_decisions(_: list[str]) -> None:
    e = _engine()
    recent = e.decisions.recent(10)
    print(json.dumps([{
        "id": d.id,
        "resolution": d.resolution.name,
        "policies": d.matched_policies,
        "conflicts": len(d.conflicts),
        "actions": len(d.actions),
    } for d in recent], indent=2))


def cmd_explain(args: list[str]) -> None:
    if not args:
        print("usage: blacknode ux explain <decision_id>")
        return
    e = _engine()
    explanation = e.explain(args[0])
    if explanation is None:
        print(json.dumps({"error": "decision not found"}))
        return
    print(json.dumps({
        "id": explanation.decision_id,
        "reason": explanation.reason,
        "factors": explanation.contributing_factors,
        "policies": explanation.policies_applied,
        "conflicts": explanation.conflicts_resolved,
        "safety": explanation.safety_checks,
    }, indent=2))


def cmd_suggest(_: list[str]) -> None:
    e = _engine()
    suggestion = e.suggest()
    if suggestion is None:
        print(json.dumps({"suggestion": None}))
        return
    print(json.dumps({
        "id": suggestion.id,
        "description": suggestion.description,
        "confidence": suggestion.confidence,
        "evidence": suggestion.evidence,
    }, indent=2))


def cmd_learning(_: list[str]) -> None:
    e = _engine()
    print(json.dumps(e.learning.summary(), indent=2))


def cmd_permissions(_: list[str]) -> None:
    e = _engine()
    perms = e.permissions.list_permissions()
    print(json.dumps([{
        "policy": p.policy_name,
        "decision": p.decision.name,
        "remember": p.remember,
    } for p in perms], indent=2))


COMMANDS = {
    "boot": cmd_boot,
    "theme": cmd_theme,
    "profile": cmd_profile,
    "mode": cmd_mode,
    "status": cmd_status,
    "intents": cmd_intents,
    "policies": cmd_policies,
    "decisions": cmd_decisions,
    "explain": cmd_explain,
    "suggest": cmd_suggest,
    "learning": cmd_learning,
    "permissions": cmd_permissions,
}


def main() -> None:
    args = sys.argv[1:]
    debug = "--debug" in args
    args = [a for a in args if a != "--debug"]

    if not args or args[0] not in COMMANDS:
        print("usage: blacknode ux <command> [args]")
        print(f"commands: {', '.join(COMMANDS)}")
        sys.exit(1)

    COMMANDS[args[0]](args[1:])


if __name__ == "__main__":
    main()
