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

# ---------- mensaje no generico (psicologia: te conoce) ----------
DOW_NAME="$(date +%A)"
title="BlackNode"
body=""

case "$FRANJA" in
    late)
        body="${USER_NAME}, son las de la madrugada. El equipo esta listo si lo necesitas; si no, descansa. 🌃"
        ;;
    dawn)
        if [[ "$DOW" == "1" ]]; then
            body="Lunes temprano, ${USER_NAME}. El sistema ya cargo tu perfil y bajó las distracciones. Empieza sin ruido."
        else
            body="Madrugaste, ${USER_NAME}. Tu entorno esta exactamente como lo dejaste ayer."
        fi
        ;;
    morning)
        if [[ "$streak" -ge 3 ]]; then
            body="Buenos dias, ${USER_NAME}. Vas $streak dias seguidos aqui — tu ritmo ya se nota. ☀"
        else
            body="Buenos dias, ${USER_NAME}. Hoy es una buena pagina en blanco."
        fi
        ;;
    noon)
        body="Mediodia, ${USER_NAME}. Respira un momento; tu sesion sigue intacta del lado izquierdo."
        ;;
    afternoon)
        if [[ "$PROFILE" != "default" ]]; then
            body="Tarde avanzada, ${USER_NAME}. Perfil '$PROFILE' activo y tu espacio de trabajo ya calibrado."
        else
            body="Buenas tardes, ${USER_NAME}. Si venias a trabajar, todo esta donde lo dejaste."
        fi
        ;;
    evening)
        if [[ "$DOW" == "5" ]]; then
            body="Viernes por la noche, ${USER_NAME}. Cierra lo que abriste; el sistema guardo tu estado."
        elif [[ "$COMMITS_TODAY" != "0" ]]; then
            body="Buenas noches, ${USER_NAME}. Hoy dejaste $COMMITS_TODAY commit(s) en el camino verde. 🌙"
        else
            body="Buenas noches, ${USER_NAME}. Luz baja activada — el sistema bajo el brillo por ti."
        fi
        ;;
    night)
        body="Noche, ${USER_NAME}. Modo calma ON: menos luz, menos ruido. Tu mañana estara lista."
        ;;
esac

# linea de contexto discreta
ctx="Perfil: $PROFILE   ·   Racha: $streak día(s)"
[[ "$COMMITS_TODAY" != "0" ]] && ctx="$ctx   ·   Commits hoy: $COMMITS_TODAY"

notify-send -i "$ICON" -a "BlackNode" "$title" "$body"$'\n'"$ctx"
