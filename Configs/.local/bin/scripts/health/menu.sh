#!/usr/bin/env bash

repo="${HOME}/BlackNode"
pass=0
warn=0
fail=0
out=()

ok()   { pass=$((pass+1));  out+=("  ok    $1"); }
bad()  { fail=$((fail+1));  out+=("  FAIL  $1"); }
wtf()  { warn=$((warn+1));  out+=("  warn  $1"); }

svc()  { systemctl is-active --quiet "$1" 2>/dev/null && ok "$1 running" || bad "$1 not running"; }
bin()  { command -v "$1" >/dev/null && ok "$1 found" || bad "$1 not found"; }

echo ""
echo "BlackNode System Health"
echo "------------------------"

echo ""; echo "Services"
svc NetworkManager
svc pipewire
svc systemd-logind

echo ""; echo "Session"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then ok "Hyprland session active"; else bad "not in a Hyprland session"; fi
bin hyprctl; bin hyprlock; bin waybar; bin rofi; bin kitty; bin awww; bin matugen

echo ""; echo "GPU"
if command -v nvidia-smi >/dev/null; then
    nv=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo unknown)
    ok "NVIDIA driver $nv"
elif lsmod 2>/dev/null | grep -q '^nvidia'; then wtf "nvidia module loaded, nvidia-smi missing"
elif lsmod 2>/dev/null | grep -q '^amdgpu'; then ok "AMD GPU"
elif lsmod 2>/dev/null | grep -q '^i915'; then ok "Intel GPU"
else wtf "GPU driver not detected"; fi

echo ""; echo "Resources"
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_pct=$((mem_used * 100 / (mem_total + 1)))
if [[ $mem_pct -gt 80 ]]; then bad "Memory ${mem_used}M/${mem_total}M (${mem_pct}%)"
elif [[ $mem_pct -gt 60 ]]; then wtf "Memory ${mem_used}M/${mem_total}M (${mem_pct}%)"
else ok "Memory ${mem_used}M/${mem_total}M (${mem_pct}%)"; fi

disk_pct=$(df / | awk 'NR==2 {gsub(/%/,""); print $5}')
if [[ $disk_pct -gt 90 ]]; then bad "Root disk ${disk_pct}% used"
elif [[ $disk_pct -gt 75 ]]; then wtf "Root disk ${disk_pct}% used"
else ok "Root disk ${disk_pct}% used"; fi

load=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null || echo "?")
ok "Load average $load"

echo ""; echo "Config"
for c in .config/hypr/hyprland.lua .config/hypr/settings/keybinds.lua \
         .config/hypr/hyprlock.conf .config/hypr/hypridle.conf \
         .config/waybar/config.jsonc .config/waybar/style.css \
         .config/rofi/config.rasi .config/kitty/kitty.conf .local/bin/bn-menu; do
    t="$HOME/$c"
    if [[ -L "$t" ]]; then
        link=$(readlink "$t")
        [[ -e "$link" ]] && ok "$c -> linked" || bad "$c -> broken symlink"
    elif [[ -e "$t" ]]; then ok "$c present"
    else bad "$c missing"; fi
done

echo ""; echo "Repository"
if [[ -d "$repo/.git" ]]; then
    ok "git repo present"
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
    behind=$(git -C "$repo" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
    ahead=$(git -C "$repo" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
    if [[ "$behind" -gt 0 ]]; then wtf "branch $branch: $behind behind (git pull)"
    elif [[ "$ahead" -gt 0 ]]; then wtf "branch $branch: $ahead ahead"
    else ok "branch $branch up to date"; fi
else bad "not a git repo ($repo)"; fi

echo ""
echo "------------------------"
echo "Results: $pass ok, $warn warn, $fail fail"
echo ""
