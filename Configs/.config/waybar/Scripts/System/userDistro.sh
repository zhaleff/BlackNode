#!/usr/bin/env bash

source /etc/os-release

case "$ID" in
    nixos)
        icon=""
        ;;

    arch)
        icon=""
        ;;

    artix)
        icon=""
        ;;

    manjaro)
        icon=""
        ;;

    endeavouros)
        icon=""
        ;;

    cachyos)
        icon=""
        ;;

    *)
        icon=""
        ;;
esac


kernel=$(uname -r)
tooltip="$icon  ${NAME}\n  ${kernel}\n  ${USER}"
USER=$(whoami)

printf '{"text":"%s","tooltip":"%s"}\n' "$icon" "$tooltip"
