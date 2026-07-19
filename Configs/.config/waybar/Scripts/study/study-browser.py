#!/usr/bin/env python3
import json
def main():
    text = chr(0xf269)
    tooltip = "Browser — research resources"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-browser", "alt": "study-browser"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
