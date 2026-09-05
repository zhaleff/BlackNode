#!/usr/bin/env bash

ROFI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROFI_THEMES="$ROFI_DIR/themes"

for _bn_lib in notify rofi url search; do
    source "$ROFI_DIR/lib/$_bn_lib.sh"
done
unset _bn_lib
