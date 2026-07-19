#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0fbc)
    tooltip = "Documentation hub"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-docs", "alt": "coding-docs"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
