run_post_install() {
    step "Post-Install"

    if [[ -f /etc/systemd/system/display-manager.service ]]; then
        local dm
        dm=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || echo "")
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
        warn "PipeWire not found :: audio may not work"
        info "Install: sudo pacman -S pipewire pipewire-pulse wireplumber"
    fi

    if ! fc-list | grep -qi "JetBrains Mono" &>/dev/null; then
        warn "JetBrains Mono font not found :: UI may look off"
        info "Install: sudo pacman -S ttf-jetbrains-mono"
    fi
}

show_troubleshooting() {
    echo ""
    hr
    echo -e "  ${ORANGE}${BOLD}:: Troubleshooting${NC}"
    hr
    echo ""
    dim "  ${BOLD}Hyprland won't start${NC}"
    dim "  :: cat ~/.config/hypr/hyprland.lua"
    dim "  :: Try: Hyprland (verbose)"
    dim "  :: mv ~/.config/hypr/hyprland.lua{,.bak}"
    echo ""
    dim "  ${BOLD}No audio${NC}"
    dim "  :: sudo pacman -S pipewire pipewire-pulse wireplumber"
    dim "  :: systemctl --user enable --now pipewire pipewire-pulse"
    echo ""
    dim "  ${BOLD}Wallpapers not working${NC}"
    dim "  :: Put images in ~/Pictures/Wallpapers/"
    dim "  :: Run: ~/.config/rofi/scripts/wallselect.sh"
    echo ""
    dim "  ${BOLD}Bluetooth not working${NC}"
    dim "  :: sudo systemctl enable --now bluetooth"
    echo ""
    dim "  ${BOLD}Weird keybindings${NC}"
    dim "  :: Check: cat ~/.config/hypr/settings/input.lua"
    dim "  :: Default: SUPER = Windows key, SUPER + SPACE = menu"
    echo ""
    dim "  ${BOLD}Need more help?${NC}"
    dim "  :: Run diagnostic: bash ${REPO}/Scripts/failed.sh"
    dim "  :: Open an issue: https://github.com/zhaleff/BlackNode/issues"
    dim "  :: Include the log: ${LOG}"
    echo ""
    press_enter
}

show_summary() {
    echo ""
    hr
    echo -e "  ${GREEN}${BOLD}BlackNode is ready${NC}"
    hr
    echo ""
    echo -e "  ${BOLD}System${NC}       ${OS_NAME:-Arch} / ${GPU_VENDOR} / ${MONITOR_RES:-auto}"
    echo -e "  ${BOLD}Configs${NC}      ${DIM}${HOME}/.config/ -> BlackNode${NC}"
    echo -e "  ${BOLD}Backup${NC}       ${DIM}${BACKUP}${NC}"
    echo -e "  ${BOLD}Log${NC}          ${DIM}${LOG}${NC}"
    echo ""
    hr
    echo -e "  ${BOLD}Quick start:${NC}"
    echo ""
    echo -e "  ${BOLD}1${NC}  Log out -> select Hyprland in SDDM"
    echo -e "  ${BOLD}2${NC}  Set wallpaper        ${DIM}SUPER + W${NC}"
    echo -e "  ${BOLD}3${NC}  Open BlackNode menu  ${DIM}SUPER + SPACE${NC}"
    echo -e "  ${BOLD}4${NC}  Browse keybinds      ${DIM}bn-menu -> About -> Keybinds${NC}"
    echo -e "  ${BOLD}5${NC}  Switch profiles      ${DIM}bn-menu -> Profiles${NC}"
    echo ""
    hr
    echo -e "  ${DIM}Need help?${NC}"
    echo -e "  ${DIM}Issues: https://github.com/zhaleff/BlackNode/issues${NC}"
    echo ""
    echo -e "  ${PURPLE}${BOLD}Thanks for installing BlackNode${NC}"
    echo ""
}
