#!/usr/bin/env python3
import json
def main():
    text = chr(0xf1ea)
    tooltip = "Nature — journal"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-nature", "alt": "study-nature"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
