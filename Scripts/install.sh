#!/usr/bin/env bash
set -uo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/install" && pwd)"
REPO="${HOME}/BlackNode"
BACKUP="${HOME}/.blacknode-backup-$(date +%Y%m%d-%H%M%S)"
LOG="${HOME}/.blacknode-install.log"
PACKAGES_JSON="${INSTALL_DIR}/packages.json"
FLAGS="$*"
STEP=0

source "${INSTALL_DIR}/lib/ui.sh"
source "${INSTALL_DIR}/lib/hints.sh"
source "${INSTALL_DIR}/lib/run.sh"
source "${INSTALL_DIR}/lib/json.sh"
source "${INSTALL_DIR}/checks/system.sh"
source "${INSTALL_DIR}/checks/hardware.sh"
source "${INSTALL_DIR}/steps/packages.sh"
source "${INSTALL_DIR}/steps/nvidia.sh"
source "${INSTALL_DIR}/steps/system-setup.sh"
source "${INSTALL_DIR}/steps/symlinks.sh"
source "${INSTALL_DIR}/steps/post-install.sh"

trap cleanup SIGINT SIGTERM

main() {
    header "BlackNode Installer"

    check_flags
    check_root
    check_distro
    check_internet
    check_pacman_lock
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

    if ! confirm "Install BlackNode dotfiles?"; then
        warn "Cancelled"
        exit 0
    fi

    AUR=""
    command -v yay &>/dev/null && AUR="yay"
    [[ -z "${AUR}" ]] && command -v paru &>/dev/null && AUR="paru"

    TOTAL_STEPS=10
    [[ -n "${AUR}" ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))
    [[ " ${FLAGS} " == *" --minimal "* ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))
    [[ "${GPU_VENDOR}" != "nvidia" ]] && TOTAL_STEPS=$((TOTAL_STEPS - 1))

    [[ -z "${AUR}" ]] && install_aur_helper
    install_core_packages
    install_aur_packages
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
