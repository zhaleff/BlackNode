#!/usr/bin/env python3
import json

def main():
    text = "\uf1c1"
    tooltip = "Documents — recent PDFs / eBooks"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "docs", "alt": "docs"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
