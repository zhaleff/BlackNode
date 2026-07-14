#!/usr/bin/env bash
# BlackNode Installer - Diagnostic
# Analyzes install logs and suggests fixes.
# Usage: bash Scripts/failed.sh [/path/to/install.log]

set -u

BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PURPLE='\033[0;35m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; RED='\033[0;31m'; TEAL='\033[0;36m'
ORANGE='\033[38;5;208m'

LOG="${1:-/tmp/blacknode-install.log}"

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

echo ""
echo -e "  ${PURPLE}${BOLD}⏣  BlackNode Diagnostic${NC}"
echo ""

if [[ ! -f "${LOG}" ]]; then
    err "Log not found: ${LOG}"
    echo ""
    info "Possible causes:"
    dim "  • The installer hasn't been run yet"
    dim "  • The log was deleted: rm /tmp/blacknode-install.log"
    dim "  • Not running from the BlackNode directory"
    echo ""
    exit 1
fi

LOG_SIZE=$(wc -l < "${LOG}")
if [[ "${LOG_SIZE}" -lt 2 ]]; then
    err "Log is empty or too short (${LOG_SIZE} lines)."
    info "The installer may not have produced useful output."
    exit 1
fi

LOG_CONTENT=$(cat "${LOG}")

PATTERNS=()
PATTERNS+=("error: failed to commit transaction")
PATTERNS+=("error: target not found")
PATTERNS+=("could not resolve host")
PATTERNS+=("No space left on device")
PATTERNS+=("disk full")
PATTERNS+=("permission denied")
PATTERNS+=("Permission denied")
PATTERNS+=("makepkg: command not found")
PATTERNS+=("command not found")
PATTERNS+=("is not in /etc/shells")
PATTERNS+=("fatal: unable to access")
PATTERNS+=("fatal: not a git repository")
PATTERNS+=("Connection refused")
PATTERNS+=("Connection timed out")
PATTERNS+=("could not connect")
PATTERNS+=("signature from.*is unknown trust")
PATTERNS+=("invalid or corrupted package")
PATTERNS+=("failed to retrieve file")
PATTERNS+=("unable to lock database")
PATTERNS+=("/var/lib/pacman/db.lck")
PATTERNS+=("already running")
PATTERNS+=("could not get file information")
PATTERNS+=("failed to init transaction")
PATTERNS+=("not enough free disk space")
PATTERNS+=("exists in filesystem")
PATTERNS+=("failed to install")

FIXES=()
FIXES+=("PACMAN_CONFLICT")
FIXES+=("PACMAN_TARGET")
FIXES+=("NETWORK_DNS")
FIXES+=("DISK_SPACE")
FIXES+=("DISK_SPACE")
FIXES+=("PERMISSION")
FIXES+=("PERMISSION")
FIXES+=("BASE_DEVEL")
FIXES+=("COMMAND_NOT_FOUND")
FIXES+=("SHELLS_FILE")
FIXES+=("GIT_ACCESS")
FIXES+=("GIT_REPO")
FIXES+=("NETWORK_DNS")
FIXES+=("NETWORK_DNS")
FIXES+=("NETWORK_DNS")
FIXES+=("PACMAN_KEYS")
FIXES+=("PACMAN_CORRUPT")
FIXES+=("PACMAN_CORRUPT")
FIXES+=("PACMAN_LOCK")
FIXES+=("PACMAN_LOCK")
FIXES+=("PACMAN_LOCK")
FIXES+=("SUDO")
FIXES+=("PACMAN_CONFLICT")
FIXES+=("DISK_SPACE")
FIXES+=("PACMAN_CONFLICT")
FIXES+=("PACMAN_CONFLICT")

FOUND_ERRORS=()
FOUND_FIXES=()

for i in "${!PATTERNS[@]}"; do
    pattern="${PATTERNS[$i]}"
    if echo "${LOG_CONTENT}" | grep -qiE "${pattern}" &>/dev/null; then
        FOUND_ERRORS+=("${pattern}")
        FOUND_FIXES+=("${FIXES[$i]}")
    fi
done

echo -e "  ${BOLD}Analyzing:${NC} ${LOG} (${LOG_SIZE} lines)"
hr
echo ""

if [[ ${#FOUND_ERRORS[@]} -eq 0 ]]; then
    info "No common errors detected in the log."
    echo ""
    dim "This could mean:"
    dim "  • The error isn't in our database yet"
    dim "  • The installer ran successfully (check the '✔' lines)"
    dim "  • The issue happened outside the logged commands"
    echo ""
else
    err "${#FOUND_ERRORS[@]} issue(s) detected"
    echo ""
fi

show_fix() {
    local fix="${1}"
    case "${fix}" in
        PACMAN_CONFLICT)
            echo ""
            err "Package conflict or filesystem collision"
            dim "Another package already owns some files, or versions clash."
            echo ""
            dim "Fixes:"
            dim "  1. sudo pacman -Syu    (full system update)"
            dim "  2. sudo pacman -S --overwrite='*' <package>"
            dim "  3. Check which package owns the file:"
            dim "     pacman -Qo /path/to/conflicting/file"
            ;;
        PACMAN_TARGET)
            echo ""
            err "Package not found in repositories"
            dim "The package doesn't exist or the repo list is outdated."
            echo ""
            dim "Fixes:"
            dim "  1. sudo pacman -Syy   (refresh mirrors)"
            dim "  2. Check the package name for typos"
            dim "  3. It might be in AUR, not pacman"
            ;;
        NETWORK_DNS)
            echo ""
            err "Network or DNS issue"
            dim "Could not reach the server — no internet or DNS problem."
            echo ""
            dim "Fixes:"
            dim "  1. ping archlinux.org   (test connectivity)"
            dim "  2. ping 1.1.1.1         (test without DNS)"
            dim "  3. Check your connection: ip link, ping, curl"
            dim "  4. If on WiFi: nmcli device wifi connect <SSID>"
            ;;
        DISK_SPACE)
            echo ""
            err "Disk space is full"
            dim "Not enough space to install packages."
            echo ""
            dim "Fixes:"
            dim "  1. df -h    (check free space)"
            dim "  2. sudo pacman -Sc   (clean package cache)"
            dim "  3. sudo journalctl --vacuum-size=500M"
            dim "  4. Remove unused packages: sudo pacman -Rns <pkg>"
            ;;
        PERMISSION)
            echo ""
            err "Permission denied"
            dim "You don't have permission to access a file or directory."
            echo ""
            dim "Fixes:"
            dim "  1. Check file ownership: ls -la <path>"
            dim "  2. Fix: sudo chown -R $(whoami) <path>"
            dim "  3. Make sure you're not running as root"
            ;;
        BASE_DEVEL)
            echo ""
            err "Missing build tools (base-devel)"
            dim "makepkg requires base-devel group to compile AUR packages."
            echo ""
            dim "Fixes:"
            dim "  1. sudo pacman -S --needed base-devel"
            dim "  2. Re-run the installer after installing"
            ;;
        COMMAND_NOT_FOUND)
            echo ""
            err "A required command was not found"
            dim "The installer tried to run something that isn't installed."
            echo ""
            dim "Fixes:"
            dim "  1. Install the missing package:"
            dim "     sudo pacman -S <package-name>"
            dim "  2. Check if it's in the correct PATH"
            dim "  3. which <command>   (find where it should be)"
            ;;
        SHELLS_FILE)
            echo ""
            err "ZSH not registered in /etc/shells"
            dim "chsh requires the shell to be listed in /etc/shells."
            echo ""
            dim "Fixes:"
            dim "  1. which zsh | sudo tee -a /etc/shells"
            dim "  2. Then re-run: chsh -s \$(which zsh)"
            ;;
        GIT_ACCESS)
            echo ""
            err "Git could not access the remote"
            dim "Network issue, or the repository requires authentication."
            echo ""
            dim "Fixes:"
            dim "  1. Check internet: curl -I https://github.com"
            dim "  2. If behind a proxy, set: export HTTP_PROXY=..."
            dim "  3. Try: git clone --depth 1 (shallow clone)"
            ;;
        GIT_REPO)
            echo ""
            err "Git repository issue"
            dim "Not a git repository or corrupted .git folder."
            echo ""
            dim "Fixes:"
            dim "  1. rm -rf ~/BlackNode && git clone ..."
            dim "  2. Or: git -C ~/BlackNode status"
            ;;
        PACMAN_KEYS)
            echo ""
            err "Pacman key signature issue"
            dim "Package signatures are untrusted or missing."
            echo ""
            dim "Fixes:"
            dim "  1. sudo pacman-key --init"
            dim "  2. sudo pacman-key --populate archlinux"
            dim "  3. sudo pacman -Syy"
            ;;
        PACMAN_CORRUPT)
            echo ""
            err "Corrupted or invalid package"
            dim "Package download is corrupted."
            echo ""
            dim "Fixes:"
            dim "  1. sudo pacman -Sc   (clean cache)"
            dim "  2. sudo pacman -Syy  (refresh mirrors)"
            dim "  3. Try again"
            ;;
        PACMAN_LOCK)
            echo ""
            err "Pacman is locked"
            dim "Another package operation is running, or the lock is stale."
            echo ""
            dim "Fixes:"
            dim "  1. Wait for the other process to finish"
            dim "  2. If no pacman is running:"
            dim "     sudo rm /var/lib/pacman/db.lck"
            ;;
        SUDO)
            echo ""
            err "Sudo permission issue"
            dim "The user doesn't have sudo rights or sudo timed out."
            echo ""
            dim "Fixes:"
            dim "  1. sudo -v   (refresh sudo timestamp)"
            dim "  2. Check sudoers: sudo usermod -aG wheel $(whoami)"
            dim "  3. Log out and back in to apply group changes"
            ;;
        *)
            dim "No specific fix available for this error."
            ;;
    esac
}

SEEN=()
for i in "${!FOUND_ERRORS[@]}"; do
    error="${FOUND_ERRORS[$i]}"
    fix="${FOUND_FIXES[$i]}"

    if [[ " ${SEEN[*]} " == *" ${fix} "* ]]; then
        continue
    fi
    SEEN+=("${fix}")

    echo ""
    hr
    echo -e "  ${RED}${BOLD}✖  $(echo ${error} | tr '[:lower:]' '[:upper:]' | head -c 60)${NC}"
    hr
    show_fix "${fix}"
    echo ""
done

SEEN_STEPS=()
while IFS= read -r line; do
    if echo "${line}" | grep -qE '^\$'; then
        cmd=$(echo "${line}" | sed 's/^\$ //')
        SEEN_STEPS+=("${cmd}")
    fi
done < <(grep -E '^\$ ' "${LOG}" 2>/dev/null | tail -20)

if [[ ${#SEEN_STEPS[@]} -gt 0 ]]; then
    echo ""
    hr
    echo -e "  ${BOLD}Last commands run:${NC}"
    hr
    echo ""
    for cmd in "${SEEN_STEPS[@]}"; do
        dim "  $ ${cmd}"
    done
    echo ""
fi

echo ""
hr
echo -e "  ${ORANGE}${BOLD}☰  What now?${NC}"
hr
echo ""
info "1. Re-run the installer"
dim "    bash ${HOME}/BlackNode/Scripts/install.sh"
echo ""
info "2. Skip only the failed step"
dim "    Edit install.sh and comment out the completed steps,"
dim "    or just re-run and choose 'Skip' when it fails."
echo ""
info "3. View the full log"
dim "    ${LOG}"
echo ""
info "4. Get help"
dim "    Open an issue: https://github.com/zhaleff/BlackNode/issues"
dim "    Discord:       https://discord.gg/hollowsec"
dim "    Include the log: ${LOG}"
echo ""
hr
echo ""

if confirm "Open the log file in less?"; then
    if command -v less &>/dev/null; then
        less "${LOG}"
    else
        cat "${LOG}"
    fi
fi

if confirm "Re-run the installer?"; then
    if [[ -f "${HOME}/BlackNode/Scripts/install.sh" ]]; then
        exec bash "${HOME}/BlackNode/Scripts/install.sh"
    else
        err "Installer not found at ${HOME}/BlackNode/Scripts/install.sh"
        exit 1
    fi
fi

echo ""
ok "Diagnostic complete"
info "Log: ${LOG}"
