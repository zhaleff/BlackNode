#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0e6)
    tooltip = "Q&A — Stack Overflow / search"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-stack", "alt": "coding-stack"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
