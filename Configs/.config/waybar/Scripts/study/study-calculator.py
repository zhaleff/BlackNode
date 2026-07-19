#!/usr/bin/env python3
import json
def main():
    text = chr(0xf1ec)
    tooltip = "Calculator"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-calculator", "alt": "study-calculator"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
