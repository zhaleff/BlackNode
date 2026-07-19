#!/usr/bin/env python3
import json

def main():
    text = "\uf269"
    tooltip = "Browser — study resources & research"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "browser", "alt": "browser"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
