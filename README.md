<div align="center">

<img src="./Images/musicPlayer.png" alt="BlackNode desktop with the music player open" width="100%">

<div align="center">
<img src="./Images/cavaNvim.png" alt="Cava and Neovim sharing the desktop palette" width="49%">
<img src="./Images/wallselect.png" alt="Wallpaper selector that generates the palette" width="49%">
</div>

<div align="center">
<img src="./Images/blacknodeMenu.png" alt="The BlackNode control menu" width="49%">
<img src="./Images/launcherApp.png" alt="Application launcher" width="49%">
</div>

<div align="center">
<img src="./Images/fastfetch.png" alt="Fastfetch with BlackNode colors" width="49%">
<img src="./Images/btop.png" alt="btop with the generated palette" width="49%">
</div>

<div align="center">
<img src="./Images/screenshotMenu.png" alt="Screenshot menu" width="49%">
<img src="./Images/wlogout.png" alt="Session menu" width="49%">
</div>

<sub>Every screenshot comes from a running session.</sub>

<br>
<br>

<h1>BlackNode</h1>

<h3>A complete desktop for Arch Linux and Hyprland.</h3>

<p>Install it once. Stop fixing it.</p>

<br>

<a href="https://github.com/zhaleff/BlackNode/stargazers"><img src="https://img.shields.io/github/stars/zhaleff/BlackNode?style=for-the-badge&logo=github&logoColor=F9E2AF&label=STARS&labelColor=181825&color=F9E2AF" alt="Stars"></a>&nbsp;&nbsp;
<a href="https://github.com/zhaleff/BlackNode/commits/main"><img src="https://img.shields.io/github/last-commit/zhaleff/BlackNode?style=for-the-badge&logo=git&logoColor=A6E3A1&label=UPDATED&labelColor=181825&color=A6E3A1" alt="Last commit"></a>&nbsp;&nbsp;
<a href="./LICENSE"><img src="https://img.shields.io/github/license/zhaleff/BlackNode?style=for-the-badge&logo=opensourceinitiative&logoColor=CBA6F7&label=LICENSE&labelColor=181825&color=CBA6F7" alt="MIT license"></a>&nbsp;&nbsp;
<img src="https://img.shields.io/badge/ARCH%20LINUX-HYPRLAND-89B4FA?style=for-the-badge&logo=archlinux&logoColor=89B4FA&label=BUILT%20FOR&labelColor=181825" alt="Built for Arch Linux and Hyprland">

<br>
<br>

**[Install](#install)** &nbsp;·&nbsp; **[Philosophy](./docs/philosophy.md)** &nbsp;·&nbsp; **[FAQ](#faq)**

</div>

## The last ten percent

You look at your desktop before you start any work. When it looks unfinished, you feel it every day.

The last ten percent is the expensive part: a bar that almost matches, one application that ignores the palette, a keybind you keep meaning to change. None of it breaks your work. All of it takes a little attention, every time you sit down.

BlackNode finishes that ten percent. It is one system: window manager, bar, launcher, notifications, lock screen, terminal, editor, and the scripts that connect them. The parts share a palette and a keyboard grammar. You install it, pick an image, and go back to work.

## Install in one command

Built for **Arch Linux** with **Hyprland**. The installer checks your system, installs what is missing, backs up what it replaces, and asks before it touches anything.

```bash
git clone https://github.com/zhaleff/BlackNode.git "$HOME/BlackNode" && cd "$HOME/BlackNode" && bash Scripts/install.sh
```

Your GTK, Qt, shell, and Zsh configuration will be replaced. Before that, everything is copied to `~/.blacknode-backup-YYYYmmdd-HHMMSS`, and every step is logged to `~/.blacknode-install.log`. If you dislike it, you go back to what you had.

Then:

1. Log out and back in.
2. Press <kbd>SUPER</kbd> + <kbd>W</kbd> and choose an image.
3. Press <kbd>SUPER</kbd> + <kbd>SPACE</kbd> to open the menu. Start working.

The palette is generated from your image, so the desktop is not complete until you pick one. If something looks unstyled on first login, the [first-boot guide](./docs/firstBoot.md) covers it.

<details>
<summary><b>Not on Arch, or not ready to switch?</b></summary>

<br>

You can read the configuration and take what you need, but the installer and the packages assume Arch. Star the repo. When you switch, it will be here.

</details>

## What is inside

- **Hyprland** runs the session and the layout.
- **Waybar** is the bar, **Rofi** the launcher, **wlogout** the session menu, **hyprlock** the lock screen.
- **Kitty**, **Zsh** and **Neovim** are the terminal, the shell and the editor.
- **matugen** builds the palette from the image you choose, and every piece reads it.
- **grim** and **slurp** take screenshots, **cliphist** keeps the clipboard history.
- **btop**, **fastfetch** and **cava** are themed to match.

BlackNode makes one choice for each shared surface: one layout, one control menu, one palette source. That is why the parts fit.

## What you stop doing

- Spending two days tuning, again. You run one command and get a desktop that holds.
- Living with five applications in five different looks. One palette covers everything you see.
- Relearning keybinds. One grammar handles focus, movement, and workspaces.
- Calling your setup "almost right". You stop noticing it.
- Worrying about your old configuration. It sits in a timestamped backup with a full install log.

## Is this for you?

It is if you have opinions about window management, you have redesigned your bar more than once, you keep a folder of screenshots of setups you wanted, you notice when one application does not match the rest, and you would rather press a key than move the mouse.

Three or more of those, and it was built for you. If you want a desktop assembled by committee, or "good enough" is fine, skip it.

## Questions

<details>
<summary><b>Is this a theme pack?</b></summary>

<br>

No. It is a full session: layout, menus, notifications, lock screen, shell, and editor. The colors come from one source, so the pieces agree.

</details>

<details>
<summary><b>Do I need to know Hyprland?</b></summary>

<br>

No. Install, log in, choose an image. When you want to change something, the files are plain text and the [manual](./docs/README.md) explains them.

</details>

<details>
<summary><b>Will it overwrite my setup?</b></summary>

<br>

After backing it up. Your configuration is copied to `~/.blacknode-backup-YYYYmmdd-HHMMSS` before anything is replaced, and every command is logged.

</details>

<details>
<summary><b>What if something breaks?</b></summary>

<br>

Read the log, then [loose ends](./docs/looseEnds.md). It lists what is incomplete, what needs optional packages, and what to check first.

</details>

<details>
<summary><b>Why is it free?</b></summary>

<br>

MIT license: use it, change it, make it yours. If it saves you a weekend, star the repo so the next person finds it.

</details>

## Philosophy

The design rules come from Stoicism. Epictetus separated what is up to us from what is not. Marcus Aurelius asked whether a thing was necessary before adding it. Seneca counted cost in time. BlackNode asks those questions of a desktop. [Read the full philosophy.](./docs/philosophy.md)

---

<div align="center">

<sub>MIT License · Made by <a href="https://github.com/zhaleff">zhaleff</a></sub>

</div>
