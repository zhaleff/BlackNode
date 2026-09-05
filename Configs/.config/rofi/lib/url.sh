#!/usr/bin/env bash

urlq() {
    python3 -c 'import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))' "$1"
}

open_url() {
    xdg-open "$1" & disown
}
