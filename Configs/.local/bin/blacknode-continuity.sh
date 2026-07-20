#!/usr/bin/env bash
# BlackNode Session Continuity
# Guarda el estado real de la sesion y, al entrar, ofrece RETOMAR con un click.
#   blacknode-continuity.sh --save     -> persiste estado (suspend/reboot/shutdown)
#   blacknode-continuity.sh --restore  -> ofrece retomar lo que quedo pendiente

set -euo pipefail

STATE_DIR="$HOME/.local/share/blacknode"
STATE="$STATE_DIR/session_state.json"
REPO="$HOME/BlackNode"
THEME="$HOME/.config/rofi/styles/submenu.rasi"

save_state() {
    mkdir -p "$STATE_DIR"
    profile="$([[ -f "$STATE_DIR/active_profile" ]] && cat "$STATE_DIR/active_profile" || echo default)"
    branch=""; dirty=0
    if [[ -d "$REPO/.git" ]]; then
        branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
        [[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]] && dirty=1
    fi
    recent_notes="$(find "$HOME/BlackNode/Notes" -maxdepth 1 -type f -newermt '-2 days' 2>/dev/null | wc -l || true)"
    python3 - "$profile" "$branch" "$dirty" "$recent_notes" "$STATE" <<'PY'
import json, sys, datetime
profile, branch, dirty, rn, out = sys.argv[1:6]
json.dump({
    "saved_at": datetime.datetime.now().isoformat(timespec="seconds"),
    "profile": profile,
    "branch": branch,
    "dirty_repo": int(dirty),
    "recent_notes": int(rn),
}, open(out, "w"), indent=2)
PY
}

offer_restore() {
    [[ -f "$STATE" ]] || return 0
    profile="$(python3 -c "import json;print(json.load(open('$STATE')).get('profile','default'))")"
    dirty="$(python3 -c "import json;print(json.load(open('$STATE')).get('dirty_repo',0))")"
    rn="$(python3 -c "import json;print(json.load(open('$STATE')).get('recent_notes',0))")"
    active="$([[ -f "$STATE_DIR/active_profile" ]] && cat "$STATE_DIR/active_profile" || echo default)"

    lines=()
    [[ "$profile" != "$active" && "$profile" != "default" ]] && lines+=("󰏔  Retomar perfil: $profile")
    [[ "$dirty" == "1" ]] && lines+=("󰈙  Cambios sin commit en BlackNode")
    [[ "$rn" -gt 0 ]] && lines+=("󰏟  Abrir notas recientes ($rn)")
    [[ ${#lines[@]} -eq 0 ]] && return 0

    choice=$(printf '%s\n' "${lines[@]}" "󰸋  Ignorar" | rofi -dmenu -i -p " Retomar" -theme "$THEME")
    [[ -z "$choice" || "$choice" == "󰸋  Ignorar" ]] && return 0

    case "$choice" in
        "󰏔  Retomar perfil: $profile")
            echo "$profile" > "$STATE_DIR/active_profile"
            "$HOME/.config/rofi/scripts/profiles.sh" >/dev/null 2>&1 &
            ;;
        "󰈙  Cambios sin commit en BlackNode")
            kitty -e bash -c "git -C '$REPO' status; exec bash" & disown
            ;;
        "󰏟  Abrir notas recientes ($rn)")
            kitty -e nvim "$HOME/BlackNode/Notes" & disown
            ;;
    esac
}

case "${1:-}" in
    --save)    save_state ;;
    --restore) offer_restore ;;
    *)         save_state ;;
esac
