#!/usr/bin/env python3
import json

def main():
    text = "\uf0c3"
    tooltip = "Tools — pomodoro, calculator, calendar"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "tools", "alt": "tools"}, ensure_ascii=False))

if __name__ == "__main__":
    main()
