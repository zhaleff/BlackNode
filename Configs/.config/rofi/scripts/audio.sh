#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
LIST_THEME="$R/styles/audio-list.rasi"
LOG="$HOME/.local/share/blacknode/music_history"
COVERS="/tmp/rofi_covers"
INPUT="/tmp/rofi_audio_input"
mkdir -p "$(dirname "$LOG")"

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
    track_current
    tail -10 "$LOG" 2>/dev/null > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
    mkdir -p "$COVERS"
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
        $FIRST && LABEL="$LABEL  " && FIRST=false
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

    [ ! -s "$INPUT" ] && notify-send "Audio" "No music history" && exit
    SELECTED=$(rofi -dmenu -p "Recently Played" -theme "$LIST_THEME" < "$INPUT")
    [ -z "$SELECTED" ] && exit
    notify-send "Audio" "$(echo "$SELECTED" | sed 's/  $//')"
}

list_sessions() {
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

    [ -z "$list" ] && notify-send "Audio" "No active apps" && exit
    SELECTED=$(printf '%b' "$list" | rofi -dmenu -p "Audio Apps" -theme "$LIST_THEME" -theme-str "listview { lines: 8; } window { width: 400px; }")
    [ -z "$SELECTED" ] && exit
    APP_ID=$(echo "$SELECTED" | sed 's/.*(\([0-9]*\)).*/\1/')
    [ -n "$APP_ID" ] && pactl set-sink-input-mute "$APP_ID" toggle && list_sessions
}

CHOICE=$(printf "󰋲 \n󰝚 " | rofi -dmenu -p "Audio" -theme-str "listview { lines: 2; }" -theme "$MENU_THEME")
case "$CHOICE" in
    "󰋲 ") show_list ;;
    "󰝚 ") list_sessions ;;
esac
