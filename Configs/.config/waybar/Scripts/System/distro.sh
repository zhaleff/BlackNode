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

printf '{"text":"%s"}\n' "$icon"
