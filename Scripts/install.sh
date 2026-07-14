#!/usr/bin/env bash
#
# ⏣  BlackNode Installer  —  by zhaleff · HollowSec
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/zhaleff/BlackNode/master/Scripts/install.sh)
#   bash Scripts/install.sh          # if already cloned
#   bash Scripts/install.sh --minimal  # skip optional blocks
#   bash Scripts/install.sh --help     # show flags
#

set -u
set -o pipefail

# ──────────────────────────── Config ────────────────────────────

REPO="${HOME}/BlackNode"
BACKUP="${HOME}/.config/blacknode-backup-$(date +%Y%m%d%H%M%S)"
LOG="/tmp/blacknode-install.log"
FLAGS="${*}"
STEP=0
TOTAL_STEPS=9

# ──────────────────────────── Colors ────────────────────────────

BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PURPLE='\033[0;35m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; RED='\033[0;31m'; TEAL='\033[0;36m'
BG_PURPLE='\033[45m'

# ──────────────────────────── Logger ────────────────────────────

: > "$LOG"

log()  { echo "[$(date +%H:%M:%S)] ${*}" >> "$LOG"; }

# ──────────────────────────── UI Helpers ────────────────────────────

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

confirm() {
    local msg="${1}" default="${2:-Y}"
    local Yn="Y/n"; [[ "${default}" == "N" ]] && Yn="y/N"
    echo -ne "  ${TEAL}▸${NC} ${BOLD}${msg}${NC} ${DIM}[${Yn}]${NC} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    [[ "${ans}" =~ ^[Yy] ]]
}

choose() {
    local msg="${1}" default="${2:-}" opts="${3:-}"
    local opt_hint=""
    [[ -n "${opts}" ]] && opt_hint=" ${DIM}(${opts})${NC}"
    echo -ne "  ${TEAL}▸${NC} ${BOLD}${msg}${NC}${opt_hint} "
    read -r ans
    [[ -z "${ans}" ]] && ans="${default}"
    echo "${ans}"
}

press_enter() {
    echo -ne "  ${DIM}Press ENTER to continue${NC} "
    read -r _
}

# ──────────────────────────── Execution ────────────────────────────

run() {
    local cmd="${*}" rc
    log "$ ${cmd}"
    eval "${cmd}" 2>&1 | tee -a "${LOG}"
    rc=${PIPESTATUS[0]}
    if [[ ${rc} -ne 0 ]]; then
        echo ""
        err "Command failed (exit ${rc})"
        dim "${cmd}"
        dim "Log: ${LOG}"
        echo ""
        while true; do
            echo -ne "  ${YELLOW}?${NC}  ${BOLD}R${NC}etry  ${BOLD}S${NC}kip  ${BOLD}A${NC}bort  ${DIM}[R/s/a]${NC} "
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

spinner() {
    # Simple spinner while a command runs — fallback to no-op if not interactive
    local msg="${1}" pid
    shift
    log "SPINNER: ${*}"
    eval "${*}" &
    pid=${!}
    local spin='-\|/'
    local i=0
    while kill -0 "${pid}" 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r  ${BLUE}i${NC}  ${msg} ${spin:${i}:1}"
        sleep 0.15
    done
    wait "${pid}"
    printf "\r  ${GREEN}✔${NC}  ${msg} done    \n"
    return ${?}
}

# ──────────────────────────── Pre-flight ────────────────────────────

check_flags() {
    case " ${FLAGS} " in
        *" --help "*|*" -h "*)
            echo ""
            echo -e "  ${BOLD}Usage:${NC}  bash install.sh [flags]"
            echo ""
            echo "  --minimal     Skip optional packages and extras"
            echo "  --nvidia      Auto-select NVIDIA optimizations"
            echo "  --no-nvidia   Skip NVIDIA setup even if detected"
            echo "  --help        Show this message"
            echo ""
            exit 0
            ;;
    esac
}

check_root() {
    if [[ ${EUID} -eq 0 ]]; then
        err "Don't run as root. Run as a normal user (sudo will be called when needed)."
        exit 1
    fi
}

check_distro() {
    if ! command -v pacman &>/dev/null; then
        err "This installer is for Arch Linux and derivatives only."
        exit 1
    fi
}

check_internet() {
    if ! ping -c 1 -W 3 archlinux.org &>/dev/null && \
       ! ping -c 1 -W 3 github.com &>/dev/null; then
        err "No internet connection. Check your network and try again."
        exit 1
    fi
    ok "Internet reachable"
}

check_pacman_lock() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        err "Pacman is locked (another package operation is running)."
        warn "Wait for it to finish, or remove the lock file:"
        dim "  sudo rm /var/lib/pacman/db.lck"
        exit 1
    fi
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        info "Sudo access required for package installation."
        if ! sudo -v; then
            err "Sudo failed. Cannot continue."
            exit 1
        fi
    fi
    ok "Sudo access granted"
}

check_existing_install() {
    local existing=0
    local msg=""
    for item in "${REPO}/Configs/.config"/*; do
        local name; name=$(basename "${item}")
        local dst="${HOME}/.config/${name}"
        if [[ -L "${dst}" && "$(readlink "${dst}")" == "${item}" ]]; then
            existing=1
            msg="${name}"
        fi
    done
    if [[ ${existing} -eq 1 ]]; then
        warn "Existing BlackNode configs detected (${msg})"
        if confirm "Re-link configs? (backups will be made)" "N"; then
            return 0
        else
            warn "Skipping config linking"
            SKIP_LINK=1
        fi
    fi
}

detect_gpu() {
    GPU_VENDOR=""
    if [[ -f /sys/class/drm/card0/device/vendor ]]; then
        local ven; ven=$(cat /sys/class/drm/card0/device/vendor)
        case "${ven}" in
            0x10de) GPU_VENDOR="nvidia" ;;
            0x1002) GPU_VENDOR="amd" ;;
            0x8086) GPU_VENDOR="intel" ;;
        esac
    fi
    if lspci -nn 2>/dev/null | grep -qi "VGA.*NVIDIA"; then
        GPU_VENDOR="nvidia"
    fi
    if lspci -nn 2>/dev/null | grep -qi "VGA.*AMD\|VGA.*Radeon"; then
        [[ "${GPU_VENDOR}" != "nvidia" ]] && GPU_VENDOR="amd"
    fi
    if [[ -z "${GPU_VENDOR}" ]]; then
        GPU_VENDOR="other"
    fi
}

detect_desktop_env() {
    if [[ -z "${XDG_CURRENT_DESKTOP:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
        warn "No desktop detected — you might be in a TTY."
        info "It's recommended to install from within an existing desktop."
        info "If you continue, reboot into Hyprland after installation."
        if ! confirm "Continue anyway?" "N"; then
            warn "Cancelled"; exit 0
        fi
    fi
}

# ──────────────────────────── Rollback ────────────────────────────

rollback() {
    if [[ -d "${BACKUP}" ]]; then
        info "Restoring backups from ${BACKUP}..."
        if [[ -d "${BACKUP}/.config" ]]; then
            for item in "${BACKUP}/.config"/*; do
                local name; name=$(basename "${item}")
                local dst="${HOME}/.config/${name}"
                rm -f "${dst}"
                mv "${item}" "${dst}"
            done
        fi
        if [[ -d "${BACKUP}/.local/bin" ]]; then
            for item in "${BACKUP}/.local/bin"/*; do
                local name; name=$(basename "${item}")
                local dst="${HOME}/.local/bin/${name}"
                rm -f "${dst}"
                mv "${item}" "${dst}"
            done
        fi
        ok "Backups restored (${BACKUP})"
    else
        info "No backups to restore"
    fi
}

cleanup() {
    echo ""
    warn "Installation interrupted"
    if confirm "Rollback config symlinks?" "N"; then rollback; fi
    exit 1
}

trap cleanup SIGINT SIGTERM

# ──────────────────────────── Steps ────────────────────────────

install_aur_helper() {
    step "AUR Helper"
    info "BlackNode needs an AUR helper (yay or paru) for some packages."
    hr
    echo ""
    info "Pick one:"
    dim "  yay   — most common, written in Go"
    dim "  paru  — modern, written in Rust"
    echo ""

    local pick
    pick=$(choose "Which AUR helper?" "yay" "yay / paru")
    case "${pick}" in
        yay|Yay|YAY) AUR="yay" ;;
        paru|Paru|PARU) AUR="paru" ;;
        *) warn "Unknown choice, defaulting to yay"; AUR="yay" ;;
    esac

    info "Installing ${AUR} (needs base-devel + git)"
    run "sudo pacman -S --needed --noconfirm base-devel git"
    run "git clone https://aur.archlinux.org/${AUR}.git /tmp/${AUR}"
    run "(cd /tmp/${AUR} && makepkg -si --noconfirm)"
    cd "${REPO}"

    if command -v "${AUR}" &>/dev/null; then
        ok "${AUR} ready"
    else
        err "${AUR} installation failed"
        warn "You can install it manually later:"
        dim "  git clone https://aur.archlinux.org/${AUR}.git && cd ${AUR} && makepkg -si"
        AUR=""
        if ! confirm "Continue without AUR helper?"; then exit 1; fi
    fi
}

install_core_packages() {
    step "Core Packages"

    local packages=(
        hyprland waybar rofi-wayland kitty neovim
        dunst hyprlock hypridle fastfetch yazi
        zsh fzf matugen sddm gtk3 gtk4 ttf-jetbrains-mono
    )

    info "These packages are required for BlackNode:"
    dim ""
    echo -e "  ${DIM}${packages[*]}${NC}"
    dim ""
    hr
    echo ""

    # NVIDIA override
    if [[ "${GPU_VENDOR}" == "nvidia" ]] && ! [[ " ${FLAGS} " == *" --no-nvidia "* ]]; then
        warn "NVIDIA GPU detected"
        info "You can use the standard hyprland (XWayland + NVIDIA works) or"
        info "install hyprland-nvidia-git (AUR) with NVIDIA patches baked in."
        echo ""
        if confirm "Use hyprland-nvidia-git instead of hyprland?"; then
            packages=("${packages[@]/hyprland/hyprland-nvidia-git}")
            NVIDIA_SETUP=1
        fi
    fi

    if confirm "Install core packages?"; then
        run "sudo pacman -S --needed --noconfirm ${packages[*]}"
        ok "Core packages installed"
    else
        warn "Core packages are required for BlackNode. Skipping may break things."
        if ! confirm "Really skip?" "N"; then
            run "sudo pacman -S --needed --noconfirm ${packages[*]}"
            ok "Core packages installed"
        else
            warn "Skipped core packages"
        fi
    fi
}

install_aur_packages() {
    step "AUR Packages"

    local aur_pkgs=(wlogout clipse-bin powerlevel10k-git)
    if [[ "${NVIDIA_SETUP:-0}" -eq 1 ]] && ! [[ " ${packages[*]} " == *" hyprland-nvidia-git "* ]]; then
        aur_pkgs+=(hyprland-nvidia-git)
    fi

    if [[ -z "${AUR:-}" ]]; then
        warn "No AUR helper available"
        if confirm "Install one now?"; then
            install_aur_helper
        fi
        if [[ -z "${AUR:-}" ]]; then
            dim "Manual install later:"
            dim "  ${AUR:-yay} -S ${aur_pkgs[*]}"
            return
        fi
    fi

    info "AUR packages:"
    dim "  ${aur_pkgs[*]}"
    echo ""

    if confirm "Install AUR packages?"; then
        run "${AUR} -S --needed --noconfirm ${aur_pkgs[*]}"
        ok "AUR packages installed"
    else
        dim "Skip or later: ${AUR} -S ${aur_pkgs[*]}"
    fi
}

install_optional_packages() {
    if [[ " ${FLAGS} " == *" --minimal "* ]]; then
        SKIP_OPTIONAL=1
    fi

    if [[ "${SKIP_OPTIONAL:-0}" -eq 1 ]]; then
        info "Skipping optional packages (--minimal mode)"
        return
    fi

    step "Optional Packages"

    echo -e "  ${DIM}playerctl      — media keys${NC}"
    echo -e "  ${DIM}brightnessctl  — brightness keys${NC}"
    echo -e "  ${DIM}wireplumber    — audio (recommended)${NC}"
    echo -e "  ${DIM}grim + slurp   — screenshots${NC}"
    echo -e "  ${DIM}pacman-contrib — update count in waybar${NC}"
    echo -e "  ${DIM}bluez + blueman — bluetooth${NC}"
    echo -e "  ${DIM}pamixer        — volume in waybar${NC}"
    echo -e "  ${DIM}firefox        — browser${NC}"
    echo ""

    if confirm "Install all optional packages?"; then
        run "sudo pacman -S --needed --noconfirm playerctl brightnessctl wireplumber grim slurp pacman-contrib bluez bluez-utils blueman pamixer firefox"
        ok "Optional packages installed"
    else
        info "Install later per-package as needed:"
        dim "  sudo pacman -S playerctl brightnessctl wireplumber grim slurp pacman-contrib bluez blueman pamixer firefox"
    fi
}

setup_nvidia() {
    [[ "${GPU_VENDOR}" != "nvidia" ]] && return
    [[ " ${FLAGS} " == *" --no-nvidia "* ]] && return

    step "NVIDIA Configuration"

    warn "NVIDIA GPU detected — additional setup recommended"

    # nvidia-dkms or nvidia-open-dkms
    if ! pacman -Q nvidia-dkms nvidia-open-dkms 2>/dev/null; then
        info "You need NVIDIA drivers."
        echo ""
        local nv_pkg
        nv_pkg=$(choose "Which driver?" "nvidia-dkms" "nvidia-dkms / nvidia-open-dkms")
        case "${nv_pkg}" in
            *open*) nv_pkg="nvidia-open-dkms" ;;
            *) nv_pkg="nvidia-dkms" ;;
        esac
        run "sudo pacman -S --needed --noconfirm ${nv_pkg} nvidia-utils"
    else
        ok "NVIDIA drivers already installed"
    fi

    # mkinitcpio nvidia modules
    info "Adding NVIDIA modules to mkinitcpio..."
    local modconf="/etc/mkinitcpio.conf"
    if [[ -f "${modconf}" ]]; then
        if grep -q "^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm" "${modconf}"; then
            ok "NVIDIA modules already in mkinitcpio.conf"
        else
            sudo sed -i 's/^MODULES=(/&nvidia nvidia_modeset nvidia_uvm nvidia_drm /' "${modconf}"
            run "sudo mkinitcpio -P"
        fi
    fi

    # Kernel parameter for DRM modeset
    info "Ensuring nvidia_drm.modeset=1 is set..."
    local kdir="/etc/default/grub"
    if [[ -f "${kdir}" ]]; then
        if grep -q "nvidia_drm.modeset=1" "${kdir}"; then
            ok "Already set in GRUB"
        else
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia_drm.modeset=1 /' "${kdir}"
            warn "GRUB config updated — run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
        fi
    fi

    # Hyprland env vars for NVIDIA
    local env_file="${HOME}/.config/hypr/env/nvidia.conf"
    mkdir -p "$(dirname "${env_file}")"
    if [[ ! -f "${env_file}" ]]; then
        cat > "${env_file}" << 'EOF'
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
EOF
        ok "NVIDIA env vars created at ${env_file}"
        info "Add this to hyprland.conf if not already:"
        dim "  source = ~/.config/hypr/env/nvidia.conf"
    else
        ok "NVIDIA env vars already exist"
    fi

    echo ""
    info "NVIDIA notes:"
    dim "  • The first launch may take a few seconds"
    dim "  • If you get blank screen, try removing 'nvidia' from MODULES in mkinitcpio.conf"
    dim "  • Use 'nvidia-offload' for apps that need the dGPU"
}

setup_keyboard() {
    step "Keyboard Layout"
    info "Default layout: 'us,es' — US English with Spanish toggle"
    if confirm "Change keyboard layout?" "N"; then
        local layout
        layout=$(choose "Layout code" "us" "e.g. us, es, latam, de, us,ru")
        if [[ -n "${layout}" ]]; then
            sed -i "s/kb_layout = \".*\"/kb_layout = \"${layout}\"/" \
                "${REPO}/Configs/.config/hypr/settings/input.lua"
            ok "Keyboard layout: ${layout}"
        fi
    else
        ok "Using default layout"
    fi
}

setup_shell() {
    step "Shell"

    if [[ "${SHELL}" == *"zsh"* ]]; then
        ok "ZSH is already your default shell"
        return
    fi

    info "BlackNode uses ZSH with powerlevel10k theme."
    info "Changing the shell only affects new terminals."
    echo ""

    if confirm "Make ZSH your default shell?"; then
        if ! command -v zsh &>/dev/null; then
            warn "ZSH is not installed (should be in core packages)"
            if confirm "Install ZSH now?"; then
                run "sudo pacman -S --noconfirm zsh"
            else
                warn "Shell not changed. Do it later:"
                dim "  sudo pacman -S zsh && chsh -s \$(which zsh)"
                return
            fi
        fi
        run "chsh -s $(which zsh)"
        ok "Default shell changed to ZSH"
        info "Log out and back in (or open a new terminal) to see the change."
    fi
}

setup_wallpaper_dir() {
    step "Wallpaper Directory"

    local wp="${HOME}/Pictures/Wallpapers"
    if [[ -d "${wp}" ]]; then
        ok "Wallpaper directory already exists: ${wp}"
        return
    fi

    if confirm "Create wallpaper directory?"; then
        run "mkdir -p \"${wp}\""
        ok "Created: ${wp}"
        info "Place wallpapers there, then set one with:"
        dim "  ~/.config/rofi/scripts/wallselect.sh"
        info "Or use SUPER + W to launch the wallpaper selector."
    else
        warn "No wallpaper directory. You can create it later."
    fi
}

link_configs() {
    step "Link Configs"

    if [[ "${SKIP_LINK:-0}" -eq 1 ]]; then
        warn "Skipping config linking (already linked)"
        return
    fi

    warn "Configs in ~/.config/ will be backed up to:"
    dim "  ${BACKUP}"
    echo ""

    if ! confirm "Link configs now?"; then
        warn "Manual: bash ${REPO}/Scripts/linkdots.sh"
        return
    fi

    local item name dst linked=0 backed=0 skipped=0

    for item in "${REPO}/Configs/.config"/*; do
        name=$(basename "${item}"); dst="${HOME}/.config/${name}"
        if [[ -L "${dst}" && "$(readlink "${dst}")" == "${item}" ]]; then
            skipped=$((skipped + 1))
            continue
        fi
        if [[ -e "${dst}" || -L "${dst}" ]]; then
            mkdir -p "${BACKUP}/.config"
            mv "${dst}" "${BACKUP}/.config/${name}"
            backed=$((backed + 1))
        fi
        ln -sf "${item}" "${dst}" && linked=$((linked + 1))
    done

    for item in "${REPO}/Configs/.local/bin"/*; do
        name=$(basename "${item}"); dst="${HOME}/.local/bin/${name}"
        if [[ -L "${dst}" && "$(readlink "${dst}")" == "${item}" ]]; then
            skipped=$((skipped + 1))
            continue
        fi
        if [[ -e "${dst}" || -L "${dst}" ]]; then
            mkdir -p "${BACKUP}/.local/bin"
            mv "${dst}" "${BACKUP}/.local/bin/${name}"
            backed=$((backed + 1))
        fi
        ln -sf "${item}" "${dst}" && linked=$((linked + 1))
    done

    ok "${linked} linked, ${backed} backed up, ${skipped} already up-to-date"

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        warn "${HOME}/.local/bin is not in PATH"
        info "Add this to your shell rc file:"
        dim "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

run_post_install() {
    step "Post-Install"

    # SDDM
    if [[ -f /etc/systemd/system/display-manager.service ]]; then
        local dm; dm=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || echo "")
        if [[ "${dm}" != *sddm* ]]; then
            warn "Current display manager is not SDDM"
            if confirm "Enable SDDM as display manager?"; then
                run "sudo systemctl enable --now sddm"
            fi
        else
            ok "SDDM is active"
        fi
    else
        info "No display manager detected"
        if confirm "Enable SDDM?"; then
            run "sudo systemctl enable --now sddm"
        fi
    fi

    # Bluetooth
    if command -v systemctl &>/dev/null; then
        if systemctl is-enabled bluetooth &>/dev/null; then
            ok "Bluetooth service already enabled"
        elif confirm "Enable Bluetooth service?"; then
            run "sudo systemctl enable --now bluetooth"
        fi
    fi

    # Default profile
    local profile_dir="${HOME}/.config/hypr/profiles"
    mkdir -p "${profile_dir}"
    if [[ ! -f "${profile_dir}/.active" ]]; then
        echo -n "default" > "${profile_dir}/.active"
        ok "Default profile set"
    fi

    # PipeWire (common issue: not installed)
    if ! command -v pipewire &>/dev/null; then
        warn "PipeWire not found — audio may not work"
        info "Install: sudo pacman -S pipewire pipewire-pulse wireplumber"
    fi
}

show_summary() {
    echo ""
    hr
    echo -e "  ${GREEN}${BOLD}✔  BlackNode is ready${NC}"
    hr
    echo ""
    echo -e "  ${BOLD}Configs${NC}    ${DIM}${HOME}/.config/ symlinked${NC}"
    echo -e "  ${BOLD}Backup${NC}     ${DIM}${BACKUP}${NC}"
    echo -e "  ${BOLD}Log${NC}        ${DIM}${LOG}${NC}"
    echo ""
    hr
    echo -e "  ${BOLD}Next steps:${NC}"
    echo ""
    echo -e "  ${BOLD}1${NC}  Log out and select Hyprland in SDDM"
    echo -e "  ${BOLD}2${NC}  Set wallpaper        ${DIM}SUPER + W${NC}"
    echo -e "  ${BOLD}3${NC}  Open BlackNode menu  ${DIM}SUPER + SPACE${NC}"
    echo -e "  ${BOLD}4${NC}  Browse keybinds      ${DIM}bn-menu → About → Keybinds${NC}"
    echo -e "  ${BOLD}5${NC}  Switch profiles      ${DIM}bn-menu → Profiles${NC}"
    echo ""
    hr
    echo -e "  ${DIM}Issues: https://github.com/zhaleff/BlackNode/issues${NC}"
    echo -e "  ${DIM}Help:   https://discord.gg/hollowsec${NC}"
    echo ""
    echo -e "  ${PURPLE}${BOLD}⏣  Thanks for installing BlackNode${NC}  ${DIM}— zhaleff${NC}"
    echo ""
}

# ──────────────────────────── Main ────────────────────────────

main() {
    echo ""
    echo -e "  ${BG_PURPLE}${BOLD}  ⏣  BlackNode Installer  ${NC}"
    echo -e "  ${DIM}  by zhaleff · HollowSec${NC}"
    echo ""

    # Pre-flight
    check_flags
    check_root
    check_distro
    check_internet
    check_pacman_lock
    check_sudo
    detect_gpu
    detect_desktop_env

    echo ""
    hr
    echo -e "  ${BOLD}System info:${NC}"
    dim "  OS:       $(grep ^NAME= /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"')"
    dim "  Kernel:   $(uname -r)"
    dim "  GPU:      ${GPU_VENDOR}"
    dim "  Shell:    ${SHELL}"
    hr
    echo ""

    if [[ ! -d "${REPO}" ]]; then
        warn "BlackNode not cloned yet"
        if confirm "Clone BlackNode to ${REPO}?"; then
            run "git clone https://github.com/zhaleff/BlackNode.git \"${REPO}\""
        else
            err "BlackNode repository required. Clone it:"
            dim "  git clone https://github.com/zhaleff/BlackNode.git \"${REPO}\""
            exit 1
        fi
    else
        ok "BlackNode repository found at ${REPO}"
    fi

    if ! confirm "Install BlackNode dotfiles?"; then
        warn "Cancelled"; exit 0
    fi

    # Detect AUR helper
    AUR=$(command -v yay &>/dev/null && echo "yay" || command -v paru &>/dev/null && echo "paru" || echo "")

    # Reset step counter with actual total
    TOTAL_STEPS=9
    [[ -n "${AUR}" ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))   # skip AUR helper step
    [[ " ${FLAGS} " == *" --minimal "* ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))

    # Run install blocks
    if [[ -z "${AUR}" ]]; then install_aur_helper; fi
    install_core_packages
    install_aur_packages
    install_optional_packages
    setup_nvidia
    setup_keyboard
    setup_shell
    setup_wallpaper_dir
    link_configs
    run_post_install
    show_summary
}

main "$@"
