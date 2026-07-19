#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0fbc)
    tooltip = "Wikipedia — random / search / ES"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-wiki", "alt": "study-wiki"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
