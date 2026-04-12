```
                                                                                    )                   
 (  (           (                             )         (   (                )  ( /(        (          
 )\))(   '   (  )\             )      (    ( /(       ( )\  )\    )       ( /(  )\())       )\ )   (   
((_)()\ )   ))\((_) (   (     (      ))\   )\()) (    )((_)((_)( /(   (   )\())((_)\   (   (()/(  ))\  
_(())\_)() /((_)_   )\  )\    )\  ' /((_) (_))/  )\  ((_)_  _  )(_))  )\ ((_)\  _((_)  )\   ((_))/((_)
\ \((_)/ /(_)) | | ((_)((_) _((_)) (_))   | |_  ((_)  | _ )| |((_)_  ((_)| |(_)| \| | ((_)  _| |(_)) 
 \ \/\/ / / -_)| |/ _|/ _ \| '  \()/ -_)  |  _|/ _ \  | _ \| |/ _` |/ _| | / / | .` |/ _ \/ _` |/ -_)
  \_/\_/  \___||_|\__|\___/|_|_|_| \___|   \__|\___/  |___/|_|\__,_|\__| |_\_\ |_|\_|\___/\__,_|\___|  
```

#

> A minimal, modular Hyprland dotfile environment for Arch Linux.  
> Built by [zhaleff](https://github.com/zhaleff) — MIT Licence.

#

## Overview

BlackNode is a fully modular dotfile suite built around Hyprland on Arch Linux. Every component has its own independent install script. No script depends on another. You run only what you need, nothing more.

The environment is built around a deliberate stack: every tool was chosen for a reason. Nothing is installed by default just because it is popular.

#

## Requirements

- Arch Linux (or an Arch-based distro)
- `git` installed
- An internet connection
- A non-root user with `sudo` access

#

## Installation

#

### 1. Clone the repository

Clone BlackNode into your home directory. The scripts expect the repo to live at `$HOME/BlackNode/`.

```bash
git clone https://github.com/zhaleff/BlackNode.git $HOME/BlackNode
```

#

### 2. Navigate to the repo

```bash
cd $HOME/BlackNode
```

#

### 3. Run the main installer

The entry point for BlackNode is `blacknode.sh`. This is the only script you need to run manually. It will present you with options and call individual component scripts based on your choices.

```bash
bash blacknode.sh
```

> If you prefer to install components individually, skip to the [Manual Installation](#manual-installation) section below.

#

## Manual Installation

Every script in BlackNode is fully independent. You can run any of them on their own, in any order, without running `blacknode.sh` first.

Before installing most components, you will need `yay` as your AUR helper. If you do not have it yet, run this first:

```bash
bash yay.sh
```

After that, run whichever scripts you need.

#

### Documentation scripts

These scripts have no side effects. They only print information to the terminal.

```bash
bash welcome.sh        # BlackNode ASCII banner and project intro
bash introduction.sh   # Environment overview, philosophy and component list
bash information.sh    # Live check — shows which components are installed
bash changelog.sh      # Version history
bash help.sh           # Full reference of every available script
```

#

### Core

```bash
bash yay.sh            # Installs the yay AUR helper (uses pacman + git)
bash flatpak.sh        # Installs Flatpak and adds the Flathub remote
bash bins.sh           # Deploys BlackNode scripts to ~/.local/bin
bash update.sh         # Full system update — pacman → yay → flatpak
```

#

### Window Manager

```bash
bash hyprland.sh       # Hyprland + xdg-desktop-portal-hyprland → ~/.config/hypr/
bash hyprlock.sh       # hyprlock + hypridle (pacman extra) → ~/.config/hypr/
bash hyprshot.sh       # hyprshot (pacman extra) + creates ~/Pictures/Screenshots
```

> `hyprlock` and `hyprshot` are installed directly via `pacman` since both are available in the official `extra` repository.

#

### Bar & Launcher

```bash
bash waybar.sh         # Waybar → ~/.config/waybar/
bash rofi.sh           # rofi-wayland → ~/.config/rofi/
```

#

### Terminal & Shell

```bash
bash kitty.sh          # Kitty terminal → ~/.config/kitty/
bash alacritty.sh      # Alacritty terminal → ~/.config/alacritty/
bash zsh.sh            # Zsh + Powerlevel10k → ~/.config/zsh/ + sets default shell
```

> `zsh.sh` installs `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions` and `zsh-theme-powerlevel10k-git`. It also calls `chsh` to set Zsh as your default shell. You will need to log out and back in for the change to take effect.

#

### Tools

```bash
bash nvim.sh           # Neovim → ~/.config/nvim/
bash yazi.sh           # Yazi + preview dependencies → ~/.config/yazi/
bash fastfetch.sh      # Fastfetch → ~/.config/fastfetch/
bash cava.sh           # Cava audio visualiser → ~/.config/cava/
bash clipse.sh         # Clipse clipboard manager → ~/.config/clipse/
bash dunst.sh          # Dunst + libnotify → ~/.config/dunst/
bash wlogout.sh        # wlogout → ~/.config/wlogout/
```

> `yazi.sh` also installs the following preview dependencies: `ffmpegthumbnailer`, `unar`, `jq`, `poppler`, `fd`, `ripgrep`, `fzf`, `zoxide`, `imagemagick`.

#

### Theming

```bash
bash wallust.sh        # wallust colour-scheme generator → ~/.config/wallust/
bash wallpaper.sh      # Interactive — moves your wallpapers to ~/.local/share/wallpapers
bash gtk.sh            # nwg-look + GTK 3/4 themes → ~/.config/gtk-3.0/ + gtk-4.0/
bash awww.sh           # awww wallpaper daemon + creates ~/Pictures/Wallpapers
```

> BlackNode uses `awww` as its wallpaper daemon. `awww` is the active fork of `swww` with GPU-accelerated transitions. `swww` is no longer maintained.

> Wallpapers are stored at `~/.local/share/wallpapers`. `wallpaper.sh` will ask you where your current wallpapers are and move them there automatically.

#

## Repository Structure

```
$HOME/BlackNode/
├── blacknode.sh              ← main installer entry point
├── yay.sh
├── hyprland.sh
├── waybar.sh
├── ... (one script per component)
└── Configs/
    ├── .config/
    │   ├── hypr/
    │   ├── waybar/
    │   ├── kitty/
    │   ├── alacritty/
    │   ├── nvim/
    │   ├── rofi/
    │   ├── dunst/
    │   ├── zsh/
    │   ├── powerlevel10k/
    │   ├── yazi/
    │   ├── fastfetch/
    │   ├── cava/
    │   ├── clipse/
    │   ├── wallust/
    │   ├── wlogout/
    │   ├── gtk-3.0/
    │   ├── gtk-4.0/
    │   ├── qt5ct/
    │   └── sddm/
    └── .local/
        └── bin/              ← scripts deployed via bins.sh
```

#

## Update

To update the entire system at once:

```bash
bash update.sh
```

This runs `pacman -Syu`, then `yay -Syu`, then `flatpak update` in sequence. Any tool that is not installed is skipped automatically.

#

## Licence

MIT — see [LICENSE](./LICENSE) for the full text.

#

## Author

Made with intent by [zhaleff](https://github.com/zhaleff).
