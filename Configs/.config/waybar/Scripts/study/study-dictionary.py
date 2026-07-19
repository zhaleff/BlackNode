#!/usr/bin/env python3
import json
def main():
    text = chr(0xf02d)
    tooltip = "Dictionary — Wiktionary"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-dictionary", "alt": "study-dictionary"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
