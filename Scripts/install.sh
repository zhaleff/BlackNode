#!/usr/bin/env bash
set -euo pipefail

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

check_dependency() {
    command -v "$1" &>/dev/null
}

section() {
    echo ""
    echo -e "${CYAN}──────────────────────────────────────────${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}──────────────────────────────────────────${NC}"
    echo ""
}

select_aur_helper() {
    if check_dependency yay; then
        AUR="yay"
    elif check_dependency paru; then
        AUR="paru"
    else
        section "AUR Helper"
        info "BlackNode needs an AUR helper for some packages (wlogout, clipse, etc.)."
        ask "Install yay? [Y/n]: "; read -r ans
        if [[ "$ans" =~ ^[Nn] ]]; then
            ask "Install paru instead? [Y/n]: "; read -r ans2
            if [[ "$ans2" =~ ^[Nn] ]]; then
                err "AUR helper required. Aborting."
                exit 1
            fi
            AUR="paru"
            info "Installing paru..."
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            (cd /tmp/paru && makepkg -si --noconfirm) 2>&1 | tee -a "$LOG"
        else
            AUR="yay"
            info "Installing yay..."
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            (cd /tmp/yay && makepkg -si --noconfirm) 2>&1 | tee -a "$LOG"
        fi
        ok "AUR helper: $AUR"
    fi
}

install_packages() {
    section "Package Installation"
    info "BlackNode needs the following packages:"
    echo "  Core: hyprland, waybar, rofi-wayland, kitty, neovim, dunst,"
    echo "        hyprlock, hypridle, fastfetch, yazi, zsh, fzf, matugen,"
    echo "        sddm, gtk3, gtk4, ttf-jetbrains-mono, nerd-fonts"
    echo "  AUR:  wlogout, clipse-bin, powerlevel10k-git"
    echo ""
    ask "Install core packages now? [Y/n]: "; read -r ans
    if [[ ! "$ans" =~ ^[Nn] ]]; then
        info "Installing core packages..."
        sudo pacman -S --needed --noconfirm \
            hyprland waybar rofi-wayland kitty neovim \
            dunst hyprlock hypridle fastfetch yazi zsh fzf \
            matugen sddm gtk3 gtk4 ttf-jetbrains-mono 2>&1 | tee -a "$LOG"
        ok "Core packages installed"
    else
        warn "Skipping core packages. Install them manually later."
    fi

    ask "Install AUR packages? [Y/n]: "; read -r ans2
    if [[ ! "$ans2" =~ ^[Nn] ]]; then
        $AUR -S --needed --noconfirm wlogout clipse-bin powerlevel10k-git 2>&1 | tee -a "$LOG"
        ok "AUR packages installed"
    fi

    section "Optional Packages"
    echo "  playerctl    — media controls (recommended)"
    echo "  brightnessctl — screen brightness keys (recommended)"
    echo "  wireplumber   — audio (recommended)"
    echo "  grim+slurp    — screenshots (needed for hyprshot)"
    echo "  pacman-contrib — update count in waybar"
    echo "  bluez+blueman — bluetooth"
    echo "  pamixer       — volume control in waybar"
    echo "  firefox       — browser (config has themes for it)"
    echo ""
    ask "Install all optional packages? [Y/n]: "; read -r ans3
    if [[ ! "$ans3" =~ ^[Nn] ]]; then
        sudo pacman -S --needed --noconfirm \
            playerctl brightnessctl wireplumber grim slurp \
            pacman-contrib bluez bluez-utils blueman pamixer \
            firefox 2>&1 | tee -a "$LOG"
        ok "Optional packages installed"
    else
        info "You can install them later with:"
        echo "  sudo pacman -S playerctl brightnessctl wireplumber grim slurp pacman-contrib bluez blueman pamixer firefox"
    fi
}

setup_keyboard() {
    section "Keyboard Layout"
    info "BlackNode defaults to 'us,es' (US + Spanish)."
    ask "Change keyboard layout? [y/N]: "; read -r ans
    if [[ "$ans" =~ ^[Yy] ]]; then
        ask "Enter your layout (e.g. 'us,es', 'us', 'latam', 'de'): "; read -r layout
        if [[ -n "$layout" ]]; then
            sed -i "s/kb_layout = \".*\"/kb_layout = \"$layout\"/" \
                "$REPO/Configs/.config/hypr/settings/input.lua"
            ok "Keyboard layout set to: $layout"
        fi
    fi
}

setup_shell() {
    section "Shell Setup"
    if [[ "$SHELL" != *"zsh"* ]]; then
        info "BlackNode uses ZSH with powerlevel10k."
        ask "Change default shell to ZSH? [Y/n]: "; read -r ans
        if [[ ! "$ans" =~ ^[Nn] ]]; then
            if check_dependency zsh; then
                chsh -s "$(which zsh)" 2>&1 | tee -a "$LOG"
                ok "Default shell changed to ZSH"
            else
                warn "ZSH not found. Install it first."
            fi
        fi
    else
        ok "ZSH is already your default shell"
    fi
}

setup_wallpaper_dir() {
    section "Wallpaper Directory"
    local wp_dir="$HOME/Pictures/Wallpapers"
    if [[ ! -d "$wp_dir" ]]; then
        ask "Create wallpaper directory at $wp_dir? [Y/n]: "; read -r ans
        if [[ ! "$ans" =~ ^[Nn] ]]; then
            mkdir -p "$wp_dir"
            ok "Created $wp_dir"
            info "Place your wallpapers there, then run:"
            echo "  ~/.config/rofi/scripts/wallselect.sh"
        fi
    else
        ok "Wallpaper directory exists: $wp_dir"
    fi
}

link_configs() {
    section "Linking Configs"
    info "This will symlink BlackNode configs to ~/.config/ and ~/.local/bin/"
    warn "Existing configs will be backed up to: $BACKUP"
    ask "Continue? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        warn "Skipping. Run manually: bash Scripts/linkdots.sh"
        return
    fi

    for item in "$REPO/Configs/.config"/*; do
        local name=$(basename "$item")
        local dst="$HOME/.config/$name"
        if [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]]; then
            info "  ✓ $name (already linked)"
            continue
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$BACKUP/.config"
            mv "$dst" "$BACKUP/.config/$name"
            info "  backed up: $name"
        fi
        ln -sf "$item" "$dst"
        ok "  linked: $name"
    done

    for item in "$REPO/Configs/.local/bin"/*; do
        local name=$(basename "$item")
        local dst="$HOME/.local/bin/$name"
        if [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]]; then
            info "  ✓ $name (already linked)"
            continue
        fi
        if [[ -e "$dst" || -L "$dst" ]]; then
            mkdir -p "$BACKUP/.local/bin"
            mv "$dst" "$BACKUP/.local/bin/$name"
            info "  backed up: $name"
        fi
        ln -sf "$item" "$dst"
        ok "  linked: $name"
    done
}

run_post_install() {
    section "Post-Install"

    if command -v systemctl &>/dev/null; then
        if ! systemctl is-enabled --quiet bluetooth 2>/dev/null; then
            ask "Enable Bluetooth service? [Y/n]: "; read -r ans
            if [[ ! "$ans" =~ ^[Nn] ]]; then
                sudo systemctl enable --now bluetooth 2>&1 | tee -a "$LOG"
                ok "Bluetooth enabled"
            fi
        fi
    fi

    if [[ ! -f "$HOME/.config/hypr/profiles/.active" ]]; then
        echo -n "default" > "$HOME/.config/hypr/profiles/.active"
        ok "Default profile set"
    fi

    info "To generate colors from wallpaper, place an image in ~/Pictures/Wallpapers/ and run:"
    echo "  matugen image ~/Pictures/Wallpapers/your-wallpaper.jpg"
    echo ""
    info "Then reload Hyprland: SUPER + SHIFT + R or hyprctl reload"
}

show_summary() {
    section "Installation Complete"
    echo -e "${GREEN}BlackNode is ready!${NC}"
    echo ""
    echo "  Configs:        $HOME/.config/ (symlinked)"
    echo "  Backup:         $BACKUP"
    echo "  Wallpapers:     $HOME/Pictures/Wallpapers/"
    echo "  Shell:          $SHELL"
    echo "  AUR helper:     ${AUR:-none}"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and select Hyprland from SDDM/login manager"
    echo "  2. On first login, set wallpaper: SUPER + W"
    echo "  3. Open bn-menu: SUPER + SPACE"
    echo "  4. Check keybinds: bn-menu → About → Keybinds"
    echo ""
    echo "Need help? https://discord.gg/hollowsec"
    echo "Issues?     https://github.com/zhaleff/BlackNode/issues"
    echo ""
}

main() {
    echo ""
    echo -e "${CYAN}  ╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}  ║       BlackNode Dotfiles Installer        ║${NC}"
    echo -e "${CYAN}  ║       by zhaleff · HollowSec              ║${NC}"
    echo -e "${CYAN}  ╚═══════════════════════════════════════════╝${NC}"
    echo ""

    if [[ ! -d "$REPO" ]]; then
        err "BlackNode not found at $REPO"
        info "Clone it first:"
        echo "  git clone https://github.com/zhaleff/BlackNode.git $REPO"
        exit 1
    fi

    if [[ "$(uname -o)" != "GNU/Linux" ]]; then
        err "BlackNode targets Arch Linux. You are running: $(uname -o)"
        ask "Continue anyway? [y/N]: "; read -r ans
        if [[ ! "$ans" =~ ^[Yy] ]]; then exit 1; fi
    fi

    ask "Ready to install BlackNode? [Y/n]: "; read -r ans
    if [[ "$ans" =~ ^[Nn] ]]; then
        info "Installation cancelled."
        exit 0
    fi

    select_aur_helper
    install_packages
    setup_keyboard
    setup_shell
    setup_wallpaper_dir
    link_configs
    run_post_install
    show_summary
}

main "$@"
