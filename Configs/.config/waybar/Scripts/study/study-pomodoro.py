#!/usr/bin/env python3
import json
def main():
    text = chr(0xf0dc)
    tooltip = "Pomodoro — focus timer"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "study-pomodoro", "alt": "study-pomodoro"}, ensure_ascii=False))
if __name__ == "__main__":
    main()
