#!/usr/bin/env bash
# ============================================================
#  BlackNode Installer — Hyprland Dotfiles Environment
#  Author: BlackNode Project
#  Target: Arch Linux + Hyprland + Wayland
# ============================================================

set -euo pipefail

# ─────────────────────────────────────────────
#  COLORS & SYMBOLS
# ─────────────────────────────────────────────
readonly RST='\033[0m'
readonly BLD='\033[1m'
readonly DIM='\033[2m'

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GRN='\033[0;32m'
readonly YLW='\033[0;33m'
readonly BLU='\033[0;34m'
readonly MAG='\033[0;35m'
readonly CYN='\033[0;36m'
readonly WHT='\033[0;37m'

readonly BBLK='\033[1;30m'
readonly BRED='\033[1;31m'
readonly BGRN='\033[1;32m'
readonly BYLW='\033[1;33m'
readonly BBLU='\033[1;34m'
readonly BMAG='\033[1;35m'
readonly BCYN='\033[1;36m'
readonly BWHT='\033[1;37m'

OK="  ${BGRN}✓${RST}"
INFO="  ${BCYN}·${RST}"
WARN="  ${BYLW}⚠${RST}"
ERR="  ${BRED}✗${RST}"
STEP="${BMAG}❯${RST}"

# ─────────────────────────────────────────────
#  LOGGING
# ─────────────────────────────────────────────
log_ok()   { printf "${OK}  %b\n" "$*"; }
log_info() { printf "${INFO}  %b\n" "$*"; }
log_warn() { printf "${WARN}  %b\n" "$*"; }
log_err()  { printf "${ERR}  %b\n" "$*" >&2; }
log_step() { printf "\n${STEP}  ${BLD}%b${RST}\n" "$*"; }

die() {
    log_err "$*"
    exit 1
}

# ─────────────────────────────────────────────
#  BANNER
# ─────────────────────────────────────────────
print_banner() {
    clear
    printf "\n"
    printf "${BBLK}  ╔══════════════════════════════════════════════════╗${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}██████╗ ${BBLU}██╗      █████╗  ██████╗ ██╗  ██╗${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}██╔══██╗${BBLU}██║     ██╔══██╗██╔════╝ ██║ ██╔╝${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}██████╔╝${BBLU}██║     ███████║██║      █████╔╝ ${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}██╔══██╗${BBLU}██║     ██╔══██║██║      ██╔═██╗ ${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}██████╔╝${BBLU}███████╗██║  ██║╚██████╗ ██║  ██╗${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BMAG}╚═════╝ ${BBLU}╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝${RST}  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${DIM}Hyprland Dotfiles Installer — Arch Linux${RST}       ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ╚══════════════════════════════════════════════════╝${RST}\n"
    printf "\n"
}

# ─────────────────────────────────────────────
#  PREREQS CHECK
# ─────────────────────────────────────────────
check_prereqs() {
    [[ $EUID -eq 0 ]] && die "Do not run this script as root."
    command -v pacman &>/dev/null || die "pacman not found. This script targets Arch Linux only."
    command -v git    &>/dev/null || die "git is not installed. Install it first: sudo pacman -S git"
}

# ─────────────────────────────────────────────
#  LOCATE DOTFILES DIRECTORY
# ─────────────────────────────────────────────
locate_dotfiles() {
    local search_root="${HOME}"
    local -a candidates=()

    # Search home directory (max depth 3) for directories with "blacknode" in the name
    while IFS= read -r -d '' dir; do
        candidates+=("$dir")
    done < <(find "$search_root" -maxdepth 3 -type d -iname "*blacknode*" -print0 2>/dev/null)

    if [[ ${#candidates[@]} -eq 0 ]]; then
        log_err "No directory containing 'blacknode' found under ${HOME}."
        log_info "Clone the repository first, then re-run this installer."
        exit 1
    fi

    if [[ ${#candidates[@]} -eq 1 ]]; then
        DOTFILES_DIR="${candidates[0]}"
        log_ok "Dotfiles directory detected: ${BCYN}${DOTFILES_DIR}${RST}"
        return
    fi

    # Multiple candidates — let the user pick
    printf "\n${WARN}  Multiple BlackNode directories found:\n\n"
    local i=1
    for d in "${candidates[@]}"; do
        printf "  ${DIM}[${RST}${BWHT}%d${RST}${DIM}]${RST}  %s\n" "$i" "$d"
        (( i++ ))
    done
    printf "\n"

    local choice
    while true; do
        printf "  ${BLD}Select a directory [1-%d]: ${RST}" "${#candidates[@]}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#candidates[@]} )); then
            DOTFILES_DIR="${candidates[$((choice - 1))]}"
            break
        fi
        log_warn "Invalid selection. Try again."
    done

    log_ok "Using: ${BCYN}${DOTFILES_DIR}${RST}"
}

# ─────────────────────────────────────────────
#  USER PROMPTS
# ─────────────────────────────────────────────
prompt_keyboard_layout() {
    printf "\n"
    printf "  ${BLD}Keyboard layout${RST} ${DIM}(e.g. us, es, latam, de, fr)${RST}: "
    read -r KB_LAYOUT
    KB_LAYOUT="${KB_LAYOUT:-us}"
    log_ok "Keyboard layout set to: ${BCYN}${KB_LAYOUT}${RST}"
}

prompt_wallpaper_dir() {
    printf "\n"
    printf "  ${BLD}Wallpaper source directory${RST} ${DIM}(leave blank to skip)${RST}: "
    read -r WALLPAPER_SRC
    WALLPAPER_SRC="${WALLPAPER_SRC/#\~/$HOME}"  # expand ~ manually
}

# ─────────────────────────────────────────────
#  YAY SETUP
# ─────────────────────────────────────────────
ensure_yay() {
    if command -v yay &>/dev/null; then
        log_ok "yay is already installed"
        return
    fi

    log_step "Installing yay (AUR helper)"
    local build_dir
    build_dir="$(mktemp -d)"

    sudo pacman -S --needed --noconfirm base-devel

    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
    (cd "$build_dir/yay-bin" && makepkg -si --noconfirm)

    rm -rf "$build_dir"
    log_ok "yay installed"
}

# ─────────────────────────────────────────────
#  PACKAGE INSTALLATION
# ─────────────────────────────────────────────
PACMAN_PKGS=(
    # Core desktop
    hyprland waybar rofi-wayland hyprlock hypridle sddm dunst wlogout dmenu

    # Shell
    zsh

    # Terminals
    kitty alacritty

    # Editor
    neovim

    # File manager
    yazi

    # Wallpaper daemon
    swww

    # Audio
    cava pipewire pipewire-pulse wireplumber pavucontrol

    # Screenshot & display
    grim slurp wl-clipboard brightnessctl

    # Network / Bluetooth
    network-manager-applet bluez bluez-utils

    # Portal & polkit
    xdg-desktop-portal-hyprland xdg-user-dirs polkit polkit-gnome

    # Theming
    qt5ct qt6ct nwg-look
    gtk3 gtk4
    papirus-icon-theme
    arc-gtk-theme

    # Fonts
    ttf-jetbrains-mono-nerd
    ttf-fira-code
    ttf-nerd-fonts-symbols
    noto-fonts noto-fonts-emoji noto-fonts-cjk

    # System utils
    git wget curl unzip zip tar rsync jq bc
    fastfetch btop

    # Python (often needed by rice tools)
    python python-pip

    # Misc
    imagemagick ffmpeg
)

YAY_PKGS=(
    wallust
    clipse
    powerlevel10k
    oh-my-zsh-git
    sddm-theme-astronaut
)

install_pacman_packages() {
    log_step "Installing pacman packages"
    sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"
    log_ok "Pacman packages installed"
}

install_yay_packages() {
    log_step "Installing AUR packages"
    yay -S --needed --noconfirm "${YAY_PKGS[@]}"
    log_ok "AUR packages installed"
}

# ─────────────────────────────────────────────
#  DOTFILES INSTALLATION
# ─────────────────────────────────────────────
install_dotfiles() {
    log_step "Installing dotfiles"

    local src="${DOTFILES_DIR}/Configs/.config"

    [[ -d "$src" ]] || die "Expected config directory not found: ${src}"

    mkdir -p "${HOME}/.config"

    rsync -aHAX --no-perms \
        "$src/" \
        "${HOME}/.config/" \
        --info=progress2 \
        2>/dev/null

    log_ok "Dotfiles installed to ~/.config"
}

# ─────────────────────────────────────────────
#  KEYBOARD LAYOUT CONFIGURATION
# ─────────────────────────────────────────────
configure_keyboard() {
    local input_cfg="${HOME}/.config/hypr/settings/input.lua"

    [[ -f "$input_cfg" ]] || {
        log_warn "Hyprland input config not found at: ${input_cfg} — skipping keyboard layout"
        return
    }

    log_step "Configuring keyboard layout"

    # Replace kb_layout value in the Lua config
    sed -i "s|kb_layout\s*=\s*\"[^\"]*\"|kb_layout = \"${KB_LAYOUT}\"|" "$input_cfg"

    log_ok "Keyboard layout set to '${KB_LAYOUT}' in input.lua"
}

# ─────────────────────────────────────────────
#  WALLPAPER HANDLING
# ─────────────────────────────────────────────
install_wallpapers() {
    [[ -z "${WALLPAPER_SRC}" ]] && {
        log_info "No wallpaper directory provided — skipping"
        return
    }

    [[ -d "${WALLPAPER_SRC}" ]] || {
        log_warn "Wallpaper directory not found: ${WALLPAPER_SRC} — skipping"
        return
    }

    log_step "Installing wallpapers"

    local dest="${HOME}/.local/share/wallpapers"
    mkdir -p "$dest"

    local count=0
    while IFS= read -r -d '' img; do
        mv "$img" "$dest/"
        (( count++ ))
    done < <(find "$WALLPAPER_SRC" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        -print0)

    log_ok "Moved ${count} wallpaper(s) to ${dest}"
}

# ─────────────────────────────────────────────
#  SDDM SETUP
# ─────────────────────────────────────────────
setup_sddm() {
    log_step "Configuring SDDM"

    # Install theme from dotfiles if present
    local sddm_theme_src="${DOTFILES_DIR}/Extras/sddm"
    if [[ -d "$sddm_theme_src" ]]; then
        sudo mkdir -p /usr/share/sddm/themes
        sudo cp -r "$sddm_theme_src/"* /usr/share/sddm/themes/
        log_ok "SDDM theme installed"
    fi

    # Ensure basic SDDM config exists
    sudo mkdir -p /etc/sddm.conf.d
    if [[ ! -f /etc/sddm.conf.d/default.conf ]]; then
        sudo tee /etc/sddm.conf.d/default.conf > /dev/null <<EOF
[Theme]
Current=astronaut

[Autologin]
Relogin=false
EOF
        log_ok "SDDM config written"
    fi

    sudo systemctl enable sddm.service
    log_ok "SDDM service enabled"
}

# ─────────────────────────────────────────────
#  SERVICE ENABLEMENT
# ─────────────────────────────────────────────
enable_services() {
    log_step "Enabling system services"

    sudo systemctl enable bluetooth.service
    log_ok "bluetooth enabled"

    # Pipewire user services (enabled per-user)
    systemctl --user enable --now pipewire.service       2>/dev/null || true
    systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
    systemctl --user enable --now wireplumber.service    2>/dev/null || true
    log_ok "Pipewire/WirePlumber user services enabled"

    xdg-user-dirs-update 2>/dev/null || true
    log_ok "XDG user dirs initialized"
}

# ─────────────────────────────────────────────
#  ZSH SHELL PROMPT
# ─────────────────────────────────────────────
prompt_zsh_default() {
    printf "\n"
    printf "  ${BLD}Set Zsh as default shell?${RST} ${DIM}[y/N]${RST}: "
    read -r answer
    if [[ "${answer,,}" == "y" ]]; then
        local zsh_path
        zsh_path="$(command -v zsh)"
        chsh -s "$zsh_path" "$(whoami)"
        log_ok "Default shell changed to Zsh. Takes effect on next login."
    else
        log_info "Shell unchanged. You can run ${BCYN}chsh -s \$(which zsh)${RST} later."
    fi
}

# ─────────────────────────────────────────────
#  FINAL SUMMARY
# ─────────────────────────────────────────────
print_summary() {
    printf "\n"
    printf "${BBLK}  ╔══════════════════════════════════════════════════╗${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${BGRN}Installation complete.${RST}                          ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}   ${DIM}Reboot to launch into your Hyprland session.${RST}    ${BBLK}║${RST}\n"
    printf "${BBLK}  ║${RST}                                                  ${BBLK}║${RST}\n"
    printf "${BBLK}  ╚══════════════════════════════════════════════════╝${RST}\n"
    printf "\n"
    printf "  ${DIM}Quick reboot:${RST}  ${BCYN}systemctl reboot${RST}\n\n"
}

# ─────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────
main() {
    print_banner
    check_prereqs

    log_step "Locating dotfiles"
    locate_dotfiles

    prompt_keyboard_layout
    prompt_wallpaper_dir

    ensure_yay
    install_pacman_packages
    install_yay_packages

    install_dotfiles
    configure_keyboard
    install_wallpapers

    setup_sddm
    enable_services

    prompt_zsh_default
    print_summary
}

main "$@"
