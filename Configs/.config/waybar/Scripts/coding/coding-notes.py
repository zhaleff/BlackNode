#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0f34)
    tooltip = "Scratch notes — nvim"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-notes", "alt": "coding-notes"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
