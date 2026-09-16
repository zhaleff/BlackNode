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
        info "No monitor config yet :: auto-detected: ${MONITOR_RES}"
        if confirm "Write ${MONITOR_RES} to monitor settings?"; then
            mkdir -p "$(dirname "${target}")"
            cat > "${target}" << MONEOF
monitor = ,${MONITOR_RES},auto,1
MONEOF
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
                run "sudo pacman -S --noconfirm zsh"
            else
                warn "Shell not changed."
                dim "Manual: sudo pacman -S zsh && chsh -s \$(which zsh)"
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
            ok "Backed up: .zshrc -> .zshrc.blacknode-backup"
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
