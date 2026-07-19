#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0eee)
    tooltip = "Documents — recent / open"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-docs", "alt": "study-docs"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
