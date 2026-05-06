#!/bin/zsh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${BLUE}=== BlackNode Dotfiles Installer ===${NC}"

echo "${YELLOW}Selecciona el layout del teclado:${NC}"
echo "1) en-us    2) en-uk    3) es"
echo "4) de       5) fr       6) it"
echo "7) pt       8) ru       9) jp"
echo "10) sv      11) da      12) no"
echo "13) pl      14) cz      15) sk"
echo "16) hu      17) ro      18) bg"
echo "19) hr      20) si      21) et"
echo "22) lv      23) lt      24) fi"
echo "25) tr      26) gr      27) il"
echo "28) ar      29) th      30) vi"
echo "31) ko      32) zh-cn   33) zh-tw"
read -r KB_CHOICE

case $KB_CHOICE in
  1) KB_LAYOUT="en-us" ;;
  2) KB_LAYOUT="en-uk" ;;
  3) KB_LAYOUT="es" ;;
  4) KB_LAYOUT="de" ;;
  5) KB_LAYOUT="fr" ;;
  6) KB_LAYOUT="it" ;;
  7) KB_LAYOUT="pt" ;;
  8) KB_LAYOUT="ru" ;;
  9) KB_LAYOUT="jp" ;;
  10) KB_LAYOUT="sv" ;;
  11) KB_LAYOUT="da" ;;
  12) KB_LAYOUT="no" ;;
  13) KB_LAYOUT="pl" ;;
  14) KB_LAYOUT="cz" ;;
  15) KB_LAYOUT="sk" ;;
  16) KB_LAYOUT="hu" ;;
  17) KB_LAYOUT="ro" ;;
  18) KB_LAYOUT="bg" ;;
  19) KB_LAYOUT="hr" ;;
  20) KB_LAYOUT="si" ;;
  21) KB_LAYOUT="et" ;;
  22) KB_LAYOUT="lv" ;;
  23) KB_LAYOUT="lt" ;;
  24) KB_LAYOUT="fi" ;;
  25) KB_LAYOUT="tr" ;;
  26) KB_LAYOUT="gr" ;;
  27) KB_LAYOUT="il" ;;
  28) KB_LAYOUT="ar" ;;
  29) KB_LAYOUT="th" ;;
  30) KB_LAYOUT="vi" ;;
  31) KB_LAYOUT="ko" ;;
  32) KB_LAYOUT="zh-cn" ;;
  33) KB_LAYOUT="zh-tw" ;;
  *) KB_LAYOUT="es" ;;
esac

sed -i "s/^    kb_layout = .*/    kb_layout = $KB_LAYOUT/" ~/BlackNode/Configs/.config/hypr/settings/input.conf
echo "${GREEN}Layout configurado: $KB_LAYOUT${NC}"

echo "${YELLOW}¿Tienes yay instalado? (s/n)${NC}"
read -r HAS_YAY
if [ "$HAS_YAY" != "s" ]; then
  echo "${BLUE}Instalando yay...${NC}"
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  rm -rf /tmp/yay
fi

echo "${BLUE}Instalando paquetes...${NC}"
sudo pacman -S --needed waybar rofi zsh hyprlock hypridle pavucontrol nwg-look hyprshot neovim wlogout git base-devel

echo "${BLUE}Instalando wallust...${NC}"
yay -S --needed wallust

if [ -d ~/.config ]; then
  BACKUP_DIR=~/.config.bak.$(date +%Y%m%d%H%M%S)
  echo "${YELLOW}Respaldando .config en $BACKUP_DIR${NC}"
  mv ~/.config "$BACKUP_DIR"
fi

echo "${BLUE}Copiando dotfiles...${NC}"
mkdir -p ~/.config
cp -r ~/BlackNode/Configs/.config/* ~/.config/

echo "${BLUE}Configurando zsh...${NC}"
cp ~/BlackNode/Configs/.config/zsh/.zshrc ~/.zshrc

mkdir -p ~/.zsh/plugins/
PLUGINS_DIR=~/.zsh/plugins

git clone https://github.com/romkatv/powerlevel10k.git "$PLUGINS_DIR/powerlevel10k" || true
git clone https://github.com/djui/alias-tips.git "$PLUGINS_DIR/alias-tips" || true
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$PLUGINS_DIR/fast-syntax-highlighting" || true
git clone https://github.com/Aloxaf/fzf-tab.git "$PLUGINS_DIR/fzf-tab" || true
git clone https://github.com/posva/fzf-zsh-plugin.git "$PLUGINS_DIR/fzf-zsh-plugin" || true
git clone https://github.com/marlonrichert/zsh-autocomplete.git "$PLUGINS_DIR/zsh-autocomplete" || true
git clone https://github.com/hlissner/zsh-autopair.git "$PLUGINS_DIR/zsh-autopair" || true
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGINS_DIR/zsh-autosuggestions" || true
git clone https://github.com/Tarrasch/zsh-bd.git "$PLUGINS_DIR/zsh-bd" || true
git clone https://github.com/zsh-users/zsh-completions.git "$PLUGINS_DIR/zsh-completions" || true
git clone https://github.com/joshskidmore/zsh-fzf-history-search.git "$PLUGINS_DIR/zsh-fzf-history-search" || true
git clone https://github.com/zsh-users/zsh-history-substring-search.git "$PLUGINS_DIR/zsh-history-substring-search" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting" || true
git clone https://github.com/jeffreytse/zsh-vi-mode.git "$PLUGINS_DIR/zsh-vi-mode" || true
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$PLUGINS_DIR/zsh-you-should-use" || true

echo "${BLUE}Copiando wallust cache...${NC}"
mkdir -p ~/.cache/wallust
cp -r ~/BlackNode/Configs/.cache/wallust/* ~/.cache/wallust/ 2>/dev/null || true

echo "${GREEN}Recargando Hyprland...${NC}"
hyprctl reload

echo "${BLUE}Reiniciando servicios...${NC}"
killall waybar; waybar & disown
killall hyprlock; hyprlock & disown

if ! command -v wallust &> /dev/null; then
  echo "${RED}Advertencia: wallust no está instalado${NC}"
fi

echo "${GREEN}Instalación completada${NC}"
exec zsh
