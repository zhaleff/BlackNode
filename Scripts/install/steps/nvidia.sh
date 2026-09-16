setup_nvidia() {
    [[ "${GPU_VENDOR}" != "nvidia" ]] && return
    [[ " ${FLAGS} " == *" --no-nvidia "* ]] && return

    step "NVIDIA Configuration"

    warn "NVIDIA GPU detected (${GPU_NAME:-unknown})"
    info "Setting up NVIDIA for Hyprland..."
    hr
    echo ""

    if ! pacman -Q nvidia-dkms nvidia-open-dkms 2>/dev/null; then
        info "Choose your NVIDIA driver:"
        dim "  nvidia-dkms      :: proprietary, works on all GPUs"
        dim "  nvidia-open-dkms :: open source, for Turing+ (RTX 2000+)"
        echo ""
        local nv_pkg
        nv_pkg=$(choose "Which driver?" "nvidia-dkms" "nvidia-dkms / nvidia-open-dkms")
        [[ "${nv_pkg}" == *"open"* ]] && nv_pkg="nvidia-open-dkms" || nv_pkg="nvidia-dkms"
        run "sudo pacman -S --needed --noconfirm ${nv_pkg} $(pkg_list nvidia.utils | tr '\n' ' ')"
        ok "NVIDIA driver installed: ${nv_pkg}"
    else
        ok "NVIDIA driver already installed"
    fi

    local modconf="/etc/mkinitcpio.conf"
    if [[ -f "${modconf}" ]]; then
        if grep -q "^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm" "${modconf}"; then
            ok "NVIDIA modules already in mkinitcpio.conf"
        else
            info "Adding NVIDIA modules to mkinitcpio.conf..."
            sudo sed -i 's/^MODULES=(/&nvidia nvidia_modeset nvidia_uvm nvidia_drm /' "${modconf}"
            run "sudo mkinitcpio -P"
            ok "Initramfs rebuilt with NVIDIA modules"
        fi
    else
        warn "mkinitcpio.conf not found"
        tip "Check your initramfs setup manually"
    fi

    local kdir=""
    if [[ -f /etc/default/grub ]]; then
        kdir="/etc/default/grub"
    elif [[ -d /boot/loader/entries ]]; then
        kdir="systemd-boot"
    fi

    if [[ "${kdir}" == "/etc/default/grub" ]]; then
        if grep -q "nvidia_drm.modeset=1" "${kdir}"; then
            ok "nvidia_drm.modeset=1 already in GRUB"
        else
            info "Adding nvidia_drm.modeset=1 to GRUB..."
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia_drm.modeset=1 /' "${kdir}"
            warn "GRUB config updated"
            dim "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
            if confirm "Run grub-mkconfig now?"; then
                run "sudo grub-mkconfig -o /boot/grub/grub.cfg"
            fi
        fi
    elif [[ "${kdir}" == "systemd-boot" ]]; then
        warn "Systemd-boot detected. Add manually:"
        dim "  nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    fi

    local env_file="${HOME}/.config/hypr/settings/env.lua"
    if ! grep -q "nvidia" "${env_file}" 2>/dev/null; then
        cat >> "${env_file}" << 'ENVEOF'

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
ENVEOF
        ok "NVIDIA env vars added to settings/env.lua"
    else
        ok "NVIDIA env vars already in env.lua"
    fi

    echo ""
    hr
    echo -e "  ${ORANGE}::${NC}  ${BOLD}NVIDIA checklist:${NC}"
    dim "  :: First launch may take a few seconds (shader compilation)"
    dim "  :: If you get a black screen:"
    dim "     - Remove 'nvidia' from MODULES in /etc/mkinitcpio.conf"
    dim "     - Rebuild: sudo mkinitcpio -P"
    dim "     - Use env = WLR_NO_HARDWARE_CURSORS,1"
    hr
    echo ""
    press_enter
}
