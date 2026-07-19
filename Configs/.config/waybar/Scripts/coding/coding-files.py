#!/usr/bin/env python3
import json
def main():
    text = chr(0xf07b)
    tooltip = "Files — file manager"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "coding-files", "alt": "coding-files"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
