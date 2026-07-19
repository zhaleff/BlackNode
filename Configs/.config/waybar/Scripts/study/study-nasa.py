#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0c3)
    tooltip = "NASA Science"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-nasa", "alt": "study-nasa"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
