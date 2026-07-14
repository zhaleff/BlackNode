#!/usr/bin/env bash
set -u

REPO="$HOME/BlackNode"
BACKUP="$HOME/.config/blacknode-backup-$(date +%Y%m%d%H%M%S)"
LOG="/tmp/blacknode-install.log"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
ask()   { echo -ne "${CYAN}[?]${NC} $1"; }

> "$LOG"

run() {
    local cmd="$*"
    echo "[$(date +%H:%M:%S)] $ $cmd" >> "$LOG"
    eval "$cmd" 2>&1 | tee -a "$LOG"
    local rc=${PIPESTATUS[0]}
    if [[ $rc -ne 0 ]]; then
        err "Command failed (exit $rc): $cmd"
        warn "Check $LOG for details"
        while true; do
            ask "[R]etry, [S]kip, or [A]bort? [R/s/a]: "; read -r choice
            case "$choice" in
                [Rr]|"") run "$cmd"; return $? ;;
                [Ss]) warn "Skipped: $cmd"; return 1 ;;
                [Aa]) err "Aborted by user"; exit 1 ;;
            esac
        done
    fi
    return 0
}

section() {
    echo ""
    echo -e "${CYAN}──────────────────────────────────────────${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}──────────────────────────────────────────${NC}"
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
    echo "  hyprland, waybar, rofi-wayland, kitty, neovim, dunst,"
    echo "  hyprlock, hypridle, fastfetch, yazi, zsh, fzf, matugen,"
    echo "  sddm, gtk3, gtk4, ttf-jetbrains-mono"
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
    echo "  playerctl     — media keys (recommended)"
    echo "  brightnessctl — brightness keys (recommended)"
    echo "  wireplumber   — audio (recommended)"
    echo "  grim+slurp    — screenshots for hyprshot"
    echo "  pacman-contrib— update count in waybar"
    echo "  bluez+blueman — bluetooth"
    echo "  pamixer       — volume in waybar"
    echo "  firefox       — browser (config has themes)"
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
    section "Done"
    echo -e "${GREEN}BlackNode installed.${NC}"
    echo ""
    echo "  Configs:    $HOME/.config/ → BlackNode"
    echo "  Backup:     $BACKUP"
    echo "  Wallpapers: $HOME/Pictures/Wallpapers/"
    echo "  Log:        $LOG"
    echo ""
    echo "Next:"
    echo "  1. Log out, select Hyprland in SDDM"
    echo "  2. Set wallpaper: SUPER + W"
    echo "  3. Open menu: SUPER + SPACE"
    echo "  4. bn-menu → About → Keybinds"
    echo ""
    echo "  Issues: https://github.com/zhaleff/BlackNode/issues"
    echo "  Help:   https://discord.gg/hollowsec"
}

main() {
    echo ""
    echo -e "${CYAN}  BlackNode Installer — zhaleff / HollowSec${NC}"
    echo ""

    if [[ ! -d "$REPO" ]]; then
        err "BlackNode not found at $REPO"
        echo "  git clone https://github.com/zhaleff/BlackNode.git $REPO"
        exit 1
    fi

    ask "Install BlackNode? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        info "Cancelled."; exit 0
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
