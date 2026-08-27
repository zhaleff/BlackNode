#!/usr/bin/env bash
# BlackNode Installer — Fedora edition
# Port of Scripts/install.sh for Fedora (dnf). Original targets Arch/pacman.
# Usage: bash Scripts/install-fedora.sh [--minimal] [--nvidia] [--no-nvidia] [--help]

set -u
set -o pipefail

REPO="${HOME}/BlackNode"
BACKUP="${HOME}/.config/blacknode-backup-$(date +%Y%m%d%H%M%S)"
LOG="/tmp/blacknode-install.log"
FLAGS="${*}"
STEP=0
TOTAL_STEPS=11

BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PURPLE='\033[0;35m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; RED='\033[0;31m'; TEAL='\033[0;36m'
BG_PURPLE='\033[45m'; ORANGE='\033[38;5;208m'

# Package manager (Fedora 41+ ships dnf5 but keeps `dnf` as a symlink)
if command -v dnf &>/dev/null; then
    PM="dnf"
elif command -v dnf5 &>/dev/null; then
    PM="dnf5"
else
    PM="dnf"
fi
PKG_INSTALL="sudo ${PM} install -y"

ASSUME_YES=0

: > "$LOG"
log()  { echo "[$(date +%H:%M:%S)] ${*}" >> "$LOG"; }

header() {
    echo ""
    echo -e "  ${BG_PURPLE}${BOLD}  ${*}  ${NC}"
    echo ""
}

step() {
    STEP=$((STEP + 1))
    echo ""
    echo -e "  ${PURPLE}${BOLD}▸ ${STEP}/${TOTAL_STEPS}${NC}  ${BOLD}${*}${NC}"
    echo -e "  ${DIM}${PURPLE}────────────────────────────────────────${NC}"
    echo ""
}

info()  { echo -e "  ${BLUE}i${NC}  ${*}"; }
ok()    { echo -e "  ${GREEN}✔${NC}  ${*}"; }
warn()  { echo -e "  ${YELLOW}▲${NC}  ${*}"; }
err()   { echo -e "  ${RED}✖${NC}  ${*}"; }
dim()   { echo -e "  ${DIM}${*}${NC}"; }
hr()    { echo -e "  ${DIM}────────────────────────────────────────${NC}"; }
tip()   { echo -e "  ${ORANGE}☰${NC}  ${BOLD}TIP:${NC} ${*}"; }

confirm() {
    [[ "${ASSUME_YES}" -eq 1 ]] && { [[ "${2:-Y}" == "Y" ]] && return 0 || return 1; }
    local msg="${1}" default="${2:-Y}"
    local Yn="Y/n"; [[ "${default}" == "N" ]] && Yn="y/N"
    echo -ne "  ${TEAL}▸${NC} ${BOLD}${msg}${NC} ${DIM}[${Yn}]${NC} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    [[ "${ans}" =~ ^[Yy] ]]
}

choose() {
    [[ "${ASSUME_YES}" -eq 1 ]] && { echo "${2:-}"; return; }
    local msg="${1}" default="${2:-}" opts="${3:-}"
    local opt_hint=""
    [[ -n "${opts}" ]] && opt_hint=" ${DIM}(${opts})${NC}"
    echo -ne "  ${TEAL}▸${NC} ${BOLD}${msg}${NC}${opt_hint} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    echo "${ans}"
}

press_enter() {
    [[ "${ASSUME_YES}" -eq 1 ]] && return
    echo -ne "  ${DIM}Press ENTER to continue${NC} "
    read -r _
}

hint_for() {
    local cmd="${1}" rc="${2:-0}"
    case "${cmd}" in
        *dnf*|*rpm*)
            echo -e "  ${ORANGE}☰${NC}  DNF failed. Try:"
            echo -e "  ${ORANGE}☰${NC}  ${DIM}sudo dnf clean all && sudo dnf makecache${NC}"
            echo -e "  ${ORANGE}☰${NC}  ${DIM}sudo ${PM} check-update${NC}"
            ;;
        *chsh*)
            echo -e "  ${ORANGE}☰${NC}  chsh requires the shell to be in /etc/shells."
            echo -e "  ${ORANGE}☰${NC}  Fix: echo \$(which zsh) | sudo tee -a /etc/shells"
            ;;
        *git\ clone*)
            echo -e "  ${ORANGE}☰${NC}  Check your internet or github access."
            echo -e "  ${ORANGE}☰${NC}  Try: ${DIM}git clone --depth 1${NC}"
            ;;
        *systemctl*)
            echo -e "  ${ORANGE}☰${NC}  You may need to log out and back in."
            echo -e "  ${ORANGE}☰${NC}  Or try: ${DIM}sudo systemctl restart ${cmd##* }${NC}"
            ;;
        *akmods*|*dracut*)
            echo -e "  ${ORANGE}☰${NC}  NVIDIA kernel module build failed."
            echo -e "  ${ORANGE}☰${NC}  ${DIM}sudo akmods --force${NC}  then  ${DIM}sudo dracut --force${NC}"
            ;;
        *grub2-mkconfig*)
            echo -e "  ${ORANGE}☰${NC}  If grub2-mkconfig fails, update manually:"
            echo -e "  ${ORANGE}☰${NC}  ${DIM}sudo grub2-mkconfig -o /boot/grub2/grub.cfg${NC}"
            ;;
        *sddm*)
            echo -e "  ${ORANGE}☰${NC}  Fix SDDM: ${DIM}sudo systemctl enable --now sddm${NC}"
            ;;
        *) ;;
    esac
    echo -e "  ${ORANGE}☰${NC}  Need more help?  →  https://github.com/zhaleff/BlackNode/issues"
}

run() {
    local cmd="${*}" rc hint_shown=0
    log "$ ${cmd}"
    eval "${cmd}" 2>&1 | tee -a "${LOG}"; rc=${PIPESTATUS[0]}
    if [[ ${rc} -ne 0 ]]; then
        echo ""
        err "Command failed (exit ${rc})"
        dim "${cmd}"
        dim "Log: ${LOG}"
        [[ ${rc} -eq 126 ]] && dim "Caused by: permission denied"
        [[ ${rc} -eq 127 ]] && dim "Caused by: command not found"
        echo ""
        if [[ ${hint_shown} -eq 0 ]]; then
            hint_for "${cmd}" "${rc}"
            hint_shown=1
            echo ""
        fi
        if [[ "${ASSUME_YES}" -eq 1 ]]; then
            warn "Skipped (unattended mode): ${cmd}"
            return 1
        fi
        while true; do
            echo -ne "  ${YELLOW}?${NC}  ${BOLD}R${NC}etry  ${S}${NC}kip  ${BOLD}A${NC}bort  ${DIM}[R/s/a]${NC} "
            read -r choice
            case "${choice}" in
                [Rr]|"") run "${cmd}"; return ${?} ;;
                [Ss]) warn "Skipped"; return 1 ;;
                [Aa])
                    err "Aborted by user"
                    if confirm "Rollback config symlinks?" "N"; then rollback; fi
                    exit 1
                    ;;
            esac
        done
    fi
    return 0
}

check_flags() {
    case " ${FLAGS} " in
        *" --yes "*|*" -y "*)
            ASSUME_YES=1
            ;;
        *" --help "*|*" -h "*)
            echo ""
            echo -e "  ${BOLD}Usage:${NC}  bash install-fedora.sh [flags]"
            echo ""
            dim "  --minimal     Skip optional packages and extras"
            dim "  --nvidia      Auto-select NVIDIA optimizations"
            dim "  --no-nvidia   Skip NVIDIA setup even if detected"
            dim "  --help        Show this message"
            echo ""
            dim "Examples:"
            dim "  bash install-fedora.sh"
            dim "  bash install-fedora.sh --minimal"
            dim "  bash install-fedora.sh --nvidia"
            echo ""
            exit 0
            ;;
    esac
}

check_root() {
    if [[ ${EUID} -eq 0 ]]; then
        err "Don't run as root."
        err "Run as a normal user. sudo will be called when needed."
        exit 1
    fi
}

check_distro() {
    local distro=""
    if [[ -f /etc/os-release ]]; then
        distro=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    fi
    OS_NAME=$(grep ^NAME= /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    OS_ID="${distro}"

    if ! command -v "${PM}" &>/dev/null; then
        err "This installer requires dnf (Fedora or derivative)."
        err "Detected: ${OS_NAME:-unknown}"
        err "BlackNode Fedora edition targets Fedora 39+."
        exit 1
    fi

    case "${distro,,}" in
        fedora)
            ok "${OS_NAME} detected — compatible"
            ;;
        *)
            warn "Unknown distro: ${OS_NAME:-$distro}"
            info "You have ${PM}, so trying to proceed..."
            if ! confirm "Continue anyway?" "N"; then
                err "Cancelled. BlackNode Fedora edition targets Fedora."
                exit 1
            fi
            ;;
    esac
}

check_internet() {
    local hosts=(fedoraproject.org github.com)
    local ok=0
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "${host}" &>/dev/null; then
            ok=1
            break
        fi
    done
    if [[ ${ok} -eq 0 ]]; then
        err "No internet connection. Check your network."
        exit 1
    fi
    ok "Internet reachable"
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        info "Sudo access is needed for package installation."
        if ! sudo -v; then
            if [[ "${ASSUME_YES}" -eq 1 ]]; then
                warn "Sudo unavailable in unattended mode — package/DM steps will be skipped."
                return 0
            fi
            err "Sudo failed. Cannot continue."
            err "Make sure you have sudo rights:"
            dim "  sudo usermod -aG wheel $(whoami)"
            dim "  Then log out and back in."
            exit 1
        fi
    fi
    ok "Sudo access granted"
}

check_user_groups() {
    local missing=()
    for g in video input; do
        if ! groups | grep -qw "${g}"; then
            missing+=("${g}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "You are NOT in the following groups: ${missing[*]}"
        info "Hyprland may need these for keyboard/mouse/display access."
        info "Fix: sudo usermod -aG ${missing[*]} $(whoami)"
        if confirm "Continue anyway?"; then
            info "Log out after install to apply group changes."
        fi
    fi
}

check_disk_space() {
    local needed=3000000
    local avail
    avail=$(df "${HOME}" | awk 'NR==2 {print $4}')
    if [[ ${avail} -lt ${needed} ]]; then
        warn "Low disk space: $((avail / 1024))MB available in ${HOME}"
        info "Recommended: at least 3GB free."
        if ! confirm "Continue anyway?" "N"; then
            err "Free up space or install fewer packages."
            exit 1
        fi
    else
        ok "Disk space: $((avail / 1024))MB available"
    fi
}

check_existing_install() {
    local existing=0
    local found=""
    for item in "${REPO}/Configs/.config"/*; do
        local name; name=$(basename "${item}")
        local dst="${HOME}/.config/${name}"
        if [[ -L "${dst}" && "$(readlink "${dst}")" == "${item}" ]]; then
            existing=1
            found="${name}"
            break
        fi
    done
    if [[ ${existing} -eq 1 ]]; then
        warn "BlackNode configs already linked (${found})"
        if confirm "Re-link configs? (backups will be made)" "N"; then
            SKIP_LINK=0
        else
            info "Keeping existing links."
            SKIP_LINK=1
        fi
    else
        SKIP_LINK=0
    fi
}

detect_gpu() {
    GPU_VENDOR=""
    GPU_NAME=""
    if command -v lspci &>/dev/null; then
        local gpu_line
        gpu_line=$(lspci -nn 2>/dev/null | grep -iE "VGA|3D|Display" | head -1)
        GPU_NAME=$(echo "${gpu_line}" | sed 's/.*: //; s/ \[.*//')
        if echo "${gpu_line}" | grep -qi "NVIDIA"; then
            GPU_VENDOR="nvidia"
        elif echo "${gpu_line}" | grep -qiE "AMD|Radeon|ATI"; then
            GPU_VENDOR="amd"
        elif echo "${gpu_line}" | grep -qi "Intel"; then
            GPU_VENDOR="intel"
        elif [[ -f /sys/class/drm/card0/device/vendor ]]; then
            local ven; ven=$(cat /sys/class/drm/card0/device/vendor)
            case "${ven}" in
                0x10de) GPU_VENDOR="nvidia" ;;
                0x1002) GPU_VENDOR="amd" ;;
                0x8086) GPU_VENDOR="intel" ;;
            esac
        fi
    fi
    [[ -z "${GPU_VENDOR}" ]] && GPU_VENDOR="other"
    [[ -z "${GPU_NAME}" ]] && GPU_NAME="${GPU_VENDOR}"
}

detect_resolution() {
    MONITOR_RES=""
    MONITOR_NAME=""
    if command -v xrandr &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
        MONITOR_RES=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}' | head -1)
        MONITOR_NAME=$(xrandr 2>/dev/null | grep '*' | awk '{print $2}' | head -1)
    elif command -v hyprctl &>/dev/null; then
        MONITOR_RES=$(hyprctl monitors 2>/dev/null | grep -m1 "resolution" | awk '{print $2}')
    elif [[ -d /sys/class/drm ]]; then
        local mode_file
        mode_file=$(ls /sys/class/drm/*/modes 2>/dev/null | head -1)
        [[ -n "${mode_file}" ]] && MONITOR_RES=$(head -1 "${mode_file}" 2>/dev/null)
    fi
    if [[ -z "${MONITOR_RES}" ]]; then
        local edid
        edid=$(find /sys/class/drm -name "edid" 2>/dev/null | head -1)
        if [[ -n "${edid}" ]]; then
            MONITOR_RES=$(hexdump -s 54 -n 4 -e '2/2 "%d"' "${edid}" 2>/dev/null | awk '{print $1"x"$2}')
        fi
    fi
    [[ -z "${MONITOR_RES}" ]] && MONITOR_RES="unknown"
    [[ -z "${MONITOR_NAME}" ]] && MONITOR_NAME=""
}

detect_language() {
    SYS_LANG="${LANG:-${LC_ALL:-unknown}}"
    SYS_LOCALE="$(locale 2>/dev/null | grep LANG= | cut -d= -f2 | tr -d '\"')"
    [[ -z "${SYS_LOCALE}" ]] && SYS_LOCALE="${SYS_LANG}"
}

detect_desktop_env() {
    if [[ -z "${XDG_CURRENT_DESKTOP:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]] && [[ -z "${DISPLAY:-}" ]]; then
        warn "No desktop detected — you might be in a TTY."
        info "You can install from here, then reboot into Hyprland."
        if ! confirm "Continue with installation?" "N"; then
            warn "Cancelled. Run from a desktop environment."
            exit 0
        fi
    fi
}

rollback() {
    if [[ -d "${BACKUP}" ]]; then
        info "Restoring backups from ${BACKUP}..."
        if [[ -d "${BACKUP}/.config" ]]; then
            for item in "${BACKUP}/.config"/*; do
                local name; name=$(basename "${item}")
                local dst="${HOME}/.config/${name}"
                rm -f "${dst}"
                mv "${item}" "${dst}" 2>/dev/null
            done
        fi
        if [[ -d "${BACKUP}/.local/bin" ]]; then
            for item in "${BACKUP}/.local/bin"/*; do
                local name; name=$(basename "${item}")
                local dst="${HOME}/.local/bin/${name}"
                rm -f "${dst}"
                mv "${item}" "${dst}" 2>/dev/null
            done
        fi
        ok "Backups restored from: ${BACKUP}"
    else
        info "No backups to restore"
    fi
}

cleanup() {
    echo ""
    warn "Installation interrupted (Ctrl+C)"
    if confirm "Rollback config symlinks?" "N"; then rollback; fi
    info "Check the log: ${DIM}${LOG}"
    tip "Report issues: https://github.com/zhaleff/BlackNode/issues"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Build tools that don't ship in Fedora repos (Arch uses AUR for these).
# powerlevel10k = theme source (zsh sources ~/powerlevel10k)
# matugen       = Rust binary (crates.io)
# clipse        = Go binary (github.com/savedra1/clipse)
install_source_packages() {
    step "Source-built Tools (no Fedora package)"

    # --- powerlevel10k theme source ---
    if [[ -d "${HOME}/powerlevel10k" ]]; then
        ok "powerlevel10k already cloned at ~/powerlevel10k"
    else
        info "Cloning powerlevel10k theme to ~/powerlevel10k (zsh sources it)"
        run "git clone --depth 1 https://github.com/romkatv/powerlevel10k.git \"${HOME}/powerlevel10k\""
    fi

    # --- matugen (Material You colour generator) ---
    if command -v matugen &>/dev/null; then
        ok "matugen already installed"
    else
        if command -v cargo &>/dev/null; then
            info "Building matugen via cargo (this can take a few minutes)"
            if run "cargo install matugen"; then
                ok "matugen installed"
            else
                warn "matugen build failed — install later: cargo install matugen"
            fi
        else
            warn "Rust/Cargo not found. Install later: cargo install matugen"
            dim "  Fedora: sudo dnf install rust cargo"
        fi
    fi

    # --- clipse (clipboard history) ---
    if command -v clipse &>/dev/null; then
        ok "clipse already installed"
    else
        if command -v go &>/dev/null; then
            info "Building clipse via go install"
            if run "go install github.com/savedra1/clipse@latest"; then
                export PATH="${HOME}/go/bin:${PATH}"
                if [[ -x "${HOME}/go/bin/clipse" ]]; then
                    install -Dm755 "${HOME}/go/bin/clipse" "${HOME}/.local/bin/clipse"
                    ok "clipse installed to ~/.local/bin/clipse"
                else
                    ok "clipse installed to ~/go/bin"
                fi
            else
                warn "clipse build failed — install later: go install github.com/savedra1/clipse@latest"
            fi
        else
            warn "Go not found. Install clipse manually:"
            dim "  https://github.com/savedra1/clipse/releases"
            dim "  Fedora: sudo dnf install golang  (then re-run this step)"
        fi
    fi
}

install_core_packages() {
    step "Core Packages"

    # NOTE: gtk4-devel / libadwaita-devel are needed to build settings-center (Rust/gsk4),
    # and libXtst-devel / libX11-devel are needed to build clipse (X11 headers).
    local packages=(
        hyprland waybar rofi kitty neovim
        dunst hyprlock hypridle fastfetch yazi
        zsh fzf sddm gtk3 gtk4 jetbrains-mono-fonts
        gtk4-devel libadwaita-devel libXtst-devel libX11-devel
    )

    info "Required packages for BlackNode (Fedora names):"
    dim ""
    echo -e "  ${DIM}${packages[*]}${NC}"
    dim ""
    hr
    echo ""

    if [[ "${GPU_VENDOR}" == "nvidia" ]] && ! [[ " ${FLAGS} " == *" --no-nvidia "* ]]; then
        warn "NVIDIA GPU: ${GPU_NAME:-detected}"
        info "Fedora uses akmod-nvidia (handled in the NVIDIA step)."
    fi

    if confirm "Install core packages?"; then
        run "sudo ${PM} install -y ${packages[*]}"
        ok "Core packages installed"
    else
        warn "Core packages are required. Skipping will likely break things."
        if ! confirm "Really skip?" "N"; then
            run "sudo ${PM} install -y ${packages[*]}"
            ok "Core packages installed"
        else
            warn "Core packages skipped. You'll need to install them manually."
        fi
    fi

    local critical=(hyprland kitty)
    local missing=()
    for pkg in "${critical[@]}"; do
        if ! rpm -q "${pkg}" &>/dev/null; then
            missing+=("${pkg}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Critical packages missing: ${missing[*]}"
        info "BlackNode may not work without them."
    fi
}

install_optional_packages() {
    if [[ " ${FLAGS} " == *" --minimal "* ]]; then
        info "Skipping optional packages (--minimal mode)"
        return
    fi

    step "Optional Packages"

    echo -e "  ${DIM}playerctl      — media keys (play/pause/next)${NC}"
    echo -e "  ${DIM}brightnessctl  — brightness keys on laptops${NC}"
    echo -e "  ${DIM}wireplumber    — audio (strongly recommended)${NC}"
    echo -e "  ${DIM}grim + slurp   — screenshots${NC}"
    echo -e "  ${DIM}bluez + blueman — bluetooth${NC}"
    echo -e "  ${DIM}pamixer        — volume control${NC}"
    echo -e "  ${DIM}firefox        — browser (themes included)${NC}"
    echo ""

    if confirm "Install all optional packages?"; then
        run "sudo ${PM} install -y playerctl brightnessctl wireplumber grim slurp bluez bluez-utils blueman pamixer firefox"
        ok "Optional packages installed"
    else
        info "Install later per-package:"
        dim "  sudo dnf install <package-name>"
    fi
}

setup_nvidia() {
    [[ "${GPU_VENDOR}" != "nvidia" ]] && return
    [[ " ${FLAGS} " == *" --no-nvidia "* ]] && return

    step "NVIDIA Configuration (Fedora)"

    warn "NVIDIA GPU detected (${GPU_NAME:-unknown})"
    info "Fedora uses akmod-nvidia + dracut (not nvidia-dkms/mkinitcpio)."
    hr
    echo ""

    if ! rpm -q akmod-nvidia &>/dev/null; then
        info "Installing NVIDIA driver via RPM Fusion..."
        dim "  (requires RPM Fusion free/nonfree to be enabled)"
        if confirm "Enable RPM Fusion and install akmod-nvidia?"; then
            run "sudo ${PM} install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
            run "sudo ${PM} install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
            run "sudo ${PM} install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda"
            ok "NVIDIA driver packages installed"
        else
            warn "Skipping NVIDIA driver install."
        fi
    else
        ok "NVIDIA driver already installed"
    fi

    if rpm -q akmod-nvidia &>/dev/null; then
        info "Building kernel module and initramfs..."
        run "sudo akmods"
        run "sudo dracut --force"
        ok "Initramfs rebuilt with NVIDIA modules"
    fi

    local kdir="/etc/default/grub"
    if [[ -f "${kdir}" ]]; then
        if grep -q "nvidia_drm.modeset=1" "${kdir}"; then
            ok "nvidia_drm.modeset=1 already in GRUB"
        else
            info "Adding nvidia_drm.modeset=1 to GRUB..."
            sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia_drm.modeset=1 /' "${kdir}"
            if confirm "Run grub2-mkconfig now?"; then
                run "sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
            else
                dim "  Manual: sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
            fi
        fi
    else
        warn "GRUB config not found at ${kdir}; set nvidia_drm.modeset=1 manually."
    fi

    local env_file="${HOME}/.config/hypr/settings/env.lua"
    if ! grep -q "nvidia" "${env_file}" 2>/dev/null; then
        cat >> "${env_file}" << 'EOF'

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
EOF
        ok "NVIDIA env vars added to settings/env.lua"
    else
        ok "NVIDIA env vars already in env.lua"
    fi

    echo ""
    hr
    echo -e "  ${ORANGE}☰${NC}  ${BOLD}NVIDIA checklist:${NC}"
    dim "  • First launch may take a few seconds (shader compilation)"
    dim "  • If you get a black screen, reboot; then check: sudo akmods && sudo dracut --force"
    dim "  • Use env = WLR_NO_HARDWARE_CURSORS,1 if cursor is invisible"
    hr
    echo ""
    press_enter
}

setup_keyboard() {
    step "Keyboard Layout"

    info "System locale: ${SYS_LOCALE:-not set}"
    info "Default BlackNode layout: 'us,es' (US English + Spanish toggle)"
    echo ""

    if confirm "Change keyboard layout?" "N"; then
        local layout
        layout=$(choose "Layout code" "us" "e.g. us, es, latam, de, us,ru, br")
        if [[ -n "${layout}" ]]; then
            layout="${layout//[^a-z,A-Z0-9,_-]/}"
            if [[ -z "${layout}" ]]; then
                err "Invalid layout code"
                tip "Use something like: us, es, latam, de, us,ru, br"
                return
            fi
            local target="${REPO}/Configs/.config/hypr/settings/input.lua"
            if [[ -f "${target}" ]]; then
                sed -i "s/kb_layout = \".*\"/kb_layout = \"${layout}\"/" "${target}"
                ok "Keyboard layout set: ${layout}"
            else
                err "Can't find hyprland input config: ${target}"
                tip "You'll need to set kb_layout manually in hyprland.lua"
            fi
        fi
    else
        ok "Using default: us,es"
    fi

    if [[ -n "${SYS_LOCALE:-}" ]]; then
        local lang_code
        lang_code=$(echo "${SYS_LOCALE}" | cut -d_ -f1)
        if [[ "${lang_code}" != "en" ]] && [[ "${lang_code}" != "us" ]]; then
            info "Your system language is ${SYS_LOCALE}."
            info "If you want keybindings in your layout, set it later in:"
            dim "  ~/.config/hypr/settings/input.lua"
        fi
    fi
}

setup_resolution() {
    step "Display / Resolution"

    info "Detected: ${MONITOR_RES:-unknown}${MONITOR_NAME:+ (${MONITOR_NAME})}"

    if [[ "${MONITOR_RES}" == "unknown" ]] || [[ -z "${MONITOR_RES}" ]]; then
        info "Could not auto-detect resolution."
        tip "Edit ~/.config/hypr/settings/monitor.lua manually later."
        return
    fi

    local target="${REPO}/Configs/.config/hypr/settings/monitor.lua"
    if [[ ! -f "${target}" ]]; then
        info "No monitor config yet — auto-detected: ${MONITOR_RES}"
        if confirm "Write ${MONITOR_RES} to monitor settings?"; then
            mkdir -p "$(dirname "${target}")"
            cat > "${target}" << EOF
-- auto-configured by Fedora installer
monitor = ,${MONITOR_RES},auto,1
EOF
            ok "Monitor config written: ${target}"
        fi
    else
        ok "Monitor config exists: ${target}"
        if confirm "Update to ${MONITOR_RES}?" "N"; then
            sed -i "s/monitor = .*/monitor = ,${MONITOR_RES},auto,1/" "${target}"
            ok "Monitor resolution updated: ${MONITOR_RES}"
        fi
    fi
}

setup_shell() {
    step "Shell"

    if [[ "${SHELL}" == *"zsh"* ]]; then
        ok "ZSH is already your default shell"
        return
    fi

    info "BlackNode uses ZSH with powerlevel10k theme."
    echo ""

    if confirm "Make ZSH your default shell?"; then
        if ! command -v zsh &>/dev/null; then
            warn "ZSH not installed"
            if confirm "Install ZSH now?"; then
                run "sudo ${PM} install -y zsh"
            else
                warn "Shell not changed."
                dim "Manual: sudo dnf install zsh && chsh -s \$(which zsh)"
                return
            fi
        fi
        run "chsh -s $(which zsh)"
        ok "Default shell changed to ZSH"
        info "Log out and back in (or open a new terminal) to use ZSH."
    fi

    if [[ -f "${HOME}/.zshrc" && ! -L "${HOME}/.zshrc" ]]; then
        warn "Existing .zshrc found"
        if confirm "Back it up before linking BlackNode's?"; then
            cp "${HOME}/.zshrc" "${HOME}/.zshrc.blacknode-backup"
            ok "Backed up: .zshrc → .zshrc.blacknode-backup"
        fi
    fi
}

setup_wallpaper_dir() {
    step "Wallpaper Directory"

    local wp="${HOME}/Pictures/Wallpapers"
    if [[ -d "${wp}" ]]; then
        ok "Wallpaper directory exists: ${wp}"
        return
    fi

    if confirm "Create wallpaper directory?"; then
        run "mkdir -p \"${wp}\""
        ok "Created: ${wp}"
        tip "Set a wallpaper with: SUPER + W"
    else
        warn "No wallpaper directory. Create later: mkdir -p ~/Pictures/Wallpapers"
    fi
}

link_configs() {
    step "Link Configs"

    if [[ "${SKIP_LINK:-0}" -eq 1 ]]; then
        info "Configs already linked (skipping)"
        return
    fi

    warn "Existing configs will be backed up to:"
    dim "  ${BACKUP}"
    echo ""

    if ! confirm "Link BlackNode configs now?"; then
        warn "Manual: bash ${REPO}/Scripts/linkdots.sh"
        return
    fi

    # Delegamos el linkeo + build de los binarios Rust al script original,
    # que es distro-agnóstico (solo symlinks + cargo).
    if [[ -f "${REPO}/Scripts/linkdots.sh" ]]; then
        run "bash \"${REPO}/Scripts/linkdots.sh\""
    else
        err "linkdots.sh not found at ${REPO}/Scripts/linkdots.sh"
    fi
}

run_post_install() {
    step "Post-Install"

    if [[ -f /etc/systemd/system/display-manager.service ]]; then
        local dm; dm=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || echo "")
        if [[ "${dm}" != *sddm* ]]; then
            warn "Current display manager: $(basename "${dm}" 2>/dev/null || echo 'unknown')"
            info "BlackNode is styled for SDDM."
            if confirm "Switch to SDDM?"; then
                run "sudo systemctl enable --now sddm"
            fi
        else
            ok "SDDM is active"
        fi
    else
        info "No display manager enabled"
        if confirm "Enable SDDM?"; then
            run "sudo systemctl enable --now sddm"
        fi
    fi

    if command -v systemctl &>/dev/null; then
        if systemctl is-enabled bluetooth &>/dev/null; then
            ok "Bluetooth service enabled"
        elif confirm "Enable Bluetooth service?"; then
            run "sudo systemctl enable --now bluetooth"
        fi
    fi

    local profile_dir="${HOME}/.config/hypr/profiles"
    mkdir -p "${profile_dir}"
    if [[ ! -f "${profile_dir}/.active" ]]; then
        echo -n "default" > "${profile_dir}/.active"
        ok "Default profile set"
    fi

    if ! command -v pipewire &>/dev/null; then
        warn "PipeWire not found — audio may not work"
        info "Install: sudo dnf install pipewire pipewire-pulse wireplumber"
    fi

    if ! fc-list | grep -qi "JetBrains Mono" &>/dev/null; then
        warn "JetBrains Mono font not found — UI may look off"
        info "Install: sudo dnf install jetbrains-mono-fonts"
    fi
}

show_troubleshooting() {
    echo ""
    hr
    echo -e "  ${ORANGE}${BOLD}☰  Troubleshooting (Fedora)${NC}"
    hr
    echo ""
    dim "  ${BOLD}Hyprland won't start${NC}"
    dim "  • cat ~/.config/hypr/hyprland.lua"
    dim "  • Try: Hyprland (verbose)"
    dim "  • mv ~/.config/hypr/hyprland.lua{,.bak}"
    echo ""
    dim "  ${BOLD}No audio${NC}"
    dim "  • sudo dnf install pipewire pipewire-pulse wireplumber"
    dim "  • systemctl --user enable --now pipewire pipewire-pulse"
    echo ""
    dim "  ${BOLD}matugen / clipse missing${NC}"
    dim "  • matugen:  cargo install matugen"
    dim "  • clipse:  go install github.com/savedra1/clipse@latest"
    dim "  • p10k:    git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k"
    echo ""
    dim "  ${BOLD}Wallpapers not working${NC}"
    dim "  • Put images in ~/Pictures/Wallpapers/"
    dim "  • Run: ~/.config/rofi/scripts/wallselect.sh"
    echo ""
    dim "  ${BOLD}Bluetooth not working${NC}"
    dim "  • sudo systemctl enable --now bluetooth"
    echo ""
    dim "  ${BOLD}Weird keybindings${NC}"
    dim "  • Check: cat ~/.config/hypr/settings/input.lua"
    dim "  • Default: SUPER = Windows key, SUPER + SPACE = menu"
    echo ""
    dim "  ${BOLD}Need more help?${NC}"
    dim "  • Open an issue: https://github.com/zhaleff/BlackNode/issues"
    dim "  • Include the log: ${LOG}"
    echo ""
    press_enter
}

show_summary() {
    echo ""
    hr
    echo -e "  ${GREEN}${BOLD}✔  BlackNode is ready (Fedora)${NC}"
    hr
    echo ""
    echo -e "  ${BOLD}System${NC}       ${OS_NAME:-Fedora} / ${GPU_VENDOR} / ${MONITOR_RES:-auto}"
    echo -e "  ${BOLD}Configs${NC}      ${DIM}${HOME}/.config/ → BlackNode${NC}"
    echo -e "  ${BOLD}Backup${NC}       ${DIM}${BACKUP}${NC}"
    echo -e "  ${BOLD}Log${NC}          ${DIM}${LOG}${NC}"
    echo ""
    hr
    echo -e "  ${BOLD}Quick start:${NC}"
    echo ""
    echo -e "  ${BOLD}1${NC}  Log out → select Hyprland in SDDM"
    echo -e "  ${BOLD}2${NC}  Set wallpaper        ${DIM}SUPER + W${NC}"
    echo -e "  ${BOLD}3${NC}  Open BlackNode menu  ${DIM}SUPER + SPACE${NC}"
    echo -e "  ${BOLD}4${NC}  Browse keybinds      ${DIM}bn-menu → About → Keybinds${NC}"
    echo -e "  ${BOLD}5${NC}  Switch profiles      ${DIM}bn-menu → Profiles${NC}"
    echo ""
    hr
    echo -e "  ${PURPLE}${BOLD}⏣  Thanks for installing BlackNode${NC}"
    echo ""
}

main() {
    echo ""
    echo -e "  ${BG_PURPLE}${BOLD}  ⏣  BlackNode Fedora Installer  ${NC}"
    echo ""

    check_flags
    check_root
    check_distro
    check_internet
    check_sudo
    check_user_groups
    check_disk_space
    detect_gpu
    detect_resolution
    detect_language
    detect_desktop_env
    check_existing_install

    echo ""
    hr
    echo -e "  ${BOLD}System${NC}"
    dim "  OS:       ${OS_NAME:-unknown}"
    dim "  Kernel:   $(uname -r)"
    dim "  GPU:      ${GPU_NAME:-${GPU_VENDOR}}"
    dim "  Display:  ${MONITOR_RES:-unknown}"
    dim "  Lang:     ${SYS_LOCALE:-${SYS_LANG:-unknown}}"
    dim "  Shell:    ${SHELL}"
    dim "  Home:     ${HOME}"
    hr
    echo ""

    if [[ ! -d "${REPO}" ]]; then
        warn "BlackNode not cloned yet"
        if confirm "Clone BlackNode to ${REPO}?"; then
            run "git clone --depth 1 https://github.com/zhaleff/BlackNode.git \"${REPO}\""
        else
            err "Repository required. Clone manually:"
            dim "  git clone https://github.com/zhaleff/BlackNode.git \"${REPO}\""
            exit 1
        fi
    else
        ok "BlackNode repository found at ${REPO}"
    fi

    if ! confirm "Install BlackNode dotfiles (Fedora)?"; then
        warn "Cancelled"; exit 0
    fi

    TOTAL_STEPS=11
    [[ " ${FLAGS} " == *" --minimal "* ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))
    [[ "${GPU_VENDOR}" != "nvidia" ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))

    install_core_packages
    install_source_packages
    install_optional_packages
    setup_nvidia
    setup_keyboard
    setup_resolution
    setup_shell
    setup_wallpaper_dir
    link_configs
    run_post_install
    show_troubleshooting
    show_summary
}

main "$@"
