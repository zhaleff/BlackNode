#!/usr/bin/env python3
import json
def main():
    text = chr(0xf120)
    tooltip = "Terminal — Kitty"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-term", "alt": "coding-term"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
