#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
LAST_FILE="$STATE_DIR/greeter_last.txt"
ICON_DIR="$(mktemp -d)"
trap 'rm -rf "$ICON_DIR"' EXIT

RAW_URL="https://raw.githubusercontent.com/zhaleff/BlackNode/main/Configs/.local/share/blacknode/greeter-phrases.txt"
CACHE="$STATE_DIR/greeter-phrases.cached.txt"
REPO_LOCAL="$HOME/BlackNode/Configs/.local/share/blacknode/greeter-phrases.txt"

PHRASES="$CACHE"
if curl -fsSL --max-time 8 "$RAW_URL" -o "$CACHE" 2>/dev/null && [[ -s "$CACHE" ]]; then
    PHRASES="$CACHE"
elif [[ -s "$REPO_LOCAL" ]]; then
    PHRASES="$REPO_LOCAL"
elif [[ -s "$CACHE" ]]; then
    PHRASES="$CACHE"
fi

USER_NAME="$(getent passwd "$USER" | cut -d: -f5)"
[[ -z "$USER_NAME" || "$USER_NAME" == "$USER" ]] && USER_NAME="${USER^}"

HOUR="$(date +%H | sed 's/^0//')"

case "$HOUR" in
    0|1|2|3|4)   FRANJA=late;   COLOR="#5b6ee1" ;;
    5|6|7)       FRANJA=dawn;   COLOR="#f5a25d" ;;
    8|9|10|11)   FRANJA=morning;COLOR="#ffd166" ;;
    12|13)       FRANJA=noon;   COLOR="#ffb703" ;;
    14|15|16|17) FRANJA=afternoon;COLOR="#fb8500" ;;
    18|19|20|21) FRANJA=evening; COLOR="#9d4edd" ;;
    *)           FRANJA=night;  COLOR="#3a0ca3" ;;
esac

svg_icon() {
    local f="$1" c="$2" out="$3"
    case "$f" in
        late|night)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="48" r="44" fill="$c" fill-opacity="0.18"/>
  <path d="M62 30a26 26 0 1 0 4 30 22 22 0 1 1 -4 -30z" fill="$c"/>
  <circle cx="20" cy="22" r="1.6" fill="#fff"/><circle cx="30" cy="14" r="1.2" fill="#fff"/>
  <circle cx="14" cy="34" r="1.2" fill="#fff"/><circle cx="76" cy="20" r="1.4" fill="#fff"/>
</svg>
SVG
            ;;
        dawn)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="52" r="20" fill="$c"/>
  <g stroke="$c" stroke-width="3" stroke-linecap="round">
    <line x1="48" y1="14" x2="48" y2="24"/><line x1="20" y1="30" x2="27" y2="37"/>
    <line x1="76" y1="30" x2="69" y2="37"/>
  </g>
  <path d="M22 74h52" stroke="$c" stroke-width="3" stroke-linecap="round" stroke-opacity="0.6"/>
</svg>
SVG
            ;;
        morning|noon|afternoon)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="48" r="22" fill="$c"/>
  <g stroke="$c" stroke-width="4" stroke-linecap="round">
    <line x1="48" y1="8" x2="48" y2="20"/><line x1="48" y1="76" x2="48" y2="88"/>
    <line x1="8" y1="48" x2="20" y2="48"/><line x1="76" y1="48" x2="88" y2="48"/>
    <line x1="19" y1="19" x2="28" y2="28"/><line x1="68" y1="68" x2="77" y2="77"/>
    <line x1="19" y1="77" x2="28" y2="68"/><line x1="68" y1="28" x2="77" y2="19"/>
  </g>
</svg>
SVG
            ;;
        evening)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="48" r="44" fill="$c" fill-opacity="0.15"/>
  <path d="M58 26a24 24 0 1 0 6 34 20 20 0 1 1 -6 -34z" fill="$c"/>
  <path d="M30 64l10 6-6 10z" fill="$c" fill-opacity="0.7"/>
</svg>
SVG
            ;;
    esac
}
ICON="$ICON_DIR/greeter.svg"
svg_icon "$FRANJA" "$COLOR" "$ICON"

if [[ -f "$PHRASES" ]]; then
    POOL=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        POOL+=("$line")
    done < <(awk -v sec="[$FRANJA]" '
        $0==sec{f=1; next}
        /^\[/{f=0}
        f{print}
    ' "$PHRASES" | sed '/^$/d')
fi

if [[ ${#POOL[@]} -eq 0 ]]; then
    PHRASE="Good to see you, $USER_NAME."
else
    LAST="$([[ -f "$LAST_FILE" ]] && cat "$LAST_FILE" || echo "")"
    choice="$LAST"
    for _ in 1 2 3; do
        candidate="${POOL[$((RANDOM % ${#POOL[@]}))]}"
        [[ "$candidate" != "$LAST" || ${#POOL[@]} -eq 1 ]] && { choice="$candidate"; break; }
    done
    echo "$choice" > "$LAST_FILE"
    PHRASE="$(echo "$choice" | sed "s/\$name/$USER_NAME/g")"
fi

notify-send -a "BlackNode" -i "$ICON" "BlackNode" "$PHRASE"
