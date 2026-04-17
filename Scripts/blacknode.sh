#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGS="$REPO_DIR/Configs"

echo "==> Checking for yay..."
if ! command -v yay &>/dev/null; then
    echo "==> Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    (cd /tmp/yay-install && makepkg -si --noconfirm)
    rm -rf /tmp/yay-install
fi

echo "==> Installing packages..."
yay -S --needed --noconfirm \
    hyprland \
    hyprlock \
    hypridle \
    hyprshot \
    xdg-desktop-portal-hyprland \
    waybar \
    rofi-wayland \
    kitty \
    alacritty \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-history-substring-search \
    fzf-tab-git \
    neovim \
    yazi \
    fastfetch \
    cava \
    clipse \
    dunst \
    wlogout \
    wallust \
    swww \
    flatpak \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    playerctl \
    pamixer \
    network-manager-applet \
    polkit-kde-agent \
    nwg-look \
    qt5-wayland \
    qt6-wayland \
    sddm \
    thunar \
    ttf-jetbrains-mono-nerd \
    ttf-font-awesome \
    noto-fonts \
    noto-fonts-emoji

echo "==> Copying configs..."
mkdir -p ~/.config
cp -r "$CONFIGS/.config/"* ~/.config/

echo "==> Copying zsh plugins..."
mkdir -p ~/.zsh
cp -r "$CONFIGS/.config/zsh/plugins" ~/.zsh/

echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "==> Done. Reboot for all changes to take effect."
