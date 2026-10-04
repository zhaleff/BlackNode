#!/usr/bin/env bash

if pgrep -x wf-recorder >/dev/null; then
    printf '{"text":"\uf03d","class":"recording","tooltip":"Recording in progress"}\n'
else
    printf '{"text":"\uf03d","class":"idle","tooltip":"Not recording"}\n'
fi
