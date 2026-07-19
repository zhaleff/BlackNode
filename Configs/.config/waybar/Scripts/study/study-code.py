#!/usr/bin/env python3
import json
def main():
    text = chr(0xf121)
    tooltip = "Code / Terminal — practice"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-code", "alt": "study-code"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
