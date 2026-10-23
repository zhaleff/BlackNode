#!/usr/bin/env bash
for s in ufw firewalld nftables; do
  systemctl is-active --quiet "$s" && { fw=$s; break; }
done

ports=$(ss -tuln | tail -n +2 | wc -l)

if [ -n "$fw" ]; then
  cls=active
  tip="Firewall: ACTIVE\nService: $fw\nSince: $(systemctl show "$fw" -p ActiveEnterTimestamp --value)\nListening ports: $ports"
else
  cls=inactive
  tip="Firewall: INACTIVE\nListening ports: $ports"
fi

jq -nc --arg c "$cls" --arg t "$(printf '%b' "$tip")" '{text:"󱨑",class:$c,tooltip:$t}'
