#!/usr/bin/env python3
import json

def main():
    text = "\uf085"
    tooltip = "Environment — browser, focus mode, theme"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "env", "alt": "env"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
