#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0fbc)
    tooltip = "Markdown — open notes in nvim"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-markdown", "alt": "study-markdown"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
