<p align="center">
  <img src="./Assets/BlackNode-Logo.png" width="100%" alt="BlackNode Banner">
</p>


<h1 align="center">BlackNode // Installation Guide</h1>
<div align="center">

<a href="https://github.com/zhaleff/BlackNode/stargazers"><img src="https://img.shields.io/github/stars/zhaleff/BlackNode?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=C9CBFF&labelColor=302D41" alt="stars"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/forks"><img src="https://img.shields.io/github/forks/zhaleff/BlackNode?style=for-the-badge&logo=git&logoColor=f9e2af&label=Forks&labelColor=302D41&color=f9e2af" alt="forks"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/issues"><img src="https://img.shields.io/github/issues/zhaleff/BlackNode?style=for-the-badge&logo=github&logoColor=eba0ac&label=Issues&labelColor=302D41&color=eba0ac" alt="issues"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/commits/main"><img src="https://img.shields.io/github/last-commit/zhaleff/BlackNode?style=for-the-badge&logo=github&logoColor=white&label=Last%20Commit&labelColor=302D41&color=A6E3A1" alt="last commit"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/blob/main/LICENSE"><img src="https://img.shields.io/github/license/zhaleff/BlackNode?style=for-the-badge&logo=open-source-initiative&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="license"></a>&nbsp;&nbsp;


</div>

#

<div align="center">

<a href="#1--clone-the-repo"><kbd> <br> 1. Clone <br> </kbd></a>&ensp;&ensp;
<a href="#2--install-dependencies"><kbd> <br> 2. Dependencies <br> </kbd></a>&ensp;&ensp;
<a href="#3--link-configs"><kbd> <br> 3. Link Configs <br> </kbd></a>&ensp;&ensp;
<a href="#4--first-login"><kbd> <br> 4. First Login <br> </kbd></a>&ensp;&ensp;
<a href="#troubleshooting"><kbd> <br> Troubleshooting <br> </kbd></a>&ensp;&ensp;


</div>

#

#

<a id="1--clone-the-repo"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=1.+CLONE+THE+REPO" width="435"/>

```bash
git clone https://github.com/zhaleff/BlackNode.git $HOME/BlackNode
cd $HOME/BlackNode
```

> [!IMPORTANT]
> BlackNode targets **Arch Linux**. It may work on derivatives but this has not been tested.



<a id="2--install-dependencies"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=2.+INSTALL+DEPENDENCIES" width="435"/>

BlackNode requires **Hyprland 0.55+** (Lua config). Install the core packages:

```bash
# Official repos
sudo pacman -S --needed \
  hyprland waybar rofi-wayland kitty alacritty neovim \
  dunst hyprlock hypridle fastfetch yazi zsh fzf \
  matugen sddm gtk3 gtk4 ttf-jetbrains-mono nerd-fonts

# AUR helper
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si --noconfirm && cd -

# AUR packages
yay -S --needed wlogout clipse-bin powerlevel10k-git
```

> [!TIP]
> If you already have these packages, skip straight to step 3.



<a id="3--link-configs"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=3.+LINK+CONFIGS" width="435"/>

The `linkdots` script creates symlinks from `BlackNode/Configs/` to `~/.config/` and `~/.local/bin/`. Existing files are backed up automatically.

```bash
bash Scripts/linkdots.sh
```

What it does:

1. **Backs up** existing `~/.config/*` and `~/.local/bin/*` files to `~/.config/blacknode-backup-<timestamp>/`
2. **Symlinks** every directory in `Configs/.config/` to `~/.config/`
3. **Symlinks** every file in `Configs/.local/bin/` to `~/.local/bin/`
4. **Skips** entries that are already correctly linked

> [!WARNING]
> This overwrites your existing configs. Backup is automatic, but make sure you know what you are replacing.

### What Gets Linked

```
~/.config/
├── hypr/          → Hyprland 0.55+ Lua config (keybinds, rules, input, overrides)
├── rofi/          → M3-themed launcher, bn-menu, sidebar scripts, shared themes
├── waybar/        → 3 bar styles (Classic, Hacking, Minimal)
├── kitty/         → Terminal with Catppuccin theme
├── alacritty/     → Terminal (optional)
├── dunst/         → M3 notification daemon
├── wlogout/       → Logout screen
├── fastfetch/     → M3 two-box fetch
├── zsh/           → Plugins, aliases, completions
├── nvim/          → Neovim config
├── yazi/          → File manager
├── cava/          → Audio visualiser
├── clipse/        → Clipboard manager
├── matugen/       → Colour generation templates
├── qt5ct/         → Qt5 theming
├── powerlevel10k/ → Prompt config
├── grub/          → Bootloader theme
└── sddm/          → M3 login manager

~/.local/bin/
├── bn-menu        → Main hub launcher
├── scripts/       → Submenus (system, audio, bluetooth, etc.)
└── *.sh           → Utility scripts (brightness, volume, media, weather, etc.)
```



<a id="4--first-login"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=4.+FIRST+LOGIN" width="435"/>

### Set your wallpaper

Place wallpapers in `~/Pictures/Wallpapers/` and run:

```bash
# Opens wallpaper selector
SUPER + W
```

Or manually:

```bash
~/.config/rofi/scripts/wallselect.sh
```

Matugen generates the M3 colour palette from your wallpaper automatically.

### Keybind reference

| Binding | Action |
|---------|--------|
| `SUPER + SPACE` | bn-menu (main hub) |
| `SUPER + R` | App launcher |
| `SUPER + SHIFT + O` | BlackNode Dashboard |
| `SUPER + N` | Notification centre |
| `SUPER + V` | Quick Config HUD |
| `SUPER + D` | Kitty terminal |
| `SUPER + E` | Dolphin file manager |
| `SUPER + Q` | Close focused window |
| `SUPER + SHIFT + X` | Power menu |

Full list: [KEYBINDS.md](./KEYBINDS.md)

> [!NOTE]
> If the keyboard layout does not match your hardware, edit `~/.config/hypr/settings/input.lua` and change `kb_layout` then run `hyprctl reload`.



<a id="troubleshooting"></a>
<img src="https://readme-typing-svg.herokuapp.com?font=Lexend+Giga&size=22&pause=1000&color=6CB6FF&vCenter=true&width=435&height=25&lines=TROUBLESHOOTING" width="435"/>

### Hyprland does not start
Ensure your GPU is supported and you are launching from a TTY with `Hyprland` (not `hyprland`). Both SDDM and TTY login should work.

### Rofi themes look wrong
Run matugen on a wallpaper to regenerate the colour palette:

```bash
matugen image ~/Pictures/Wallpapers/your-wallpaper.jpg
```

### bn-menu not found
You may need to run `linkdots` to create the symlink:

```bash
bash Scripts/linkdots.sh
```

### Restoring your old configs
The backup is at `~/.config/blacknode-backup-<timestamp>/`. Restore individual files or entire directories from there.



<div align="center">
  <p>Made with &hearts; by <a href="https://github.com/zhaleff">zhaleff</a></p>
  <p><i>Happy hacking.</i></p>
</div>

<div align="right">
  <sub>Last edited: 2026</sub>
</div>
