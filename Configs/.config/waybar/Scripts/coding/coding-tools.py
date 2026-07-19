#!/usr/bin/env python3
import json
def main():
    text = chr(0xf085)
    tooltip = "Dev tools — Docker, API, etc."
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-tools", "alt": "coding-tools"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
