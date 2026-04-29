#!/usr/bin/env bash
# BlackNode Dotfiles Installer
# https://github.com/HollowSec/BlackNode

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

info()  { echo -e "  ${BLUE}•${RESET} $*"; }
ok()    { echo -e "  ${GREEN}✓${RESET} $*"; }
warn()  { echo -e "  ${YELLOW}!${RESET} $*"; }
die()   { echo -e "\n  ${RED}✗${RESET} $*\n" >&2; exit 1; }
gap()   { echo ""; }

banner() {
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
    ██████╗ ██╗      █████╗  ██████╗██╗  ██╗███╗  ██╗ ██████╗ ██████╗ ███████╗
    ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝████╗ ██║██╔═══██╗██╔══██╗██╔════╝
    ██████╔╝██║     ███████║██║     █████╔╝ ██╔██╗██║██║   ██║██║  ██║█████╗
    ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██║╚████║██║   ██║██║  ██║██╔══╝
    ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██║ ╚███║╚██████╔╝██████╔╝███████╗
    ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚══╝ ╚═════╝ ╚═════╝ ╚══════╝
EOF
    echo -e "${RESET}${DIM}                         dotfiles installer — by HollowSec${RESET}"
    echo ""
}

# Detect repo location regardless of clone name
detect_repo() {
    local candidates=(
        "$HOME/BlackNode"
        "$HOME/blacknode"
        "$HOME/BlackNode-git"
        "$HOME/blacknode-git"
        "$(dirname "$(realpath "$0")")"
    )

    REPO_DIR=""
    for c in "${candidates[@]}"; do
        if [[ -d "$c/Configs/.config" ]]; then
            REPO_DIR="$c"
            break
        fi
    done

    if [[ -z "$REPO_DIR" ]]; then
        gap
        echo -e "  ${CYAN}?${RESET} Could not find the repo automatically."
        echo -e "  ${CYAN}?${RESET} Enter the full path to your BlackNode repo:"
        read -rp "  > " REPO_DIR
        [[ -d "$REPO_DIR/Configs/.config" ]] || die "No Configs/.config found in: $REPO_DIR"
    fi

    DOTFILES_DIR="$REPO_DIR/Configs/.config"
    SCRIPTS_DIR="$REPO_DIR/Configs/.local/bin"
    ok "Repo found: $REPO_DIR"
}

# Install yay if missing
ensure_yay() {
    if command -v yay &>/dev/null; then
        ok "yay already installed."
        return
    fi
    info "Installing yay from AUR…"
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay installed."
}

# Ask what to install
declare -A GROUPS_SELECTED

ask_groups() {
    gap
    echo -e "${BOLD}  What do you want to install?${RESET} ${DIM}(press Enter to accept default Y)${RESET}"
    echo ""

    prompt_group() {
        local key="$1" label="$2"
        echo -e "  ${CYAN}?${RESET} $label ${DIM}[Y/n]${RESET}:"
        read -rp "  > " ans
        ans="${ans:-y}"
        [[ "$ans" =~ ^[Yy]$ ]] && GROUPS_SELECTED["$key"]=1 || GROUPS_SELECTED["$key"]=0
    }

    prompt_group "hyprland"  "Hyprland + hyprlock + hypridle + hyprpaper + portals"
    prompt_group "waybar"    "Waybar (status bar)"
    prompt_group "dunst"     "Dunst (notifications)"
    prompt_group "rofi"      "Rofi (launcher)"
    prompt_group "wlogout"   "Wlogout (logout menu)"
    prompt_group "sddm"      "SDDM (display manager)"
    prompt_group "terminal"  "Kitty + ZSH + plugins + Powerlevel10k"
    prompt_group "audio"     "Pipewire + Wireplumber + PulseAudio"
    prompt_group "bluetooth" "Bluetooth (bluez + blueman)"
    prompt_group "network"   "NetworkManager + applet"
    prompt_group "files"     "Thunar + CLI tools (fzf, bat, eza, btop…)"
    prompt_group "theme"     "GTK/Qt themes + Papirus + Catppuccin"
    prompt_group "fonts"     "Nerd Fonts (Meslo, JetBrains Mono, Font Awesome…)"
    prompt_group "screen"    "Screenshot tools (grim, slurp, swappy)"
    prompt_group "apps"      "Apps (Firefox, mpv, imv, VS Code)"
    prompt_group "wallust"   "wallust (dynamic colour palette from wallpaper)"
    prompt_group "swww"      "swww (animated wallpaper daemon)"
}

# Ask for wallpaper directory
ask_wallpaper_dir() {
    gap
    echo -e "  ${CYAN}?${RESET} Where are your wallpapers? ${DIM}(used for wallust init — leave blank to skip)${RESET}"
    echo -e "  ${DIM}  Suggestion: $HOME/Pictures/wallpapers${RESET}"
    read -rp "  > " WALL_DIR
    WALL_DIR="${WALL_DIR:-}"
    WALL_DIR="${WALL_DIR/#\~/$HOME}"

    if [[ -n "$WALL_DIR" ]]; then
        mkdir -p "$WALL_DIR"
        ok "Wallpaper dir: $WALL_DIR"
    else
        info "Wallpaper setup skipped."
    fi
}

# Collect packages based on selections
PKGS_PACMAN=()
PKGS_AUR=()

collect_packages() {
    [[ "${GROUPS_SELECTED[hyprland]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(
            hyprland hyprlock hypridle hyprpaper hyprpicker
            xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
            qt5-wayland qt6-wayland polkit-kde-agent
        )
        PKGS_AUR+=(hyprshot)
    }

    [[ "${GROUPS_SELECTED[waybar]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(waybar playerctl libpulse libnm)
    }

    [[ "${GROUPS_SELECTED[dunst]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(dunst libnotify)
    }

    [[ "${GROUPS_SELECTED[rofi]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(rofi-wayland)
        PKGS_AUR+=(rofi-calc)
    }

    [[ "${GROUPS_SELECTED[wlogout]:-0}" -eq 1 ]] && {
        PKGS_AUR+=(wlogout)
    }

    [[ "${GROUPS_SELECTED[sddm]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(sddm qt6-declarative qt6-svg)
        PKGS_AUR+=(sddm-theme-catppuccin)
    }

    [[ "${GROUPS_SELECTED[terminal]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(kitty zsh zsh-completions)
        PKGS_AUR+=(
            zsh-autosuggestions
            zsh-syntax-highlighting
            zsh-history-substring-search
            zsh-you-should-use
            fzf-tab-git
            zsh-theme-powerlevel10k
        )
    }

    [[ "${GROUPS_SELECTED[audio]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(pipewire pipewire-alsa pipewire-pulse wireplumber pamixer pavucontrol)
    }

    [[ "${GROUPS_SELECTED[bluetooth]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(bluez bluez-utils blueman)
    }

    [[ "${GROUPS_SELECTED[network]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(networkmanager nm-connection-editor network-manager-applet)
    }

    [[ "${GROUPS_SELECTED[files]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(
            thunar thunar-archive-plugin file-roller gvfs gvfs-mtp
            ranger fzf fd ripgrep bat eza zoxide btop fastfetch
        )
        PKGS_AUR+=(ueberzugpp)
    }

    [[ "${GROUPS_SELECTED[theme]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(
            gtk-engine-murrine gnome-themes-extra papirus-icon-theme
            breeze qt5ct qt6ct kvantum nwg-look
        )
        PKGS_AUR+=(catppuccin-gtk-theme-mocha)
    }

    [[ "${GROUPS_SELECTED[fonts]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(ttf-font-awesome ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji noto-fonts-cjk)
        PKGS_AUR+=(ttf-meslo-nerd ttf-jetbrains-mono-nerd)
    }

    [[ "${GROUPS_SELECTED[screen]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(grim slurp swappy brightnessctl wf-recorder)
    }

    [[ "${GROUPS_SELECTED[apps]:-0}" -eq 1 ]] && {
        PKGS_PACMAN+=(firefox mpv imv)
        PKGS_AUR+=(visual-studio-code-bin)
    }

    [[ "${GROUPS_SELECTED[wallust]:-0}" -eq 1 ]] && {
        PKGS_AUR+=(wallust)
    }

    [[ "${GROUPS_SELECTED[swww]:-0}" -eq 1 ]] && {
        PKGS_AUR+=(swww)
    }

    # Base tools always installed
    PKGS_PACMAN+=(wl-clipboard cliphist xwayland curl wget git base-devel zip unzip)
    PKGS_AUR+=(clipse)
}

install_packages() {
    gap
    info "Updating system…"
    sudo pacman -Syu --noconfirm

    if [[ ${#PKGS_PACMAN[@]} -gt 0 ]]; then
        info "Installing ${#PKGS_PACMAN[@]} pacman packages…"
        sudo pacman -S --needed --noconfirm "${PKGS_PACMAN[@]}" || warn "Some pacman packages may have failed."
    fi

    if [[ ${#PKGS_AUR[@]} -gt 0 ]]; then
        info "Installing ${#PKGS_AUR[@]} AUR packages…"
        yay -S --needed --noconfirm "${PKGS_AUR[@]}" || warn "Some AUR packages may have failed."
    fi

    ok "Packages done."
}

# Back up existing configs before overwriting
backup_configs() {
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    local configs=(hypr waybar dunst rofi wlogout hyprlock kitty sddm gtk-3.0 gtk-4.0 qt5ct qt6ct kvantum)
    local count=0

    mkdir -p "$backup_dir"
    for cfg in "${configs[@]}"; do
        if [[ -e "$HOME/.config/$cfg" ]]; then
            cp -r "$HOME/.config/$cfg" "$backup_dir/"
            count=$((count + 1))
        fi
    done

    if [[ $count -gt 0 ]]; then
        ok "Backed up $count config(s) → $backup_dir"
    else
        rmdir "$backup_dir" 2>/dev/null || true
        info "Nothing to back up."
    fi
}

# Symlink everything from Configs/.config into ~/.config
deploy_configs() {
    mkdir -p "$HOME/.config"

    for src in "$DOTFILES_DIR"/*/; do
        local name
        name="$(basename "$src")"
        local dest="$HOME/.config/$name"
        [[ -L "$dest" ]] && rm "$dest"
        [[ -d "$dest" ]] && rm -rf "$dest"
        ln -sf "$src" "$dest"
        ok "Linked: ~/.config/$name"
    done

    if [[ -d "$SCRIPTS_DIR" ]]; then
        mkdir -p "$HOME/.local/bin"
        for script in "$SCRIPTS_DIR"/*; do
            local sname
            sname="$(basename "$script")"
            ln -sf "$script" "$HOME/.local/bin/$sname"
            chmod +x "$script"
            ok "Script: ~/.local/bin/$sname"
        done
    fi
}

# Set zsh as default shell
setup_shell() {
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        info "Setting ZSH as default shell…"
        chsh -s "$(command -v zsh)"
        ok "Shell set to ZSH (re-login to apply)."
    else
        ok "ZSH is already default."
    fi
}

# Enable relevant system and user services
enable_services() {
    local system_svcs=(NetworkManager bluetooth sddm)
    local user_svcs=(pipewire pipewire-pulse wireplumber)

    for svc in "${system_svcs[@]}"; do
        if systemctl list-unit-files --type=service 2>/dev/null | grep -q "^${svc}.service"; then
            sudo systemctl enable --now "$svc" 2>/dev/null && ok "Enabled: $svc" || warn "Failed: $svc"
        fi
    done

    for svc in "${user_svcs[@]}"; do
        systemctl --user enable --now "$svc" 2>/dev/null && ok "User service enabled: $svc" || warn "Failed: $svc"
    done
}

# Configure SDDM theme
configure_sddm() {
    [[ "${GROUPS_SELECTED[sddm]:-0}" -ne 1 ]] && return
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/blacknode.conf > /dev/null <<EOF
[Theme]
Current=catppuccin-mocha
EOF
    ok "SDDM theme → catppuccin-mocha"
}

# Run wallust on the first wallpaper found
init_wallust() {
    [[ "${GROUPS_SELECTED[wallust]:-0}" -ne 1 ]] && return
    command -v wallust &>/dev/null || { warn "wallust not in PATH, skipping."; return; }

    local wall=""

    if [[ -n "${WALL_DIR:-}" ]]; then
        wall="$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) 2>/dev/null | head -1)"
    fi

    if [[ -z "$wall" ]]; then
        for c in \
            "$REPO_DIR/Configs/wallpapers/default.jpg" \
            "$REPO_DIR/Configs/wallpapers/default.png" \
            "$HOME/Pictures/wallpaper.jpg" \
            "$HOME/Pictures/wallpaper.png"
        do
            [[ -f "$c" ]] && { wall="$c"; break; }
        done
    fi

    if [[ -n "$wall" ]]; then
        wallust run "$wall"
        ok "wallust palette generated from: $(basename "$wall")"
    else
        warn "No wallpaper found. Run 'wallust run <image>' manually."
    fi
}

# Refresh fonts and create standard directories
misc_setup() {
    fc-cache -fv &>/dev/null
    ok "Font cache refreshed."
    xdg-user-dirs-update 2>/dev/null || true
    mkdir -p "$HOME/Pictures/screenshots" "$HOME/Pictures/wallpapers" "$HOME/.local/share/applications"
    ok "XDG directories ready."
}

# Print keybindings in a clean table
print_keybinds() {
    echo ""
    echo -e "${BOLD}${MAGENTA}  Keybindings${RESET}"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────${RESET}"

    row() { printf "  ${CYAN}%-28s${RESET} ${DIM}│${RESET}  %s\n" "$1" "$2"; }

    row "SUPER + D"            "Terminal (kitty)"
    row "SUPER + R"            "Rofi launcher"
    row "CTRL + ALT + ↑"       "App launcher"
    row "SUPER + SPACE"        "BlackNode menu"
    row "SUPER + B"            "Browser"
    row "SUPER + E"            "File manager"
    row "SUPER + C"            "Clipboard (clipse)"
    row "SUPER + H"            "Screenshot"
    row "SUPER + W"            "Wallpaper selector"
    row "SUPER + L"            "Lock screen (hyprlock)"
    row "SUPER + X"            "Logout"
    row "SUPER + SHIFT + X"    "Logout menu (wlogout)"
    row "SUPER + SHIFT + D"    "Toggle Do Not Disturb"
    row "SUPER + S"            "Toggle scratchpad"
    row "SUPER + SHIFT + S"    "Move to scratchpad"
    row "SUPER + F"            "Toggle floating"
    row "SUPER + SHIFT + F"    "Fullscreen"
    row "SUPER + Q"            "Kill window"
    row "SUPER + 1–9"          "Switch workspace"
    row "SUPER + SHIFT + 1–9"  "Move window to workspace"
    row "SUPER + ←↑↓→"         "Move focus"
    row "SUPER + Scroll"       "Cycle workspaces"
    row "SUPER + LMB drag"     "Move window"
    row "SUPER + RMB drag"     "Resize window"
    row "XF86AudioRaise/Lower" "Volume ±5%"
    row "XF86AudioMute"        "Toggle mute"
    row "XF86Brightness Up/Dn" "Brightness ±2%"
    row "XF86AudioNext/Prev"   "Next / previous track"
    row "XF86AudioPlay"        "Play / pause"

    echo -e "${DIM}  ────────────────────────────────────────────────────────────${RESET}"
}

# Final message
print_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}  ╔══════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${GREEN}  ║       Installation Complete ✓            ║${RESET}"
    echo -e "${BOLD}${GREEN}  ╠══════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${GREEN}  ║${RESET}  Repo    : ${BOLD}$REPO_DIR${RESET}"
    echo -e "${BOLD}${GREEN}  ║${RESET}  Configs : ${BOLD}$HOME/.config${RESET}"
    echo -e "${BOLD}${GREEN}  ║${RESET}"
    echo -e "${BOLD}${GREEN}  ║${RESET}  ${YELLOW}Next steps:${RESET}"
    echo -e "${BOLD}${GREEN}  ║${RESET}  1. Log out and select Hyprland in SDDM"
    echo -e "${BOLD}${GREEN}  ║${RESET}  2. Change wallpaper  →  SUPER + W"
    echo -e "${BOLD}${GREEN}  ║${RESET}  3. Open terminal     →  SUPER + D"
    echo -e "${BOLD}${GREEN}  ╚══════════════════════════════════════════╝${RESET}"
    echo ""
}

main() {
    [[ "$EUID" -eq 0 ]] && die "Do not run as root."

    banner
    detect_repo
    ensure_yay
    ask_groups
    ask_wallpaper_dir
    collect_packages
    install_packages
    backup_configs
    deploy_configs
    setup_shell
    enable_services
    configure_sddm
    init_wallust
    misc_setup
    print_keybinds
    print_summary
}

main "$@"
