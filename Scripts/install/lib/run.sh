log() { echo "[$(date +%H:%M:%S)] ${*}" >> "${LOG}"; }

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
        [[ ${rc} -eq 126 ]] && dim "Caused by: permission denied"
        [[ ${rc} -eq 127 ]] && dim "Caused by: command not found"
        echo ""
        hint_for "${cmd}"
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

rollback() {
    if [[ ! -d "${BACKUP}" ]]; then
        info "No backups to restore"
        return
    fi

    info "Restoring backups from ${BACKUP}..."

    if [[ -d "${BACKUP}/.config" ]]; then
        for item in "${BACKUP}/.config"/*; do
            local name dst
            name=$(basename "${item}")
            dst="${HOME}/.config/${name}"
            rm -f "${dst}"
            mv "${item}" "${dst}" 2>/dev/null
        done
    fi

    if [[ -d "${BACKUP}/.local/bin" ]]; then
        for item in "${BACKUP}/.local/bin"/*; do
            local name dst
            name=$(basename "${item}")
            dst="${HOME}/.local/bin/${name}"
            rm -f "${dst}"
            mv "${item}" "${dst}" 2>/dev/null
        done
    fi

    ok "Backups restored from: ${BACKUP}"
}

cleanup() {
    echo ""
    warn "Installation interrupted (Ctrl+C)"
    if confirm "Rollback config symlinks?" "N"; then rollback; fi
    info "Check the log: ${LOG}"
    tip "Report issues: https://github.com/zhaleff/BlackNode/issues"
    exit 1
}
