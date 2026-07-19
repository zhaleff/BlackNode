#!/usr/bin/env python3
import json

def main():
    text = "\uf0ac"
    tooltip = "Research — Wikipedia, search, dictionaries"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "research", "alt": "research"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
