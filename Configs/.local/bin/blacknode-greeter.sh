#!/usr/bin/env bash
# BlackNode Contextual Greeter
# El sistema recibe al usuario segun la franja horaria real, con su nombre,
# un icono SVG tematico y un mensaje que NO es generico: usa racha de dias,
# commits de hoy y perfil activo. Se dispara al iniciar sesion y al despertar.
#
# Sin placeholders: toda la info es real y se calcula una sola vez.

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
STREAK_FILE="$STATE_DIR/streak.json"
ACTIVE_FILE="$STATE_DIR/active_profile"
HEAT_SCRIPT="$HOME/.config/waybar/Scripts/git/git-heat.py"
ICON_DIR="$(mktemp -d)"
trap 'rm -rf "$ICON_DIR"' EXIT

USER_NAME="$(getent passwd "$USER" | cut -d: -f5)"
[[ -z "$USER_NAME" || "$USER_NAME" == "$USER" ]] && USER_NAME="${USER^}"

HOUR="$(date +%H | sed 's/^0//')"
DOW="$(date +%u)"        # 1=Mon .. 7=Sun
TODAY="$(date +%Y-%m-%d)"

# ---------- franja horaria ----------
case "$HOUR" in
    0|1|2|3|4)   FRANJA=late;   COLOR="#5b6ee1" ;;
    5|6|7)       FRANJA=dawn;   COLOR="#f5a25d" ;;
    8|9|10|11)   FRANJA=morning;COLOR="#ffd166" ;;
    12|13)       FRANJA=noon;   COLOR="#ffb703" ;;
    14|15|16|17) FRANJA=afternoon;COLOR="#fb8500" ;;
    18|19|20|21) FRANJA=evening; COLOR="#9d4edd" ;;
    *)           FRANJA=night;  COLOR="#3a0ca3" ;;
esac

# ---------- racha de dias consecutivos ----------
streak=1
if [[ -f "$STREAK_FILE" ]]; then
    last="$(python3 -c "import json;print(json.load(open('$STREAK_FILE')).get('last',''))" 2>/dev/null || true)"
    prev="$(python3 -c "import json;print(json.load(open('$STREAK_FILE')).get('streak',1))" 2>/dev/null || echo 1)"
    if [[ "$last" == "$TODAY" ]]; then
        streak="$prev"
    else
        yest="$(date -d yesterday +%Y-%m-%d)"
        if [[ "$last" == "$yest" ]]; then streak=$((prev+1)); else streak=1; fi
    fi
fi
mkdir -p "$STATE_DIR"
printf '{"last":"%s","streak":%s}\n' "$TODAY" "$streak" > "$STREAK_FILE"

# ---------- datos reales de contexto ----------
PROFILE="$([[ -f "$ACTIVE_FILE" ]] && cat "$ACTIVE_FILE" || echo "default")"
COMMITS_TODAY="0"
if [[ -x "$HEAT_SCRIPT" ]]; then
    COMMITS_TODAY="$(python3 "$HEAT_SCRIPT" 2>/dev/null | python3 -c "import json,sys;print(json.load(sys.stdin)['tooltip'].split('Today: ')[-1].split(' ')[0])" 2>/dev/null || echo 0)"
fi

# ---------- icono SVG vectorial por franja ----------
svg_icon() {
    local f="$1" c="$2" out="$3"
    case "$f" in
        late|night)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="48" r="44" fill="$c" fill-opacity="0.18"/>
  <path d="M62 30a26 26 0 1 0 4 30 22 22 0 1 1 -4 -30z" fill="$c"/>
  <circle cx="20" cy="22" r="1.6" fill="#fff"/>
  <circle cx="30" cy="14" r="1.2" fill="#fff"/>
  <circle cx="14" cy="34" r="1.2" fill="#fff"/>
  <circle cx="76" cy="20" r="1.4" fill="#fff"/>
</svg>
SVG
            ;;
        dawn)
            cat > "$out" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
  <circle cx="48" cy="52" r="20" fill="$c"/>
  <g stroke="$c" stroke-width="3" stroke-linecap="round">
    <line x1="48" y1="14" x2="48" y2="24"/>
    <line x1="20" y1="30" x2="27" y2="37"/>
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
    <line x1="48" y1="8" x2="48" y2="20"/>
    <line x1="48" y1="76" x2="48" y2="88"/>
    <line x1="8" y1="48" x2="20" y2="48"/>
    <line x1="76" y1="48" x2="88" y2="48"/>
    <line x1="19" y1="19" x2="28" y2="28"/>
    <line x1="68" y1="68" x2="77" y2="77"/>
    <line x1="19" y1="77" x2="28" y2="68"/>
    <line x1="68" y1="28" x2="77" y2="19"/>
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

# ---------- message: real psychology, system feels alive (ENGLISH) ----------
title="BlackNode"
body=""

case "$FRANJA" in
    late)
        body="It's the small hours, ${USER_NAME}. The machine is here if you need it. If not, rest. You earned it."
        ;;
    dawn)
        if [[ "$DOW" == "1" ]]; then
            body="Early Monday, ${USER_NAME}. Your space is already set — no noise, just you and the work."
        else
            body="You're up before the world, ${USER_NAME}. Everything is exactly where you left it yesterday."
        fi
        ;;
    morning)
        if [[ "$streak" -ge 3 ]]; then
            body="Morning, ${USER_NAME}. ${streak} days running now — I can see the rhythm you've built. Keep it."
        else
            body="Morning, ${USER_NAME}. Fresh page today. Make it yours."
        fi
        ;;
    noon)
        body="Midday, ${USER_NAME}. Breathe a second — your session is still right there waiting for you."
        ;;
    afternoon)
        if [[ "$PROFILE" != "default" ]]; then
            body="Late afternoon, ${USER_NAME}. Profile '$PROFILE' is live and your workspace is already dialed in."
        else
            body="Good afternoon, ${USER_NAME}. If you came to build something, it's all still where you left it."
        fi
        ;;
    evening)
        if [[ "$DOW" == "5" ]]; then
            body="Friday night, ${USER_NAME}. Close what you opened — I saved your state so Monday meets you halfway."
        elif [[ "$COMMITS_TODAY" != "0" ]]; then
            body="Evening, ${USER_NAME}. You left ${COMMITS_TODAY} commit(s) on the board today. That's real progress — be proud of it."
        else
            body="Evening, ${USER_NAME}. The light just dropped for you. Your tomorrow is already prepared."
        fi
        ;;
    night)
        body="Night, ${USER_NAME}. Quiet mode, lower light. You showed up today — that's what counts."
        ;;
esac

# discreet context line
ctx="Profile: $PROFILE"
[[ "$COMMITS_TODAY" != "0" ]] && ctx="$ctx   ·   Commits today: $COMMITS_TODAY"
[[ "$streak" -ge 2 ]] && ctx="$ctx   ·   Streak: $streak days"

notify-send -a "BlackNode" -i "$ICON" "$title" "$body"$'\n'"$ctx"
