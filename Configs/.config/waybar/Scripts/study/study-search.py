#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0e84)
    tooltip = "Search — files / web / text"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-search", "alt": "study-search"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
