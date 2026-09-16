link_item() {
    local src="${1}" dst="${2}"

    if [[ -L "${dst}" && "$(readlink "${dst}")" == "${src}" ]]; then
        LINK_SKIPPED=$((LINK_SKIPPED + 1))
        return
    fi

    if [[ -e "${dst}" || -L "${dst}" ]]; then
        mkdir -p "$(dirname "${dst/#${HOME}/${BACKUP}}")"
        mv "${dst}" "${dst/#${HOME}/${BACKUP}}" 2>/dev/null && LINK_BACKED=$((LINK_BACKED + 1))
    else
        mkdir -p "$(dirname "${dst}")"
    fi

    ln -sf "${src}" "${dst}" 2>/dev/null && LINK_LINKED=$((LINK_LINKED + 1)) || LINK_ERRORS=$((LINK_ERRORS + 1))
}

ensure_path_export() {
    [[ ":$PATH:" == *":${HOME}/.local/bin:"* ]] && return

    warn "${HOME}/.local/bin not in PATH"

    local rc_file=""
    [[ -f "${HOME}/.zshrc" ]] && rc_file="${HOME}/.zshrc"
    [[ -f "${HOME}/.bashrc" && -z "${rc_file}" ]] && rc_file="${HOME}/.bashrc"

    if [[ -z "${rc_file}" ]]; then
        info "Add this to your shell rc file:"
        dim '  export PATH="$HOME/.local/bin:$PATH"'
        return
    fi

    if grep -q 'export PATH="\$HOME/.local/bin:\$PATH"' "${rc_file}" 2>/dev/null; then
        ok "PATH entry already in $(basename "${rc_file}")"
    else
        echo "" >> "${rc_file}"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "${rc_file}"
        ok "Added to $(basename "${rc_file}")"
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

    LINK_LINKED=0
    LINK_BACKED=0
    LINK_SKIPPED=0
    LINK_ERRORS=0

    for item in "${REPO}/Configs/.config"/*; do
        link_item "${item}" "${HOME}/.config/$(basename "${item}")"
    done

    for item in "${REPO}/Configs/.local/bin"/*; do
        link_item "${item}" "${HOME}/.local/bin/$(basename "${item}")"
    done

    if [[ -d "${REPO}/Configs/.local/lib/blacknode" ]]; then
        link_item "${REPO}/Configs/.local/lib/blacknode" "${HOME}/.local/lib/blacknode"
    fi

    if [[ ${LINK_ERRORS} -gt 0 ]]; then
        warn "${LINK_LINKED} linked, ${LINK_BACKED} backed up, ${LINK_ERRORS} errors"
        info "Check permissions or disk space for the failed items."
    else
        ok "${LINK_LINKED} linked, ${LINK_BACKED} backed up, ${LINK_SKIPPED} already up-to-date"
    fi

    ensure_path_export
}
