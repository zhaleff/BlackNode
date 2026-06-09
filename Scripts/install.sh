#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/BlackNode/Configs/.config"
LOCAL_BIN_SRC="$DOTFILES_DIR/BlackNode/Configs/.local/bin"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
CONFIG_DEST="$HOME/.config"
LOCAL_BIN_DEST="$HOME/.local/bin"

PACMAN_PKGS=(
    waybar
    cava
    rofi-wayland
    nerd-fonts
    gtk3
    gtk4
    hyprlock
    hypridle
    neovim
    dunst
    fastfetch
    sddm
    yazi
    zsh
    kitty
    matugen
    fzf
    wget
    curl
    git
    base-devel
)

AUR_PKGS=(
    wlogout
    aylurs-gtk-shell
    clipse-bin
    powerlevel10k-git
)

ZSH_PLUGINS=(
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-autopair https://github.com/hlissner/zsh-autopair"
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting"
    "fzf-tab https://github.com/Aloxaf/fzf-tab"
    "zsh-you-should-use https://github.com/MichaelAquilina/zsh-you-should-use"
    "zsh-fzf-history-search https://github.com/joshskidmore/zsh-fzf-history-search"
    "zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search"
    "zsh-completions https://github.com/zsh-users/zsh-completions"
    "fzf-zsh-plugin https://github.com/unixorn/fzf-zsh-plugin"
)

CONFIG_DIRS=(
    cava
    clipse
    dunst
    fastfetch
    grub
    gtk-3.0
    gtk-4.0
    hypr
    kitty
    matugen
    nvim
    powerlevel10k
    qt5ct
    rofi
    sddm
    waybar
    wlogout
    yazi
    zsh
)

step()  { echo ""; echo "==> $1"; }
info()  { echo "  -> $1"; }
warn()  { echo "  [!] $1"; }

install_yay() {
    if command -v yay &>/dev/null; then
        info "yay is already installed"
        return
    fi
    info "Installing yay..."
    local tmp
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

install_pacman_packages() {
    step "Installing pacman packages"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
}

install_aur_packages() {
    step "Installing AUR packages"
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
}

create_backup() {
    step "Backing up existing configs"
    mkdir -p "$BACKUP_DIR"
    for dir in "${CONFIG_DIRS[@]}"; do
        local target="$CONFIG_DEST/$dir"
        if [[ -e "$target" && ! -L "$target" ]]; then
            info "Backup: $target"
            cp -r "$target" "$BACKUP_DIR/"
        fi
    done
    [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    [[ -e "$HOME/.zsh"   && ! -L "$HOME/.zsh"   ]] && cp -r "$HOME/.zsh" "$BACKUP_DIR/.zsh"
    info "Backup saved to: $BACKUP_DIR"
}

link_configs() {
    step "Symlinking ~/.config entries"
    mkdir -p "$CONFIG_DEST"
    for dir in "${CONFIG_DIRS[@]}"; do
        local src="$CONFIG_SRC/$dir"
        local dest="$CONFIG_DEST/$dir"
        if [[ ! -d "$src" ]]; then
            warn "Source not found, skipping: $src"
            continue
        fi
        [[ -L "$dest" ]]           && rm "$dest"
        [[ -d "$dest" && ! -L "$dest" ]] && rm -rf "$dest"
        ln -sf "$src" "$dest"
        info "Linked: $dest"
    done
}

link_local_bin() {
    step "Symlinking ~/.local/bin scripts"
    mkdir -p "$LOCAL_BIN_DEST"
    [[ ! -d "$LOCAL_BIN_SRC" ]] && return
    for file in "$LOCAL_BIN_SRC"/*; do
        [[ -f "$file" ]] || continue
        local name dest
        name="$(basename "$file")"
        dest="$LOCAL_BIN_DEST/$name"
        [[ -L "$dest" ]] && rm "$dest"
        ln -sf "$file" "$dest"
        chmod +x "$file"
        info "Linked: $dest"
    done
}

setup_zsh() {
    step "Setting up ZSH + plugins"

    local zsh_dir="$HOME/.zsh"
    mkdir -p "$zsh_dir/plugins"

    for entry in "${ZSH_PLUGINS[@]}"; do
        local name url
        name="${entry%% *}"
        url="${entry##* }"
        local path="$zsh_dir/plugins/$name"
        if [[ -d "$path" ]]; then
            info "Updating plugin: $name"
            git -C "$path" pull --quiet
        else
            info "Cloning plugin: $name"
            git clone --depth=1 "$url" "$path"
        fi
    done

    local zshrc_src="$CONFIG_SRC/zsh/configs/.zshrc"
    if [[ -f "$zshrc_src" ]]; then
        [[ -L "$HOME/.zshrc" ]] && rm "$HOME/.zshrc"
        ln -sf "$zshrc_src" "$HOME/.zshrc"
        info "Linked: ~/.zshrc"
    else
        warn ".zshrc not found at: $zshrc_src"
    fi

    if ! command -v powerlevel10k &>/dev/null && [[ ! -d /usr/share/zsh-theme-powerlevel10k ]]; then
        info "Installing powerlevel10k..."
        yay -S --needed --noconfirm powerlevel10k
    else
        info "powerlevel10k already installed"
    fi

    if [[ -f "$HOME/.zshrc" ]] && ! grep -q "POWERLEVEL9K_INSTANT_PROMPT" "$HOME/.zshrc"; then
        info "Disabling p10k instant prompt"
        local tmp
        tmp="$(mktemp)"
        { echo 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=off'; cat "$HOME/.zshrc"; } > "$tmp"
        cp "$tmp" "$HOME/.zshrc"
        rm "$tmp"
    fi

    if [[ "$(basename "$SHELL")" != "zsh" ]]; then
        info "Changing default shell to zsh"
        chsh -s "$(command -v zsh)" "$USER"
    fi
}

create_wallpaper_dir() {
    step "Wallpaper directory"
    mkdir -p "$HOME/Pictures/Wallpapers"
    warn "All wallpapers MUST be placed in: ~/Pictures/Wallpapers"
    warn "Hyprpaper, matugen, and theming scripts expect them there."
}

enable_sddm() {
    step "Enabling SDDM"
    if systemctl is-enabled sddm &>/dev/null; then
        info "SDDM is already enabled"
    else
        sudo systemctl enable sddm
        info "SDDM enabled"
    fi
}

main() {
    echo ""
    echo "  ·▄▄▄▄  ▄▄▄· ▄▄▄   ▄· ▄▌     ▄· ▄▌    ▄▄▄ .  ▐  ▄ ▄· ▄▌"
    echo "  ██▪ ██ ▐█ ▀█ ▀▄ █·▐█▪██▌    ▐█▪██▌    ▀▄.▀· •█▌▐█▐█▪██▌"
    echo "  ▐█· ▐█▌▄█▀▀█ ▐▀▀▄ ▐█▌▐█▪    ▐█▌▐█▪    ▐▀▀▪▄ ▐█▐▐▌▐█▌▐█▪"
    echo "  ██. ██ ▐█ ▪▐▌▐█•█▌ ▐█▀·.     ▐█▀·.    ▐█▄▄▌ ██▐█▌ ▐█▀·."
    echo "  ▀▀▀▀▀•  ▀  ▀ .▀  ▀  ▀ •       ▀ •      ▀▀▀  ▀▀ █▪  ▀ • "
    echo ""
    echo "  blacknode dotfiles — arch linux / hyprland"
    echo "  ─────────────────────────────────────────"
    echo ""

    if [[ ! -d "$CONFIG_SRC" ]]; then
        echo "ERROR: source not found at $CONFIG_SRC"
        echo "Run this script from the root of the BlackNode repository."
        exit 1
    fi

    install_yay
    install_pacman_packages
    install_aur_packages
    create_backup
    link_configs
    link_local_bin
    setup_zsh
    create_wallpaper_dir
    enable_sddm

    echo ""
    echo "==> Done."
    echo ""
    echo "  • Wallpapers go in:  ~/Pictures/Wallpapers"
    echo "  • Config backup at:  $BACKUP_DIR"
    echo "  • Log out and back in, or run: exec zsh"
    echo ""
}

main "$@"
