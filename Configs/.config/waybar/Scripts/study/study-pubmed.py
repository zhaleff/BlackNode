#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0fbc)
    tooltip = "PubMed — biomedical"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-pubmed", "alt": "study-pubmed"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
