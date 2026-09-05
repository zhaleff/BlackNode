import json


def emit(text, cls=None, tooltip=None, alt=None, percentage=None):
    payload = {"text": text}
    if cls:
        payload["class"] = cls
    if tooltip is not None:
        payload["tooltip"] = tooltip
    if alt:
        payload["alt"] = alt
    if percentage is not None:
        payload["percentage"] = percentage
    print(json.dumps(payload, ensure_ascii=False))