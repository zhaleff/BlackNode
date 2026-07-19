#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0eb)
    tooltip = "AI assistants"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-ai", "alt": "coding-ai"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
