#!/usr/bin/env python3
import json
def main():
    text = chr(0xf085)
    tooltip = "Focus Mode — pause notifications"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-focus", "alt": "study-focus"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
