#!/usr/bin/env bash

# Script for suspend jsjs
#

systemd-run --user --scope bash -c 'sleep 3; systemctl suspend; sleep 5; notify-send "Welcome back, $USER"'
