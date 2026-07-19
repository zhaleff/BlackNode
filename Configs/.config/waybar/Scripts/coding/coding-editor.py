#!/usr/bin/env python3
import json
def main():
    text = chr(0xf121)
    tooltip = "Editor — Neovim"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-editor", "alt": "coding-editor"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
