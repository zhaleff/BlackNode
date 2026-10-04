#!/usr/bin/env bash

case "$(playerctl status 2>/dev/null)" in
  Playing) printf '{"text":"%s","class":"playing","alt":"playing"}\n' $'\uf04b' ;;
  Paused)  printf '{"text":"%s","class":"paused","alt":"paused"}\n'  $'\uf04c' ;;
  *)       printf '{"text":"%s","class":"stopped","alt":"stopped"}\n' $'\uf04d' ;;
esac
