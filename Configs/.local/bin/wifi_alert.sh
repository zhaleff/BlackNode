#!/bin/bash

# Nombre de la interfaz WiFi (puedes cambiarlo si tu interfaz no es wlan0)
WIFI_INTERFACE="wlan0"

# Estado inicial
prev_state="disconnected"

while true; do
    # Verifica si la interfaz WiFi está activa (operstate = up)
    if [ -f "/sys/class/net/$WIFI_INTERFACE/operstate" ] && [ "$(cat /sys/class/net/$WIFI_INTERFACE/operstate)" = "up" ]; then
        current_state="connected"
    else
        current_state="disconnected"
    fi

    # Lanza notificación solo si el estado cambia
    if [ "$prev_state" != "$current_state" ]; then
        if [ "$current_state" == "connected" ]; then
            dunstify -u normal -i ~/.config/dunst/assets/wifi-online.svg -t 5000 -r 2595 "WiFi Connected"
        else
            dunstify -u normal -i ~/.config/dunst/assets/wifi-offline.svg -t 5000 -r 2595 "WiFi Disconnected"
        fi
        prev_state="$current_state"
    fi

    # Espera 5 segundos para evitar comprobaciones excesivas
    sleep 5
done

