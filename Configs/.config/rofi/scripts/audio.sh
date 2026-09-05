#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
LOG="$HOME/.local/share/blacknode/music_history"
COVERS="${XDG_RUNTIME_DIR:-/tmp}/rofi_covers"
INPUT="${XDG_RUNTIME_DIR:-/tmp}/rofi_audio_input"
WATCHER_PID="${XDG_RUNTIME_DIR:-/tmp}/blacknode_audio_watcher.pid"
mkdir -p "$(dirname "$LOG")" "$COVERS"
MAX_LOG=12

FALLBACK=""
make_fallback() {
    FALLBACK="$COVERS/_fallback.png"
    [ -f "$FALLBACK" ] && return
    if command -v convert &>/dev/null; then
        convert -size 36x36 xc:'#262b27' "$FALLBACK" 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "
import struct, zlib
w,h=36,36
raw=b''
for y in range(h):raw+=b'\0'+b'\x26\x2b\x27'*w
def c(t,d):return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
with open('$FALLBACK','wb')as f:f.write(b'\x89PNG\r\n\x1a\n'+c(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+c(b'IDAT',zlib.compress(raw))+c(b'IEND',b''))
" 2>/dev/null
    fi
    [ ! -f "$FALLBACK" ] && FALLBACK=""
}

is_ad() {
    local text
    text=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    [[ "$text" =~ anuncio|sin\ anuncios|advertisement|listen\ ad-free|spotify\ ad|publicidad ]] && return 0
    return 1
}

start_watcher() {
    [ -f "$WATCHER_PID" ] && kill -0 "$(cat "$WATCHER_PID")" 2>/dev/null && return
    (
        while true; do
            playerctl --follow metadata title 2>/dev/null | while IFS= read -r title; do
                [ -z "$title" ] && continue
                ARTIST=$(playerctl metadata artist 2>/dev/null)
                is_ad "$title" || is_ad "$ARTIST" && continue
                ALBUM=$(playerctl metadata album 2>/dev/null)
                ART=$(playerctl metadata mpris:artUrl 2>/dev/null)
                PLAYER=$(playerctl -l 2>/dev/null | head -1)
                LAST=$(tail -1 "$LOG" 2>/dev/null | cut -d'|' -f2)
                [ "$title" = "$LAST" ] && continue
                echo "$(date +'%s')|${title}|${ARTIST}|${ALBUM}|${ART}|${PLAYER}" >> "$LOG"
            done
            sleep 5
        done
    ) &>/dev/null &
    echo $! > "$WATCHER_PID"
}

track_current() {
    PLAYER=$(playerctl -l 2>/dev/null | head -1)
    [ -z "$PLAYER" ] && return
    TITLE=$(playerctl metadata title 2>/dev/null)
    ARTIST=$(playerctl metadata artist 2>/dev/null)
    is_ad "$TITLE" || is_ad "$ARTIST" && return
    ALBUM=$(playerctl metadata album 2>/dev/null)
    ART=$(playerctl metadata mpris:artUrl 2>/dev/null)
    LAST=$(tail -1 "$LOG" 2>/dev/null | cut -d'|' -f2)
    [ "$TITLE" = "$LAST" ] && return
    echo "$(date +'%s')|${TITLE}|${ARTIST}|${ALBUM}|${ART}|${PLAYER}" >> "$LOG"
}

download_art() {
    local url="$1" out="$2"
    [ -f "$out" ] && return
    case "$url" in
        file://*) [ -f "${url#file://}" ] && cp "${url#file://}" "$out" 2>/dev/null ;;
        http*) curl -sL --max-time 3 -o "$out" "$url" 2>/dev/null ;;
    esac
    [ ! -s "$out" ] && rm -f "$out"
}

show_list() {
    start_watcher
    track_current
    local logtmp; logtmp=$(mktemp "${LOG}.XXXXXX")
    tail -n "$MAX_LOG" "$LOG" 2>/dev/null > "$logtmp" && mv "$logtmp" "$LOG"
    make_fallback
    > "$INPUT"
    HASHS=""
    FIRST=true
    while IFS='|' read -r ts title artist album art_url player; do
        [ -z "$title" ] && continue
        is_ad "$title" || is_ad "$artist" && continue
        HASH=$(echo "$title$artist" | md5sum | cut -d' ' -f1)
        HASHS="$HASHS $HASH"
        COVER="$COVERS/$HASH.png"
        download_art "$art_url" "$COVER"
        LABEL="$title"
        [ -n "$artist" ] && LABEL="$LABEL - $artist"
        $FIRST && LABEL="$LABEL  " && FIRST=false
        ICON=""
        [ -f "$COVER" ] && ICON="$COVER"
        [ -z "$ICON" ] && [ -n "$FALLBACK" ] && ICON="$FALLBACK"
        if [ -n "$ICON" ]; then
            printf '%b' "$LABEL\000icon\037$ICON\n" >> "$INPUT"
        else
            echo "$LABEL" >> "$INPUT"
        fi
    done < <(tac "$LOG" 2>/dev/null)

    for f in "$COVERS"/*.png; do
        [ "$f" = "$FALLBACK" ] && continue
        H=$(basename "$f" .png)
        case " $HASHS " in *" $H "*) ;; *) rm -f "$f" ;; esac
    done

    [ ! -s "$INPUT" ] && { notify-send "Audio" "No music history"; exit; }
    SELECTED=$(rofi -dmenu -theme "$THEME" -p "Recently Played" < "$INPUT")
    [ -z "$SELECTED" ] && exit
    notify-send "Audio" "$(echo "$SELECTED" | sed 's/  $//')"
}

volume_control() {
    local vol muted icon mic_icon mic_muted
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
    [ "$muted" -gt 0 ] && icon="󰝟" || icon="󰕾"

    mic_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c MUTED)
    [ "$mic_muted" -gt 0 ] && mic_icon="" || mic_icon="󰍭"

    CHOICE=$(printf '%s\n' \
        "󰌍  Back" \
        "󰕾  Volume $vol%" \
        "󰝝  Volume +10%" \
        "󰝞  Volume -10%" \
        "󰝚  Apps" \
        "󰋲  History" \
        "$mic_icon  Mic" \
        | rofi -dmenu -theme "$THEME" -p "Audio")

    case "$CHOICE" in
        *"Back")           exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Volume"*)
            if [[ "$CHOICE" == *"+10%"* ]]; then
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+ && notify-send "Audio" "+10%"
            elif [[ "$CHOICE" == *"-10%"* ]]; then
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- && notify-send "Audio" "-10%"
            else
                wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                local m=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED || echo "unmuted")
                notify-send "Audio" "$m"
            fi
            volume_control
            ;;
        *"Apps")
            local list=""
            while IFS= read -r block; do
                id=$(echo "$block" | awk '/^Sink Input/ {gsub(/.*#/, "", $3); print $3}')
                name=$(echo "$block" | awk -F'"' '/application.name/ {print $2}')
                mute=$(echo "$block" | awk '/Mute:/ {print $2}')
                [ -z "$name" ] && continue
                icon="󰝚"
                [ "$mute" = "yes" ] && icon="󰝟"
                list="${list}${icon} $name ($id)\n"
            done < <(pactl list sink-inputs 2>/dev/null | sed -n '/Sink Input/,/^$/p')
            [ -z "$list" ] && { notify-send "Audio" "No active apps"; volume_control; return; }
            SELECTED=$(printf '%b' "$list" | rofi -dmenu -theme "$THEME" -p "Audio Apps")
            [ -z "$SELECTED" ] && { volume_control; return; }
            APP_ID=$(echo "$SELECTED" | sed 's/.*(\([0-9]*\)).*/\1/')
            [ -n "$APP_ID" ] && pactl set-sink-input-mute "$APP_ID" toggle && volume_control
            ;;
        *"History")
            show_list
            ;;
        *"Mic")
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
            local m=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -o MUTED || echo "unmuted")
            notify-send "Audio" "Mic: $m"
            volume_control
            ;;
    esac
}

case "${1:-}" in
    --history) show_list ;;
    *) volume_control ;;
esac
