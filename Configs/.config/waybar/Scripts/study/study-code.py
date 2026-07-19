#!/usr/bin/env python3
import json

def main():
    text = "\uf120"
    tooltip = "Code — editor & terminal for practice"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "code", "alt": "code"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
