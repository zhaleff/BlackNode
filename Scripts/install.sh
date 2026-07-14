#!/usr/bin/env bash
set -u

REPO="$HOME/BlackNode"
BACKUP="$HOME/.config/blacknode-backup-$(date +%Y%m%d%H%M%S)"
LOG="/tmp/blacknode-install.log"

BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
PURPLE='\033[0;35m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BG_PURPLE='\033[45m'; BG_BLUE='\033[44m'

info()  { echo -e "${BLUE}┃${NC} $1"; }
ok()    { echo -e "${GREEN}┃${NC} $1"; }
warn()  { echo -e "${YELLOW}┃${NC} $1"; }
err()   { echo -e "${RED}┃${NC} $1"; }
ask()   { echo -ne "${PURPLE}┃${NC} $1"; }

title() {
    echo ""
    echo -e "  ${BG_PURPLE}${BOLD} ${1} ${NC}"
    echo ""
}
subtitle() {
    echo ""
    echo -e "  ${PURPLE}${BOLD}◆${NC} ${BOLD}$1${NC}"
    echo ""
}

> "$LOG"

run() {
    local cmd="$*"
    echo "[$(date +%H:%M:%S)] $ $cmd" >> "$LOG"
    eval "$cmd" 2>&1 | tee -a "$LOG"
    local rc=${PIPESTATUS[0]}
    if [[ $rc -ne 0 ]]; then
        echo ""
        echo -e "  ${RED}${BOLD}✕ Command failed (exit $rc)${NC}"
        echo -e "  ${DIM}${cmd}${NC}"
        echo -e "  ${DIM}Details: $LOG${NC}"
        echo ""
        while true; do
            ask "${BOLD}R${NC}etry, ${BOLD}S${NC}kip, ${BOLD}A${NC}bort? ${DIM}[R/s/a]${NC} "; read -r choice
            case "$choice" in
                [Rr]|"") run "$cmd"; return $? ;;
                [Ss]) echo -e "  ${YELLOW}─ Skipped${NC}"; return 1 ;;
                [Aa]) echo -e "  ${RED}─ Aborted${NC}"; exit 1 ;;
            esac
        done
    fi
    return 0
}

section() {
    echo ""
    echo -e "  ${DIM}${PURPLE}┌─────────────────────────────────────┐${NC}"
    echo -e "  ${PURPLE}│${NC}  ${BOLD}$1${NC}"
    echo -e "  ${DIM}${PURPLE}└─────────────────────────────────────┘${NC}"
    echo ""
}

detect_aur_helper() {
    if command -v yay &>/dev/null; then echo "yay"
    elif command -v paru &>/dev/null; then echo "paru"
    else echo ""; fi
}

install_aur_helper() {
    section "AUR Helper"
    info "BlackNode needs an AUR helper for: wlogout, clipse-bin, powerlevel10k-git"
    echo ""
    ask "Install yay? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        ask "Install paru instead? [Y/n]: "; read -r ans2
        if [[ "$ans2" =~ ^[Nn] ]]; then
            err "No AUR helper selected."
            info "You can install one later and re-run the script."
            info "Packages needed: wlogout clipse-bin powerlevel10k-git"
            AUR=""
            return
        fi
        AUR="paru"
    else
        AUR="yay"
    fi
    info "Installing $AUR (this requires base-devel and git)..."
    run "sudo pacman -S --needed --noconfirm base-devel git"
    run "git clone https://aur.archlinux.org/$AUR.git /tmp/$AUR"
    run "cd /tmp/$AUR && makepkg -si --noconfirm"
    cd "$REPO"
    if command -v "$AUR" &>/dev/null; then
        ok "$AUR installed"
    else
        err "$AUR installation may have failed. Check $LOG"
        AUR=""
        warn "Continuing without AUR helper. Install it manually later."
    fi
}

install_core_packages() {
    section "Core Packages"
    info "Essential packages for BlackNode:"
    echo -e "  ${DIM}hyprland, waybar, rofi-wayland, kitty, neovim, dunst,${NC}"
    echo -e "  ${DIM}hyprlock, hypridle, fastfetch, yazi, zsh, fzf, matugen,${NC}"
    echo -e "  ${DIM}sddm, gtk3, gtk4, ttf-jetbrains-mono${NC}"
    echo ""
    ask "Install core packages? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        warn "Skipping. Run manually: sudo pacman -S hyprland waybar rofi-wayland kitty neovim dunst hyprlock hypridle fastfetch yazi zsh fzf matugen sddm gtk3 gtk4 ttf-jetbrains-mono"
        return
    fi
    run "sudo pacman -S --needed --noconfirm hyprland waybar rofi-wayland kitty neovim dunst hyprlock hypridle fastfetch yazi zsh fzf matugen sddm gtk3 gtk4 ttf-jetbrains-mono"
    ok "Core packages done"
}

install_aur_packages() {
    section "AUR Packages"
    if [[ -z "${AUR:-}" ]]; then
        warn "No AUR helper available. Skip or install manually."
        ask "Install manually later? [Y/n]: "; read -r ans
        if [[ "$ans" =~ ^[Nn] ]]; then
            install_aur_helper
            if [[ -z "${AUR:-}" ]]; then return; fi
        else
            info "Manual install: ${AUR:-yay} -S wlogout clipse-bin powerlevel10k-git"
            return
        fi
    fi
    ask "Install AUR packages (wlogout, clipse, powerlevel10k)? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        info "Skip or later: $AUR -S wlogout clipse-bin powerlevel10k-git"
        return
    fi
    run "$AUR -S --needed --noconfirm wlogout clipse-bin powerlevel10k-git"
    ok "AUR packages done"
}

install_optional_packages() {
    section "Optional Packages"
    echo -e "  ${DIM}playerctl     — media keys (recommended)${NC}"
    echo -e "  ${DIM}brightnessctl — brightness keys (recommended)${NC}"
    echo -e "  ${DIM}wireplumber   — audio (recommended)${NC}"
    echo -e "  ${DIM}grim+slurp    — screenshots for hyprshot${NC}"
    echo -e "  ${DIM}pacman-contrib— update count in waybar${NC}"
    echo -e "  ${DIM}bluez+blueman — bluetooth${NC}"
    echo -e "  ${DIM}pamixer       — volume in waybar${NC}"
    echo -e "  ${DIM}firefox       — browser (config has themes)${NC}"
    echo ""
    ask "Install all optional packages? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        info "Install later: sudo pacman -S playerctl brightnessctl wireplumber grim slurp pacman-contrib bluez bluez-utils blueman pamixer firefox"
        return
    fi
    run "sudo pacman -S --needed --noconfirm playerctl brightnessctl wireplumber grim slurp pacman-contrib bluez bluez-utils blueman pamixer firefox"
    ok "Optional packages done"
}

setup_keyboard() {
    section "Keyboard Layout"
    info "Default layout: 'us,es' (US + Spanish)"
    ask "Change it? [y/N]: "; read -r ans
    if [[ "$ans" =~ ^[Yy] ]]; then
        ask "Enter layout code (e.g. 'us', 'latam', 'de', 'us,es'): "; read -r layout
        if [[ -n "$layout" ]]; then
            sed -i "s/kb_layout = \".*\"/kb_layout = \"$layout\"/" \
                "$REPO/Configs/.config/hypr/settings/input.lua"
            ok "Keyboard layout: $layout"
        fi
    fi
}

setup_shell() {
    section "Shell"
    if [[ "$SHELL" == *"zsh"* ]]; then
        ok "ZSH is already your shell"
        return
    fi
    info "BlackNode uses ZSH + powerlevel10k."
    ask "Change default shell to ZSH? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        info "Skipping. You can do it later: chsh -s \$(which zsh)"
        return
    fi
    if ! command -v zsh &>/dev/null; then
        warn "ZSH not installed. Run: sudo pacman -S zsh"
        return
    fi
    run "chsh -s $(which zsh)"
    ok "Default shell changed to ZSH (log out and back in)"
}

setup_wallpaper_dir() {
    section "Wallpaper Directory"
    local wp="$HOME/Pictures/Wallpapers"
    if [[ -d "$wp" ]]; then
        ok "Wallpaper dir exists: $wp"
        return
    fi
    ask "Create $wp? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then return; fi
    run "mkdir -p $wp"
    ok "Created $wp"
    info "Place wallpapers there, then run: ~/.config/rofi/scripts/wallselect.sh"
}

link_configs() {
    section "Linking Configs"
    info "Symlinks BlackNode configs to ~/.config/ and ~/.local/bin/"
    warn "Existing files get backed up to: $BACKUP"
    ask "Continue? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        warn "Run manually: bash $REPO/Scripts/linkdots.sh"
        return
    fi

    local item name dst
    for item in "$REPO/Configs/.config"/*; do
        name=$(basename "$item")
        dst="$HOME/.config/$name"
        if [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]]; then
            info "  ✓ $name"
            continue
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$BACKUP/.config"
            mv "$dst" "$BACKUP/.config/$name"
            info "  backed up: $name"
        fi
        ln -sf "$item" "$dst" && ok "  linked: $name"
    done

    for item in "$REPO/Configs/.local/bin"/*; do
        name=$(basename "$item")
        dst="$HOME/.local/bin/$name"
        if [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]]; then
            info "  ✓ $name"
            continue
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$BACKUP/.local/bin"
            mv "$dst" "$BACKUP/.local/bin/$name"
            info "  backed up: $name"
        fi
        ln -sf "$item" "$dst" && ok "  linked: $name"
    done
    ok "All configs linked"
}

post_install() {
    section "Post-Install"

    if command -v systemctl &>/dev/null; then
        ask "Enable Bluetooth service? [Y/n]: "; read -r ans
        if [[ ! "$ans" =~ ^[Nn] ]]; then
            run "sudo systemctl enable --now bluetooth"
        fi
    fi

    mkdir -p "$HOME/.config/hypr/profiles"
    if [[ ! -f "$HOME/.config/hypr/profiles/.active" ]]; then
        echo -n "default" > "$HOME/.config/hypr/profiles/.active"
        ok "Default profile set"
    fi
}

show_summary() {
    echo ""
    echo -e "  ${GREEN}${BOLD}✔  BlackNode installed${NC}"
    echo ""
    echo -e "  ${BOLD}Configs${NC}    ${DIM}$HOME/.config/ → BlackNode${NC}"
    echo -e "  ${BOLD}Backup${NC}     ${DIM}$BACKUP${NC}"
    echo -e "  ${BOLD}Wallpapers${NC} ${DIM}$HOME/Pictures/Wallpapers/${NC}"
    echo -e "  ${BOLD}Log${NC}        ${DIM}$LOG${NC}"
    echo ""
    echo -e "  ${PURPLE}── Next steps ──${NC}"
    echo -e "  ${BOLD}1.${NC} Log out, select Hyprland in SDDM"
    echo -e "  ${BOLD}2.${NC} Set wallpaper: ${DIM}SUPER + W${NC}"
    echo -e "  ${BOLD}3.${NC} Open menu: ${DIM}SUPER + SPACE${NC}"
    echo -e "  ${BOLD}4.${NC} bn-menu → About → Keybinds"
    echo ""
    echo -e "  ${DIM}Issues: https://github.com/zhaleff/BlackNode/issues${NC}"
    echo -e "  ${DIM}Help:   https://discord.gg/hollowsec${NC}"
}

main() {
    echo ""
    echo -e "  ${PURPLE}${BOLD}⏣  BlackNode Installer${NC}   ${DIM}by zhaleff · HollowSec${NC}"
    echo ""

    if [[ ! -d "$REPO" ]]; then
        echo -e "  ${RED}${BOLD}✕ BlackNode not found${NC}"
        echo -e "  ${DIM}Clone it first:${NC}"
        echo -e "  ${BOLD}git clone https://github.com/zhaleff/BlackNode.git $REPO${NC}"
        exit 1
    fi

    ask "${BOLD}Install BlackNode?${NC} ${DIM}[Y/n]${NC} "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        echo -e "  ${YELLOW}─ Cancelled${NC}"; exit 0
    fi

    AUR=$(detect_aur_helper)
    if [[ -z "$AUR" ]]; then
        install_aur_helper
    else
        ok "AUR helper found: $AUR"
    fi

    install_core_packages
    install_aur_packages
    install_optional_packages
    setup_keyboard
    setup_shell
    setup_wallpaper_dir
    link_configs
    post_install
    show_summary
}

main "$@"
