check_flags() {
    case " ${FLAGS} " in
        *" --help "*|*" -h "*)
            echo ""
            echo -e "  ${BOLD}Usage:${NC}  bash install.sh [flags]"
            echo ""
            dim "  --minimal     Skip optional packages and extras"
            dim "  --nvidia      Auto-select NVIDIA optimizations"
            dim "  --no-nvidia   Skip NVIDIA setup even if detected"
            dim "  --help        Show this message"
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

    if ! command -v pacman &>/dev/null; then
        err "This installer requires pacman (Arch Linux or derivative)."
        err "Detected: ${OS_NAME:-unknown}"
        exit 1
    fi

    case "${distro,,}" in
        arch|endeavouros|artix|manjaro|arcolinux|garuda|cachyos)
            ok "${OS_NAME} detected :: compatible"
            ;;
        *)
            warn "Unknown distro: ${OS_NAME:-$distro}"
            info "You have pacman, so trying to proceed..."
            if ! confirm "Continue anyway?" "N"; then
                err "Cancelled. BlackNode targets Arch-based distros."
                exit 1
            fi
            ;;
    esac
}

check_internet() {
    local hosts=(archlinux.org github.com aur.archlinux.org)
    local reachable=0
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "${host}" &>/dev/null; then
            reachable=1
            break
        fi
    done
    if [[ ${reachable} -eq 0 ]]; then
        err "No internet connection. Check your network."
        exit 1
    fi
    ok "Internet reachable"
}

check_pacman_lock() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        err "Pacman is locked (another package operation is running)."
        warn "Either wait, or remove the lock file if you're sure:"
        dim "  sudo rm /var/lib/pacman/db.lck"
        exit 1
    fi
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        info "Sudo access is needed for package installation."
        if ! sudo -v; then
            err "Sudo failed. Cannot continue."
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
        local name dst
        name=$(basename "${item}")
        dst="${HOME}/.config/${name}"
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
