#!/usr/bin/env bash

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$HOME/BlackNode/Configs"
config_src="$repo/.config"
cache_src="$repo/.cache/wallust"
config_dst="$HOME/.config"
cache_dst="$HOME/.cache/wallust"
plugins_dir="$HOME/.zsh/plugins"

reset="\033[0m"
cyan="\033[0;36m"
green="\033[0;32m"
yellow="\033[1;33m"

ok()   { echo -e "${green}✓${reset} $*"; }
info() { echo -e "${cyan}→${reset} $*"; }
warn() { echo -e "${yellow}!${reset} $*"; }

[[ -f "$script_dir/welcome.sh" ]] && bash "$script_dir/welcome.sh"

if command -v paru &>/dev/null; then
    pkg="paru -S --noconfirm --needed"
elif command -v yay &>/dev/null; then
    pkg="yay -S --noconfirm --needed"
else
    pkg="sudo pacman -S --noconfirm --needed"
fi

packages=(
    zsh
    ttf-jetbrains-mono-nerd
    noto-fonts-emoji
    fzf fd bat ripgrep eza zoxide
    alacritty kitty
    fastfetch cava
    rofi-wayland
    wlogout
    clipse
    nwg-look qt5ct qt6ct
    sddm
    python-pywal
    dunst libnotify
    jq git curl wget unzip
)

info "Installing packages..."
for p in "${packages[@]}"; do
    $pkg "$p" && ok "$p"
done

if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Changing shell to zsh..."
    chsh -s "$(which zsh)" "$USER"
    ok "Shell changed to zsh"
fi

mkdir -p "$plugins_dir"

declare -A plugin_repos=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
    [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [zsh-autopair]="https://github.com/hlissner/zsh-autopair"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
    [zsh-you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
    [fzf-zsh-plugin]="https://github.com/unixorn/fzf-zsh-plugin"
    [zsh-fzf-history-search]="https://github.com/joshskidmore/zsh-fzf-history-search"
    [powerlevel10k]="https://github.com/romkatv/powerlevel10k"
)

for plugin in "${!plugin_repos[@]}"; do
    target="$plugins_dir/$plugin"
    if [[ -d "$target/.git" ]]; then
        git -C "$target" pull --quiet && ok "$plugin updated"
    else
        git clone --depth=1 "${plugin_repos[$plugin]}" "$target" && ok "$plugin cloned"
    fi
done

info "Copying dotfiles..."
for dir in "$config_src"/*/; do
    name="$(basename "$dir")"
    mkdir -p "$config_dst/$name"
    cp -r "$dir/." "$config_dst/$name/"
    ok "$name"
done

info "Copying wallust cache..."
mkdir -p "$cache_dst"
cp -r "$cache_src/." "$cache_dst/"
ok "wallust cache"

for d in "$config_dst/hypr/scripts" "$config_dst/waybar/scripts" "$config_dst/rofi/scripts"; do
    [[ -d "$d" ]] && chmod +x "$d"/*.sh 2>/dev/null
done

systemctl list-unit-files sddm.service &>/dev/null && sudo systemctl enable sddm.service

if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    info "Reloading Hyprland..."
    hyprctl reload
    sleep 1

    info "Restarting Waybar..."
    pkill -x waybar 2>/dev/null || true
    sleep 0.5
    nohup waybar &>/dev/null &
    disown
    ok "Waybar started"

    pkill -x dunst 2>/dev/null || true
    sleep 0.3
    nohup dunst &>/dev/null &
    disown
    ok "Dunst restarted"
fi

ok "BlackNode setup complete"
