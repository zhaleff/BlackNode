#!/usr/bin/env bash

ICON_DIR="/tmp/blacknode-icons/network"
PROBE_IP="1.1.1.1"
DOMAIN="google.com"
INTERVAL=10

notify() {
    notify-send -h string:x-canonical-private-synchronous:internet \
        -i "$ICON_DIR/$1" "Internet" "$2"
}

check() {
    ip route show default | grep -q . || { echo none; return; }
    timeout 3 bash -c "exec 3<>/dev/tcp/$PROBE_IP/443" 2>/dev/null || { echo offline; return; }
    timeout 3 getent ahosts "$DOMAIN" &>/dev/null || { echo dns; return; }
    echo ok
}

reported="ok"
last="ok"
streak=0

while true; do
    state=$(check)

    if [[ "$state" == "$last" ]]; then
        ((streak++))
    else
        last="$state"
        streak=1
    fi

    if [[ $streak -eq 2 && "$state" != "$reported" ]]; then
        case "$state" in
            offline) notify wifi-no-network.svg "Connected, but no internet access" ;;
            dns)     notify wifi-no-network.svg "DNS is not resolving $DOMAIN" ;;
            ok)      notify wifi-strong.svg "Internet restored" ;;
            none)    state="ok" ;;
        esac
        reported="$state"
    fi

    sleep "$INTERVAL"
done
