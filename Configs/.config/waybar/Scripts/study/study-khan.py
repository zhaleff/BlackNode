#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0eee)
    tooltip = "Khan Academy"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-khan", "alt": "study-khan"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
