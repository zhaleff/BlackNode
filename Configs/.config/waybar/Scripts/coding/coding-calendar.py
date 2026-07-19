#!/usr/bin/env python3
import json
def main():
    text = chr(0xf073)
    tooltip = "Calendar — schedule"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-calendar", "alt": "coding-calendar"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
