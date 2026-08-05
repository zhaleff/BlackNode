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
    name="$(basename "$item")"
    [[ -d "$item" ]] && { echo "  · skip dir $name (not a binary)"; continue; }
    link_item "$item" "$HOME/.local/bin/$name" ".local/bin/$name"
done

if [[ -d "$REPO/Configs/.local/share/blacknode" ]]; then
    for item in "$REPO/Configs/.local/share/blacknode"/*; do
        link_item "$item" "$HOME/.local/share/blacknode/$(basename "$item")" ".local/share/blacknode/$(basename "$item")"
    done
fi

echo ""
echo "Building components"
BRAIN_DIR="$REPO/src/brain"
if [[ -f "$BRAIN_DIR/Cargo.toml" ]]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "  → building blacknode-brain (rust)"
        (cd "$BRAIN_DIR" && cargo build --release >/dev/null 2>&1) || echo "  ✗ brain build failed"
        if [[ -x "$BRAIN_DIR/target/release/blacknode-brain" ]]; then
            install -Dm755 "$BRAIN_DIR/target/release/blacknode-brain" "$HOME/.local/bin/blacknode-brain"
            echo "  → blacknode-brain installed"
        fi
    else
        echo "  ✗ cargo not found, skipping brain build"
    fi
fi

SETTINGS_DIR="$REPO/src/settings-center"
if [[ -f "$SETTINGS_DIR/Cargo.toml" ]]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "  → building settings-center (rust)"
        (cd "$SETTINGS_DIR" && cargo build --release >/dev/null 2>&1) || echo "  ✗ settings-center build failed"
        if [[ -x "$SETTINGS_DIR/target/release/settings-center" ]]; then
            install -Dm755 "$SETTINGS_DIR/target/release/settings-center" "$HOME/.local/bin/settings-center"
            echo "  → settings-center installed"
        fi
    else
        echo "  ✗ cargo not found, skipping settings-center build"
    fi
fi

WEATHER_DIR="$REPO/src/weather"
if [[ -f "$WEATHER_DIR/Cargo.toml" ]]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "  → building blacknode-weather (rust)"
        (cd "$WEATHER_DIR" && cargo build --release >/dev/null 2>&1) || echo "  ✗ weather build failed"
        if [[ -x "$WEATHER_DIR/target/release/blacknode-weather" ]]; then
            install -Dm755 "$WEATHER_DIR/target/release/blacknode-weather" "$HOME/.local/bin/blacknode-weather"
            echo "  → blacknode-weather installed"
        fi
    else
        echo "  ✗ cargo not found, skipping weather build"
    fi
fi

MUSIC_DIR="$REPO/src/music"
if [[ -f "$MUSIC_DIR/Cargo.toml" ]]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "  → building blacknode-music (rust)"
        (cd "$MUSIC_DIR" && cargo build --release >/dev/null 2>&1) || echo "  ✗ music build failed"
        if [[ -x "$MUSIC_DIR/target/release/blacknode-music" ]]; then
            install -Dm755 "$MUSIC_DIR/target/release/blacknode-music" "$HOME/.local/bin/blacknode-music"
            echo "  → blacknode-music installed"
        fi
    else
        echo "  ✗ cargo not found, skipping music build"
    fi
fi

TUTORIAL_DIR="$REPO/src/tutorial"
if [[ -f "$TUTORIAL_DIR/Cargo.toml" ]]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "  → building blacknode-tutorial (rust)"
        (cd "$TUTORIAL_DIR" && cargo build --release >/dev/null 2>&1) || echo "  ✗ tutorial build failed"
        if [[ -x "$TUTORIAL_DIR/target/release/blacknode-tutorial" ]]; then
            install -Dm755 "$TUTORIAL_DIR/target/release/blacknode-tutorial" "$HOME/.local/bin/blacknode-tutorial"
            echo "  → blacknode-tutorial installed"
        fi
    else
        echo "  ✗ cargo not found, skipping tutorial build"
    fi
fi

echo ""
echo "Done."
