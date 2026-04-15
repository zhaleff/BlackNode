#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DOTFILES_REPO="https://github.com/TU_USUARIO/TU_REPO.git"
DOTFILES_DIR="${HOME}/.dotfiles"
LOG_FILE="${HOME}/.local/share/blacknode/install.log"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date '+%Y%m%d_%H%M%S')"

R="\033[0m"
BD="\033[1m"
DM="\033[2m"
CY="\033[0;36m"
CB="\033[1;36m"
BB="\033[1;34m"
GR="\033[0;90m"
GN="\033[0;32m"
RD="\033[0;31m"
YL="\033[0;33m"
WH="\033[1;37m"

_log()  { mkdir -p "$(dirname "$LOG_FILE")"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }
_ok()   { echo -e "${GN}  ✓  ${R}${1}"; _log "OK: $1"; }
_warn() { echo -e "${YL}  ⚠  ${R}${1}"; _log "WARN: $1"; }
_fail() { echo -e "${RD}  ✗  ${R}${1}" >&2; _log "FAIL: $1"; }
_step() { echo -e "\n${CB}  ▶  ${WH}${1}${R}"; _log "STEP: $1"; }
_sep()  { echo -e "${GR}$(printf '─%.0s' {1..68})${R}"; }
_die()  { _fail "$1"; exit 1; }

INSTALLED=() FAILED=() SKIPPED=()
_track_ok()   { INSTALLED+=("$1"); }
_track_fail() { FAILED+=("$1"); }
_track_skip() { SKIPPED+=("$1"); }

PKG_BEFORE=""

print_header() {
    clear
    echo -e "${BB}"
    cat << 'EOF'
  ██████╗ ██╗      █████╗  ██████╗██╗  ██╗███╗   ██╗ ██████╗ ██████╗ ███████╗
  ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝████╗  ██║██╔═══██╗██╔══██╗██╔════╝
  ██████╔╝██║     ███████║██║     █████╔╝ ██╔██╗ ██║██║   ██║██║  ██║█████╗
  ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██║╚██╗██║██║   ██║██║  ██║██╔══╝
  ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██║ ╚████║╚██████╔╝██████╔╝███████╗
  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝
EOF
    echo -e "${R}"
    echo -e "${DM}  Arch Linux • GNU Stow • One-shot installer  •  Log → ${LOG_FILE}${R}"
    echo -e "${DM}  $(date '+%A, %d %B %Y  %H:%M:%S')${R}"
    echo ""
}

snapshot_pkgs() { pacman -Q 2>/dev/null | awk '{print $1}' | sort; }

check_root() {
    if [[ $EUID -eq 0 ]]; then
        _die "Do not run this script as root. It will use sudo when needed."
    fi
}

check_deps() {
    _step "Checking base dependencies"
    local missing=()
    for cmd in git curl sudo; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        _warn "Missing: ${missing[*]} — installing via pacman"
        sudo pacman -S --needed --noconfirm "${missing[@]}" >> "$LOG_FILE" 2>&1 \
            && _ok "Base deps ready" \
            || _die "Cannot install base dependencies. Check your internet connection."
    else
        _ok "Base dependencies present"
    fi
}

install_yay() {
    _step "AUR helper — yay"
    if command -v yay &>/dev/null; then
        _ok "yay already installed ($(yay --version | head -1))"
        _track_skip "yay"
        return
    fi
    _warn "yay not found — building from AUR"
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN
    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay" >> "$LOG_FILE" 2>&1 \
        || _die "Failed to clone yay-bin from AUR"
    (cd "$tmp/yay" && makepkg -si --noconfirm >> "$LOG_FILE" 2>&1) \
        && { _ok "yay installed"; _track_ok "yay"; } \
        || { _fail "yay build failed — check log"; _track_fail "yay"; }
}

install_packages() {
    _step "Installing packages"

    local pacman_pkgs=(
        base-devel git curl wget unzip zip tar stow
        hyprland xdg-desktop-portal-hyprland
        waybar
        rofi-wayland
        wlogout
        hyprlock
        hyprshot
        zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
        neovim ripgrep fd tree-sitter
        yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf
        fastfetch
        cava
        clipse
        flatpak
        swww swaybg
        pipewire pipewire-pulse pipewire-alsa wireplumber
        brightnessctl playerctl
        noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd
        btop htop
        wl-clipboard
    )

    local aur_pkgs=(
        wallust-git
        ags
        hyprshot
    )

    _sep
    echo -e "${CY}  pacman packages (${#pacman_pkgs[@]})${R}"
    sudo pacman -S --needed --noconfirm "${pacman_pkgs[@]}" 2>&1 | tee -a "$LOG_FILE" \
        | grep -E "^(installing|upgrading|warning)" \
        | while read -r line; do echo -e "    ${GR}${line}${R}"; done \
        && { _ok "pacman packages done"; _track_ok "pacman packages"; } \
        || { _fail "Some pacman packages failed — check log"; _track_fail "pacman packages"; }

    _sep
    echo -e "${CY}  AUR packages (${#aur_pkgs[@]})${R}"
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm "${aur_pkgs[@]}" 2>&1 | tee -a "$LOG_FILE" \
            | grep -E "^(installing|upgrading|warning|AUR)" \
            | while read -r line; do echo -e "    ${GR}${line}${R}"; done \
            && { _ok "AUR packages done"; _track_ok "AUR packages"; } \
            || { _fail "Some AUR packages failed — check log"; _track_fail "AUR packages"; }
    else
        _warn "yay unavailable — skipping AUR packages"
        _track_skip "AUR packages"
    fi
}

clone_dotfiles() {
    _step "Dotfiles repository"

    if [[ "$DOTFILES_REPO" == *"TU_USUARIO"* ]]; then
        _warn "DOTFILES_REPO not configured in script — edit line 7 with your real repo URL"
        echo -e "${YL}  Enter your dotfiles repo URL now (or press Enter to skip):${R} \c"
        read -r user_repo
        if [[ -n "$user_repo" ]]; then
            DOTFILES_REPO="$user_repo"
        else
            _warn "Skipping dotfiles clone"
            _track_skip "dotfiles clone"
            return
        fi
    fi

    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        _warn "Dotfiles dir exists — pulling latest"
        git -C "$DOTFILES_DIR" pull --ff-only 2>&1 | tee -a "$LOG_FILE" \
            && _ok "Dotfiles updated" \
            || _warn "Pull failed — using existing files"
        return
    fi

    git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR" 2>&1 | tee -a "$LOG_FILE" \
        && { _ok "Dotfiles cloned → ${DOTFILES_DIR}"; _track_ok "dotfiles clone"; } \
        || _die "Failed to clone dotfiles from ${DOTFILES_REPO}"
}

backup_existing() {
    _step "Backing up existing configs"
    local targets=(
        "$HOME/.config/hypr"
        "$HOME/.config/waybar"
        "$HOME/.config/rofi"
        "$HOME/.config/wlogout"
        "$HOME/.config/nvim"
        "$HOME/.config/yazi"
        "$HOME/.config/fastfetch"
        "$HOME/.config/cava"
        "$HOME/.config/zsh"
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.zprofile"
    )

    local backed_up=0
    for target in "${targets[@]}"; do
        if [[ -e "$target" && ! -L "$target" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$target" "$BACKUP_DIR/" 2>/dev/null && (( backed_up++ )) || true
        fi
    done

    if (( backed_up > 0 )); then
        _ok "${backed_up} existing config(s) backed up → ${BACKUP_DIR}"
        _track_ok "backup (${backed_up} items)"
    else
        _ok "No pre-existing configs to back up"
    fi
}

stow_dotfiles() {
    _step "Symlinking dotfiles with GNU Stow"

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        _warn "Dotfiles directory not found — skipping stow"
        _track_skip "stow"
        return
    fi

    local stow_pkgs=()
    for dir in "$DOTFILES_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        local pkg
        pkg=$(basename "$dir")
        [[ "$pkg" == ".git" || "$pkg" == ".github" ]] && continue
        stow_pkgs+=("$pkg")
    done

    if [[ ${#stow_pkgs[@]} -eq 0 ]]; then
        _warn "No stow packages found in ${DOTFILES_DIR}"
        _warn "Expected structure: ~/.dotfiles/<package>/.config/<app>/..."
        _track_skip "stow"
        return
    fi

    echo -e "${GR}  Packages found: ${stow_pkgs[*]}${R}"

    local failed_stow=()
    for pkg in "${stow_pkgs[@]}"; do
        stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg" 2>&1 | tee -a "$LOG_FILE" \
            && echo -e "    ${GN}✓${R} ${pkg}" \
            || { echo -e "    ${RD}✗${R} ${pkg}"; failed_stow+=("$pkg"); }
    done

    if [[ ${#failed_stow[@]} -gt 0 ]]; then
        _warn "Stow conflicts in: ${failed_stow[*]}"
        _warn "Run manually: stow --dir=${DOTFILES_DIR} --target=${HOME} --adopt <pkg>"
        _track_fail "stow (${#failed_stow[@]} conflicts)"
    else
        _ok "All dotfiles symlinked (${#stow_pkgs[@]} packages)"
        _track_ok "stow (${#stow_pkgs[@]} packages)"
    fi
}

setup_zsh() {
    _step "Zsh shell setup"

    local zsh_bin
    zsh_bin=$(command -v zsh 2>/dev/null || true)
    if [[ -z "$zsh_bin" ]]; then
        _fail "zsh not found — was package install successful?"
        _track_fail "zsh"
        return
    fi

    if [[ "$SHELL" != "$zsh_bin" ]]; then
        _warn "Changing default shell to zsh (will prompt for password)"
        chsh -s "$zsh_bin" \
            && _ok "Default shell → zsh (takes effect on next login)" \
            || _warn "chsh failed — change shell manually: chsh -s ${zsh_bin}"
    else
        _ok "zsh already default shell"
    fi

    if [[ ! -d "${HOME}/.local/share/zsh/plugins/zsh-syntax-highlighting" ]]; then
        mkdir -p "${HOME}/.local/share/zsh/plugins"
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "${HOME}/.local/share/zsh/plugins/zsh-syntax-highlighting" >> "$LOG_FILE" 2>&1 \
            && _ok "zsh-syntax-highlighting cloned" \
            || _warn "Failed to clone zsh-syntax-highlighting (may already be in dotfiles)"
    else
        _ok "zsh-syntax-highlighting already present"
    fi

    _track_ok "zsh"
}

setup_neovim() {
    _step "Neovim setup"

    if ! command -v nvim &>/dev/null; then
        _fail "nvim not found — was package install successful?"
        _track_fail "neovim"
        return
    fi

    _ok "Neovim $(nvim --version | head -1)"

    if [[ -d "${HOME}/.config/nvim" ]]; then
        _ok "Neovim config present (via dotfiles)"
        echo -e "${DM}  Plugins will auto-install on first launch.${R}"
    else
        _warn "No nvim config found — check your dotfiles structure"
    fi

    _track_ok "neovim"
}

setup_flatpak() {
    _step "Flatpak"

    if ! command -v flatpak &>/dev/null; then
        _fail "flatpak not found"
        _track_fail "flatpak"
        return
    fi

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1 \
        && _ok "Flathub remote configured" \
        || _warn "Could not add Flathub remote (may already exist)"

    _track_ok "flatpak"
}

setup_xdg() {
    _step "XDG / portal configuration"

    mkdir -p "${HOME}/.config/xdg-desktop-portal"

    if [[ ! -f "${HOME}/.config/xdg-desktop-portal/hyprland-portals.conf" ]]; then
        cat > "${HOME}/.config/xdg-desktop-portal/hyprland-portals.conf" << 'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
EOF
        _ok "xdg-desktop-portal config written"
    else
        _ok "xdg-desktop-portal config already present"
    fi

    _track_ok "XDG portals"
}

setup_services() {
    _step "Systemd user services"

    local services=(
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
    )

    for svc in "${services[@]}"; do
        if systemctl --user is-enabled "$svc" &>/dev/null; then
            _ok "${svc} already enabled"
        else
            systemctl --user enable --now "$svc" >> "$LOG_FILE" 2>&1 \
                && _ok "${svc} enabled & started" \
                || _warn "${svc} could not be enabled (normal if not in user session yet)"
        fi
    done

    _track_ok "systemd user services"
}

setup_fonts() {
    _step "Font cache"
    fc-cache -fv >> "$LOG_FILE" 2>&1 \
        && _ok "Font cache rebuilt" \
        || _warn "fc-cache failed — fonts may not appear until next login"
    _track_ok "font cache"
}

show_package_diff() {
    _step "Package diff (new installs this run)"
    local after
    after=$(snapshot_pkgs)
    local new_pkgs
    new_pkgs=$(comm -13 <(echo "$PKG_BEFORE") <(echo "$after") 2>/dev/null || true)
    if [[ -n "$new_pkgs" ]]; then
        local count
        count=$(echo "$new_pkgs" | wc -l)
        echo -e "${CB}  ${count} new package(s) installed:${R}"
        echo "$new_pkgs" | while read -r pkg; do
            echo -e "    ${GN}+${R} ${pkg}"
        done
    else
        echo -e "${GR}  No new packages detected.${R}"
    fi
}

print_summary() {
    echo ""
    _sep
    echo -e "${CB}  INSTALLATION SUMMARY${R}"
    _sep

    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        echo -e "${GN}  Completed (${#INSTALLED[@]}):${R}"
        for c in "${INSTALLED[@]}"; do echo -e "    ${GN}✓${R}  ${c}"; done
    fi

    if [[ ${#SKIPPED[@]} -gt 0 ]]; then
        echo -e "${YL}  Skipped  (${#SKIPPED[@]}):${R}"
        for c in "${SKIPPED[@]}"; do echo -e "    ${YL}⚠${R}  ${c}"; done
    fi

    if [[ ${#FAILED[@]} -gt 0 ]]; then
        echo -e "${RD}  Failed   (${#FAILED[@]}):${R}"
        for c in "${FAILED[@]}"; do echo -e "    ${RD}✗${R}  ${c}"; done
        echo ""
        echo -e "${YL}  Review the full log for details:${R}"
        echo -e "${DM}  tail -n 50 ${LOG_FILE}${R}"
    fi

    echo ""
    _sep
    echo -e "${DM}  Full log: ${LOG_FILE}${R}"
    echo -e "${DM}  Backup:   ${BACKUP_DIR}  (if created)${R}"
    _sep
}

main() {
    mkdir -p "$(dirname "$LOG_FILE")"
    : > "$LOG_FILE"
    _log "BlackNode installer started — user=$(whoami) host=$(hostname) pid=$$"

    print_header
    check_root
    check_deps

    PKG_BEFORE=$(snapshot_pkgs)
    _log "Pre-install snapshot: $(echo "$PKG_BEFORE" | wc -l) packages"

    echo -e "${CB}  This will install your full BlackNode environment on Arch Linux.${R}"
    echo -e "${WH}  Dotfiles repo:${R} ${DOTFILES_REPO}"
    echo -e "${WH}  Dotfiles dir: ${R} ${DOTFILES_DIR}"
    echo -e "${WH}  Backup dir:   ${R} ${BACKUP_DIR}"
    echo ""
    echo -e "${CY}  Continue? (y/n): ${R}\c"
    read -r go
    [[ "$go" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

    install_yay
    install_packages
    clone_dotfiles
    backup_existing
    stow_dotfiles
    setup_zsh
    setup_neovim
    setup_flatpak
    setup_xdg
    setup_services
    setup_fonts
    show_package_diff
    print_summary

    echo ""
    echo -e "${CB}  BlackNode installation complete.${R}"
    echo -e "${DM}  Log out and back in (or reboot) to start Hyprland.${R}"
    echo ""

    _log "Installer finished — OK:${#INSTALLED[@]} SKIP:${#SKIPPED[@]} FAIL:${#FAILED[@]}"
}

main
