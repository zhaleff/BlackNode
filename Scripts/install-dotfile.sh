#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/BlackNode/Configs"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

header() {
    clear
    echo -e "${CYAN}"
    echo "                         )                "
    echo "   (  (             ) ( /(      (         "
    echo " ( )\ )\   )     ( /( )\())     )\ )  (   "
    echo " )((_|(_| /(  (  )\()|(_)\  (  (()/( ))\  "
    echo "((_)_ _ )(_)) )\((_)\ _((_) )\  ((_))((_) "
    echo " | _ ) ((_)_ ((_) |(_) \| |((_) _| (_))   "
    echo " | _ \ / _\` / _|| / /| .  / _ Y _\` / -_)  "
    echo " |___/_\__,_\__||_\_\|_|\_\___|__,_\___|  "
    echo -e "${RESET}"
    echo -e "${DIM}${WHITE}  Dotfiles Installer · BlackNode Edition${RESET}"
    echo -e "${DIM}  ─────────────────────────────────────────────────────────────────────${RESET}"
    echo
}

step()    { echo -e "${CYAN}  ›${RESET} ${BOLD}$1${RESET}"; }
ok()      { echo -e "${GREEN}  ✓${RESET} $1"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET} $1"; }
fail()    { echo -e "${RED}  ✗${RESET} $1"; exit 1; }
ask()     { echo -e "${MAGENTA}  ?${RESET} ${BOLD}$1${RESET}"; }
divider() { echo -e "${DIM}  ─────────────────────────────────────────────────────────────────────${RESET}"; }

header

echo -e "${WHITE}${BOLD}  Initial Setup${RESET}"
divider
echo

ask "Do you already have yay installed? [y/N]"
read -r has_yay
echo

if [[ "$has_yay" =~ ^[yY]$ ]]; then
    if ! command -v yay &>/dev/null; then
        warn "yay not found in PATH. Installing anyway..."
        has_yay="n"
    else
        ok "yay detected."
    fi
fi

if [[ ! "$has_yay" =~ ^[yY]$ ]]; then
    step "Installing yay (AUR helper)..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git /tmp/yay_build
    cd /tmp/yay_build
    makepkg -si --noconfirm
    cd "$HOME"
    ok "yay installed."
fi

echo
echo -e "${WHITE}${BOLD}  Keyboard Layout${RESET}"
divider
echo
echo -e "  ${DIM}Available layouts:${RESET}"
echo
echo -e "  ${CYAN}[1]${RESET}   us          — English (US)"
echo -e "  ${CYAN}[2]${RESET}   gb          — English (UK)"
echo -e "  ${CYAN}[3]${RESET}   es          — Spanish (Spain)"
echo -e "  ${CYAN}[4]${RESET}   latam       — Spanish (Latin America)"
echo -e "  ${CYAN}[5]${RESET}   de          — German"
echo -e "  ${CYAN}[6]${RESET}   fr          — French"
echo -e "  ${CYAN}[7]${RESET}   it          — Italian"
echo -e "  ${CYAN}[8]${RESET}   pt          — Portuguese"
echo -e "  ${CYAN}[9]${RESET}   br          — Portuguese (Brazil)"
echo -e "  ${CYAN}[10]${RESET}  ru          — Russian"
echo -e "  ${CYAN}[11]${RESET}  jp          — Japanese"
echo -e "  ${CYAN}[12]${RESET}  kr          — Korean"
echo -e "  ${CYAN}[13]${RESET}  cn          — Chinese"
echo -e "  ${CYAN}[14]${RESET}  pl          — Polish"
echo -e "  ${CYAN}[15]${RESET}  nl          — Dutch"
echo -e "  ${CYAN}[16]${RESET}  tr          — Turkish"
echo -e "  ${CYAN}[17]${RESET}  ara         — Arabic"
echo -e "  ${CYAN}[18]${RESET}  se          — Swedish"
echo -e "  ${CYAN}[19]${RESET}  no          — Norwegian"
echo -e "  ${CYAN}[20]${RESET}  fi          — Finnish"
echo -e "  ${CYAN}[21]${RESET}  custom      — Enter manually"
echo

ask "Pick your layout number:"
read -r kb_choice
echo

KB_VARIANT=""
case "$kb_choice" in
    1)  KB_LAYOUT="us" ;;
    2)  KB_LAYOUT="gb" ;;
    3)  KB_LAYOUT="es" ;;
    4)  KB_LAYOUT="latam" ;;
    5)  KB_LAYOUT="de" ;;
    6)  KB_LAYOUT="fr" ;;
    7)  KB_LAYOUT="it" ;;
    8)  KB_LAYOUT="pt" ;;
    9)  KB_LAYOUT="br" ;;
    10) KB_LAYOUT="ru" ;;
    11) KB_LAYOUT="jp" ;;
    12) KB_LAYOUT="kr" ;;
    13) KB_LAYOUT="cn" ;;
    14) KB_LAYOUT="pl" ;;
    15) KB_LAYOUT="nl" ;;
    16) KB_LAYOUT="tr" ;;
    17) KB_LAYOUT="ara" ;;
    18) KB_LAYOUT="se" ;;
    19) KB_LAYOUT="no" ;;
    20) KB_LAYOUT="fi" ;;
    21)
        ask "Enter layout (e.g. us, es, gb, de):"
        read -r KB_LAYOUT
        ask "Enter variant (leave empty if none):"
        read -r KB_VARIANT
        ;;
    *)
        warn "Invalid option. Defaulting to 'us'."
        KB_LAYOUT="us"
        ;;
esac

ok "Layout set to: ${BOLD}$KB_LAYOUT${RESET}${GREEN}${KB_VARIANT:+ (variant: $KB_VARIANT)}"

echo
echo -e "${WHITE}${BOLD}  Installation Summary${RESET}"
divider
echo -e "  ${DIM}The following actions will be performed:${RESET}"
echo
echo -e "  ${CYAN}1.${RESET} Install pacman + AUR packages"
echo -e "  ${CYAN}2.${RESET} Clone zsh plugins + powerlevel10k"
echo -e "  ${CYAN}3.${RESET} Backup ~/.config  →  ${BOLD}$BACKUP_DIR${RESET}"
echo -e "  ${CYAN}4.${RESET} Copy dotfiles from $DOTFILES_DIR"
echo -e "  ${CYAN}5.${RESET} Patch input.conf with layout: ${BOLD}$KB_LAYOUT${RESET}"
echo -e "  ${CYAN}6.${RESET} Copy wallust cache"
echo -e "  ${CYAN}7.${RESET} Reload Hyprland"
echo
ask "Continue? [y/N]"
read -r confirm
echo
[[ "$confirm" =~ ^[yY]$ ]] || { warn "Installation cancelled."; exit 0; }

divider
echo

step "Installing pacman packages..."
sudo pacman -S --needed --noconfirm \
    waybar \
    rofi \
    zsh \
    hyprlock \
    hypridle \
    pavucontrol \
    neovim \
    wlogout \
    wl-clipboard \
    grim \
    slurp \
    swappy \
    xdg-user-dirs \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    polkit-gnome \
    brightnessctl \
    playerctl \
    jq \
    curl \
    wget \
    unzip \
    zip \
    ripgrep \
    fd \
    bat \
    fzf \
    nwg-look
ok "Pacman packages installed."

echo

step "Installing AUR packages..."
yay -S --needed --noconfirm \
    wallust \
    hyprshot
ok "AUR packages installed."

echo

step "Setting up zsh plugins directory..."
mkdir -p "$ZSH_PLUGINS_DIR"

declare -A PLUGINS=(
    ["alias-tips"]="https://github.com/djui/alias-tips"
    ["zsh-bd"]="https://github.com/Tarrasch/zsh-bd"
    ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
    ["zsh-fzf-history-search"]="https://github.com/joshskidmore/zsh-fzf-history-search"
    ["fzf-zsh-plugin"]="https://github.com/unixorn/fzf-zsh-plugin"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
    ["zsh-autocomplete"]="https://github.com/marlonrichert/zsh-autocomplete"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-autopair"]="https://github.com/hlissner/zsh-autopair"
    ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use"
)

for plugin in "${!PLUGINS[@]}"; do
    target="$ZSH_PLUGINS_DIR/$plugin"
    if [[ -d "$target" ]]; then
        warn "Plugin '$plugin' already exists, pulling latest..."
        git -C "$target" pull --quiet
    else
        step "Cloning $plugin..."
        git clone --depth=1 "${PLUGINS[$plugin]}" "$target" --quiet
    fi
    ok "$plugin"
done

echo

step "Installing powerlevel10k..."
P10K_DIR="$HOME/.zsh/themes/powerlevel10k"
mkdir -p "$HOME/.zsh/themes"
if [[ -d "$P10K_DIR" ]]; then
    warn "powerlevel10k already exists, pulling..."
    git -C "$P10K_DIR" pull --quiet
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" --quiet
fi
ok "powerlevel10k ready."

echo

step "Backing up ~/.config to $BACKUP_DIR..."
if [[ -d "$HOME/.config" ]]; then
    cp -r "$HOME/.config" "$BACKUP_DIR"
    ok "Backup created at $BACKUP_DIR"
else
    warn "No existing ~/.config found, skipping backup."
fi

echo

step "Copying dotfiles to ~/.config/..."
[[ -d "$DOTFILES_DIR/.config" ]] || fail "Dotfiles not found at $DOTFILES_DIR/.config"
cp -rf "$DOTFILES_DIR/.config/"* "$HOME/.config/"
ok "Dotfiles copied."

echo

step "Patching Hyprland input.conf with layout: $KB_LAYOUT..."
INPUT_CONF="$HOME/.config/hypr/settings/input.conf"
[[ -f "$INPUT_CONF" ]] || fail "input.conf not found at $INPUT_CONF"

cat > "$INPUT_CONF" <<EOF
input {
    kb_layout = $KB_LAYOUT
    kb_variant = $KB_VARIANT
    kb_model =
    kb_options =
    kb_rules =
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
}
EOF

ok "input.conf patched."

echo

step "Copying wallust cache..."
WALLUST_SRC="$DOTFILES_DIR/.cache/wallust"
if [[ -d "$WALLUST_SRC" ]]; then
    mkdir -p "$HOME/.cache/wallust"
    cp -rf "$WALLUST_SRC/"* "$HOME/.cache/wallust/"
    ok "wallust cache copied."
else
    warn "No wallust cache found at $WALLUST_SRC, skipping."
fi

echo

step "Moving .zshrc to home..."
ZSHRC_SRC="$HOME/.config/zsh/.zshrc"
if [[ -f "$ZSHRC_SRC" ]]; then
    cp "$ZSHRC_SRC" "$HOME/.zshrc"
    ok ".zshrc placed at ~/.zshrc"
else
    warn ".zshrc not found at $ZSHRC_SRC"
fi

echo

step "Setting zsh as default shell..."
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
    ok "Default shell set to zsh."
else
    ok "zsh is already the default shell."
fi

echo

if ! command -v wallust &>/dev/null; then
    warn "wallust not found in PATH — make sure it's installed before running awww."
else
    ok "wallust found."
fi

echo

step "Reloading Hyprland..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload
    ok "Hyprland reloaded."
else
    warn "hyprctl not found — are you inside a Hyprland session? Run: hyprctl reload"
fi

echo
divider
echo
echo -e "${GREEN}${BOLD}  All done.${RESET}"
echo -e "${DIM}  Restart your terminal or run: exec zsh${RESET}"
echo
