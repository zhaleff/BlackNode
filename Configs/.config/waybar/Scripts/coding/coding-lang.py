#!/usr/bin/env python3
import json
def main():
    text = chr(0xf1c9)
    tooltip = "Language references"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-lang", "alt": "coding-lang"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
