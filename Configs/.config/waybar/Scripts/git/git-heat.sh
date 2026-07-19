#!/usr/bin/env bash
# Click en el modulo git-heat: muestra commits de hoy + totales.
REPO="$HOME/BlackNode"
THEME="$HOME/.config/rofi/styles/submenu.rasi"
LIST="$HOME/.config/rofi/styles/search-list.rasi"

today=$(date +%Y-%m-%d)
count=$(git -C "$REPO" log --since="$today 00:00:00" --oneline 2>/dev/null | wc -l)
total=$(git -C "$REPO" rev-list --count HEAD 2>/dev/null)

header="󱡣  Hoy: $count commit(s)   |   Total repo: $total"
commits=$(git -C "$REPO" log --since="$today 00:00:00" --format="%h  %s" 2>/dev/null)

if [[ -z "$commits" ]]; then
    echo -e "$header\n\n(Sin commits hoy todavia)" | rofi -dmenu -p " Git" -theme "$THEME"
else
    echo -e "$header\n$commits" | rofi -dmenu -i -p " Git hoy" -theme "$LIST"
fi
