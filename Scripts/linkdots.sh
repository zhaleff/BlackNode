#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP="$HOME/.config/blacknode-backup-$(date +%Y%m%d%H%M%S)"

link_item() {
    local src="$1" dst="$2" name="$3"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  ✓ $name"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "$name")"
        mv "$dst" "$BACKUP/$name"
        echo "  ✗ $name backed up"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  → $name linked"
}

echo "BlackNode — linking dotfiles"
echo "Repo: $REPO"
echo "Backup: $BACKUP"
echo ""

shopt -s nullglob
for item in "$REPO/Configs/.config"/*; do
    link_item "$item" "$HOME/.config/$(basename "$item")" ".config/$(basename "$item")"
done

for item in "$REPO/Configs/.local/bin"/*; do
    link_item "$item" "$HOME/.local/bin/$(basename "$item")" ".local/bin/$(basename "$item")"
done

if [[ -d "$REPO/Configs/.local/share/blacknode" ]]; then
    for item in "$REPO/Configs/.local/share/blacknode"/*; do
        link_item "$item" "$HOME/.local/share/blacknode/$(basename "$item")" ".local/share/blacknode/$(basename "$item")"
    done
fi

echo ""
echo "Done."
