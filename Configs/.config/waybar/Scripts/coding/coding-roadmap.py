#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0e4)
    tooltip = "Roadmap.sh — career paths"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-roadmap", "alt": "coding-roadmap"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
