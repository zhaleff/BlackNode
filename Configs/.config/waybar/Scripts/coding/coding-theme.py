#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0ecc)
    tooltip = "Theme — switch look"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-theme", "alt": "coding-theme"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
