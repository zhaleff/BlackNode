#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0f34)
    tooltip = "Notes — new / open / browse"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-notes", "alt": "study-notes"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
