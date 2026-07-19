#!/usr/bin/env python3
import json
import os

NOTES_APP = os.environ.get("STUDY_NOTES", "obsidian")

def main():
    text = "\uf15c"
    tooltip = "Notes — open your knowledge base (Markdown / Obsidian)"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "notes", "alt": "notes"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
