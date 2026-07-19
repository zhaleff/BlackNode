#!/usr/bin/env python3
import json
def main():
    text = chr(0xf1d3)
    tooltip = "Version control — Git"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-git", "alt": "coding-git"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
