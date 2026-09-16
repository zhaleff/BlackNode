install_aur_helper() {
    step "AUR Helper"

    info "BlackNode needs yay or paru for AUR packages."
    hr
    echo ""
    info "Pick one:"
    dim "  yay   :: most common, written in Go"
    dim "  paru  :: modern, written in Rust"
    echo ""

    local pick
    pick=$(choose "Which AUR helper?" "yay" "yay / paru")
    case "${pick}" in
        yay|Yay|YAY) AUR="yay" ;;
        paru|Paru|PARU) AUR="paru" ;;
        *) warn "Unknown choice, using yay"; AUR="yay" ;;
    esac

    info "Installing ${AUR} (needs base-devel + git)"
    run "sudo pacman -S --needed --noconfirm base-devel git"

    [[ -d "/tmp/${AUR}" ]] && rm -rf "/tmp/${AUR}"

    run "git clone --depth 1 https://aur.archlinux.org/${AUR}.git /tmp/${AUR}"
    run "(cd /tmp/${AUR} && makepkg -si --noconfirm)"
    cd "${REPO}" || { err "Can't find ${REPO}"; exit 1; }

    if command -v "${AUR}" &>/dev/null; then
        ok "${AUR} ready"
    else
        err "${AUR} installation failed"
        warn "Manual install:"
        dim "  git clone https://aur.archlinux.org/${AUR}.git"
        dim "  cd ${AUR} && makepkg -si"
        AUR=""
        if ! confirm "Continue without AUR helper?"; then
            err "Can't proceed without AUR helper."
            exit 1
        fi
    fi
}

install_core_packages() {
    step "Core Packages"

    local packages
    mapfile -t packages < <(pkg_list core)

    info "Required packages for BlackNode:"
    dim ""
    echo -e "  ${DIM}${packages[*]}${NC}"
    dim ""
    hr
    echo ""

    if [[ "${GPU_VENDOR}" == "nvidia" ]] && ! [[ " ${FLAGS} " == *" --no-nvidia "* ]]; then
        local nvidia_replacement
        nvidia_replacement=$(pkg_value nvidia.hyprland_replacement)
        warn "NVIDIA GPU: ${GPU_NAME:-detected}"
        info "Standard hyprland works with NVIDIA via XWayland."
        info "Or install ${nvidia_replacement} (AUR) with NVIDIA patches."
        echo ""
        if confirm "Use ${nvidia_replacement} instead of hyprland?"; then
            packages=("${packages[@]/hyprland/${nvidia_replacement}}")
            NVIDIA_SETUP=1
        fi
    fi

    if confirm "Install core packages?"; then
        run "sudo pacman -S --needed --noconfirm ${packages[*]}"
        ok "Core packages installed"
    else
        warn "Core packages are required. Skipping will likely break things."
        if ! confirm "Really skip?" "N"; then
            run "sudo pacman -S --needed --noconfirm ${packages[*]}"
            ok "Core packages installed"
        else
            warn "Core packages skipped. You'll need to install them manually."
        fi
    fi

    local critical missing=()
    mapfile -t critical < <(pkg_list critical)
    for pkg in "${critical[@]}"; do
        pacman -Q "${pkg}" &>/dev/null || missing+=("${pkg}")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Critical packages missing: ${missing[*]}"
        info "BlackNode may not work without them."
    fi
}

install_aur_packages() {
    step "AUR Packages"

    local aur_pkgs
    mapfile -t aur_pkgs < <(pkg_list aur)

    if [[ "${NVIDIA_SETUP:-0}" -eq 1 ]]; then
        aur_pkgs+=("$(pkg_value nvidia.hyprland_replacement)")
    fi

    if [[ -z "${AUR:-}" ]]; then
        warn "No AUR helper available"
        if confirm "Install one now?"; then
            install_aur_helper
        fi
        if [[ -z "${AUR:-}" ]]; then
            dim "Install manually:"
            dim "  yay -S ${aur_pkgs[*]}"
            return
        fi
    fi

    info "AUR packages needed:"
    dim "  ${aur_pkgs[*]}"
    echo ""

    if confirm "Install AUR packages?"; then
        run "${AUR} -S --needed --noconfirm ${aur_pkgs[*]}"
        ok "AUR packages installed"
    else
        dim "Install later: ${AUR} -S ${aur_pkgs[*]}"
    fi
}

install_optional_packages() {
    if [[ " ${FLAGS} " == *" --minimal "* ]]; then
        info "Skipping optional packages (--minimal mode)"
        return
    fi

    step "Optional Packages"

    echo -e "  ${DIM}playerctl      :: media keys (play/pause/next)${NC}"
    echo -e "  ${DIM}brightnessctl  :: brightness keys on laptops${NC}"
    echo -e "  ${DIM}wireplumber    :: audio (strongly recommended)${NC}"
    echo -e "  ${DIM}grim + slurp   :: screenshots${NC}"
    echo -e "  ${DIM}pacman-contrib :: update count in waybar${NC}"
    echo -e "  ${DIM}bluez + blueman :: bluetooth${NC}"
    echo -e "  ${DIM}pamixer        :: volume control${NC}"
    echo -e "  ${DIM}firefox        :: browser (themes included)${NC}"
    echo ""

    local optional
    mapfile -t optional < <(pkg_list optional)

    if confirm "Install all optional packages?"; then
        run "sudo pacman -S --needed --noconfirm ${optional[*]}"
        ok "Optional packages installed"
    else
        info "Install later per-package:"
        dim "  sudo pacman -S <package-name>"
    fi
}
