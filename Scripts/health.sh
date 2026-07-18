#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/BlackNode"
CHECK_PASS=0
CHECK_FAIL=0
CHECK_WARN=0
RESULTS=()

pass() { CHECK_PASS=$((CHECK_PASS + 1)); RESULTS+=("  ✓  $1"); }
warn() { CHECK_WARN=$((CHECK_WARN + 1)); RESULTS+=("  ⚠  $1"); }
fail() { CHECK_FAIL=$((CHECK_FAIL + 1)); RESULTS+=("  ✗  $1"); }

service_running() {
    systemctl is-active --quiet "${1}" 2>/dev/null && pass "${1} is running" || fail "${1} is not running"
}

executable() {
    command -v "${1}" &>/dev/null && pass "${1} found" || fail "${1} not found"
}

config_exists() {
    local target="${HOME}/${1}"
    if [[ -L "${target}" ]]; then
        local link; link=$(readlink "${target}")
        [[ -f "${link}" ]] && pass "${1} → linked to ${link}" || fail "${1} → broken symlink (→ ${link})"
    elif [[ -f "${target}" ]]; then
        pass "${1} exists"
    elif [[ -d "${target}" ]]; then
        pass "${1} directory exists"
    else
        fail "${1} missing"
    fi
}

hr() { printf '%*s\n' 50 '' | tr ' ' '─'; }
echo ""
echo "  BlackNode System Health"
echo ""

hr

# System services
echo "  Services"
service_running "NetworkManager"
service_running "pipewire"
[[ -f /run/current-system/sw/bin/dbus ]] || service_running "dbus"
service_running "systemd-logind"
echo ""

# Desktop session
echo "  Session"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    pass "Hyprland running (instance: ${HYPRLAND_INSTANCE_SIGNATURE})"
else
    fail "Hyprland not running (not in a Hyprland session)"
fi
executable "hyprctl"
executable "hyprlock"
executable "waybar"
executable "rofi"
executable "kitty"
executable "awww"
executable "matugen"
echo ""

# GPU
echo "  GPU & Drivers"
if command -v nvidia-smi &>/dev/null; then
    local nv_ver; nv_ver=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "unknown")
    pass "NVIDIA GPU detected (driver ${nv_ver})"
elif lsmod | grep -q "^nvidia" 2>/dev/null; then
    warn "NVIDIA module loaded but nvidia-smi not found"
elif lsmod | grep -q "^amdgpu" 2>/dev/null; then
    pass "AMD GPU detected"
elif lsmod | grep -q "^i915" 2>/dev/null; then
    pass "Intel GPU detected"
else
    warn "Could not detect GPU driver"
fi
echo ""

# Resources
echo "  Resources"
local mem_total mem_used mem_pct
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_pct=$((mem_used * 100 / (mem_total + 1)))
if [[ ${mem_pct} -gt 80 ]]; then
    fail "Memory: ${mem_used}M / ${mem_total}M (${mem_pct}%)"
elif [[ ${mem_pct} -gt 60 ]]; then
    warn "Memory: ${mem_used}M / ${mem_total}M (${mem_pct}%)"
else
    pass "Memory: ${mem_used}M / ${mem_total}M (${mem_pct}%)"
fi

local disk_pct
disk_pct=$(df / | awk 'NR==2 {gsub(/%/,""); print $5}')
if [[ ${disk_pct} -gt 90 ]]; then
    fail "Disk root: ${disk_pct}% used"
elif [[ ${disk_pct} -gt 75 ]]; then
    warn "Disk root: ${disk_pct}% used"
else
    pass "Disk root: ${disk_pct}% used"
fi

local load; load=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null || echo "?")
pass "Load average: ${load}"
echo ""

# Config validation
echo "  Config Integrity"
config_exists ".config/hypr/hyprland.lua"
config_exists ".config/hypr/settings/keybinds.lua"
config_exists ".config/hypr/hyprlock.conf"
config_exists ".config/hypr/hypridle.conf"
config_exists ".config/waybar/config.jsonc"
config_exists ".config/waybar/style.css"
config_exists ".config/rofi/config.rasi"
config_exists ".config/kitty/kitty.conf"
config_exists ".local/bin/bn-menu"
echo ""

# Dotfiles repo
echo "  Dotfiles Repository"
if [[ -d "${REPO}/.git" ]]; then
    pass "Git repository found"
    local branch behind ahead
    branch=$(git -C "${REPO}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    behind=$(git -C "${REPO}" rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    ahead=$(git -C "${REPO}" rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    if [[ "${behind}" -gt 0 ]] && [[ "${behind}" != "0" ]]; then
        warn "Branch ${branch}: ${behind} commit(s) behind upstream — run 'git pull'"
    elif [[ "${ahead}" -gt 0 ]] && [[ "${ahead}" != "0" ]]; then
        warn "Branch ${branch}: ${ahead} commit(s) ahead of upstream"
    else
        pass "Branch ${branch}: up to date"
    fi
else
    fail "Not a git repository (${REPO})"
fi
echo ""

# Backup age
echo "  Backup Status"
local latest_backup
latest_backup=$(ls -1d "${HOME}/.config/blacknode-backup-"* 2>/dev/null | sort -r | head -1)
if [[ -n "${latest_backup}" ]]; then
    local age_days
    age_days=$((($(date +%s) - $(date -r "${latest_backup}" +%s)) / 86400))
    pass "Last backup: $(basename "${latest_backup}") (${age_days} days ago)"
else
    warn "No backup found (run linkdots.sh to create one)"
fi
echo ""

hr
echo ""
echo "  Results: ${CHECK_PASS} passed, ${CHECK_WARN} warnings, ${CHECK_FAIL} failed"
echo ""
