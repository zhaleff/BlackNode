<div align="center">

<img src="./Images/musicPlayer.png" alt="BlackNode desktop" width="100%">

<br>
<br>

<h1>BlackNode</h1>

<h3>A complete desktop for Arch Linux and Hyprland.</h3>

<p>Install it once. Stop fixing it.</p>

<a href="https://github.com/zhaleff/BlackNode/stargazers"><img src="https://img.shields.io/github/stars/zhaleff/BlackNode?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=C9CBFF&labelColor=302D41" alt="Stars"></a>&nbsp;
<a href="https://github.com/zhaleff/BlackNode/forks"><img src="https://img.shields.io/github/forks/zhaleff/BlackNode?style=for-the-badge&logo=git&logoColor=f9e2af&label=Forks&labelColor=302D41&color=f9e2af" alt="Forks"></a>&nbsp;
<a href="https://github.com/zhaleff/BlackNode/commits/main"><img src="https://img.shields.io/github/last-commit/zhaleff/BlackNode?style=for-the-badge&logo=git&logoColor=white&label=Updated&labelColor=302D41&color=A6E3A1" alt="Last commit"></a>&nbsp;
<a href="https://github.com/zhaleff/BlackNode/blob/main/LICENSE"><img src="https://img.shields.io/github/license/zhaleff/BlackNode?style=for-the-badge&logo=opensourceinitiative&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="License"></a>

<br>

<img src="https://img.shields.io/badge/version-2.4.1-CBA6F7?style=for-the-badge&labelColor=302D41" alt="Version 2.4.1">&nbsp;
<img src="https://img.shields.io/badge/platform-Arch%20Linux-89B4FA?style=for-the-badge&logo=archlinux&logoColor=89B4FA&labelColor=302D41" alt="Arch Linux">&nbsp;
<img src="https://img.shields.io/badge/session-Hyprland-B4BEFE?style=for-the-badge&labelColor=302D41" alt="Hyprland">

<br>
<br>

<a href="#install"><img src="https://img.shields.io/badge/INSTALL-BlackNode-CBA6F7?style=for-the-badge&logo=archlinux&logoColor=white&labelColor=302D41" alt="Install BlackNode"></a>&nbsp;
<a href="#see-it"><img src="https://img.shields.io/badge/SEE%20IT-Screenshots-C9CBFF?style=for-the-badge&labelColor=302D41" alt="See BlackNode"></a>&nbsp;
<a href="./docs/philosophy.md"><img src="https://img.shields.io/badge/PHILOSOPHY-Stoicism-B4BEFE?style=for-the-badge&labelColor=302D41" alt="Read the philosophy"></a>&nbsp;
<a href="#questions"><img src="https://img.shields.io/badge/QUESTIONS-FAQ-f9e2af?style=for-the-badge&labelColor=302D41" alt="Questions"></a>

</div>

---

Your desktop is the first thing you see before you start work. When it looks unfinished, you feel it every day. The last ten percent is the expensive part: a bar that almost matches, one application that ignores the palette, a keybind you keep meaning to change. None of it breaks your work. All of it takes a little attention, every time.

BlackNode finishes that ten percent. It ships as one system: window manager, bar, launcher, notifications, lock screen, terminal, editor, and the scripts that connect them. The parts share a palette and a keyboard grammar. You install it in minutes, choose an image, and go back to work.

The design rules come from Stoicism. Epictetus drew the line between what is up to us and what is not. Marcus Aurelius asked whether a thing was necessary before adding it. Seneca counted cost in time. BlackNode applies those questions to a desktop. [Read the full philosophy.](./docs/philosophy.md)

---

## See it

<div align="center">

<img src="./Images/cavaNvim.png" alt="Cava and Neovim sharing the desktop palette" width="100%">

<sub>One palette across the terminal, the editor, and the bar.</sub>

<br>
<br>

<table>
  <tr>
    <td width="50%" align="center"><img src="./Images/blacknodeMenu.png" alt="The BlackNode control menu" width="100%"></td>
    <td width="50%" align="center"><img src="./Images/launcherApp.png" alt="Application launcher in BlackNode" width="100%"></td>
  </tr>
  <tr>
    <td align="center"><sub>The control menu: network, audio, clipboard, session.</sub></td>
    <td align="center"><sub>The application launcher, without leaving the keyboard.</sub></td>
  </tr>
</table>

<br>

<table>
  <tr>
    <td width="50%" align="center"><img src="./Images/fastfetch.png" alt="Fastfetch with BlackNode theming" width="100%"></td>
    <td width="50%" align="center"><img src="./Images/btop.png" alt="btop with the generated palette" width="100%"></td>
  </tr>
  <tr>
    <td align="center"><sub>The small utilities use the same colors.</sub></td>
    <td align="center"><sub>Nothing looks bolted on.</sub></td>
  </tr>
  <tr>
    <td width="50%" align="center"><img src="./Images/screenshotMenu.png" alt="Screenshot menu in BlackNode" width="100%"></td>
    <td width="50%" align="center"><img src="./Images/wlogout.png" alt="Session menu in BlackNode" width="100%"></td>
  </tr>
  <tr>
    <td align="center"><sub>Screenshots without breaking focus.</sub></td>
    <td align="center"><sub>A session menu with a clear exit.</sub></td>
  </tr>
</table>

</div>

Every screenshot on this page comes from a running session. The gaps are documented in [loose ends](./docs/looseEnds.md).

---

## Why BlackNode

| What costs you now | What changes |
|---|---|
| Two days spent tuning, again | One command, then a desktop that holds |
| Five applications with five different looks | One palette across everything you see |
| A keybind system you keep relearning | One grammar for focus, movement, and workspaces |
| A setup that is almost right | A setup you stop noticing |
| Worry about losing your old configuration | A timestamped backup and a full install log |

The rules are simple:

- **Control.** You own the files and the keybinds. Nothing depends on a service you cannot inspect.
- **Necessity.** Every option is a decision someone has to make later. BlackNode ships fewer of them.
- **Reversibility.** The installer backs up what it replaces and logs every step. You can go back.

BlackNode makes one choice for each shared surface: one layout, one control menu, one palette source. That is why the parts fit.

### Who this is for

- [ ] You have opinions about window management.
- [ ] You have redesigned your bar more than once.
- [ ] You have a folder of screenshots of setups you wanted.
- [ ] You notice when one application does not match the rest.
- [ ] You would rather press a key than move the mouse.
- [ ] You want it to look good, but you need it to work.
- [ ] You are tired of calling your setup "almost done".

If three or more apply, this was built for you.

### Who it is not for

- People who want a desktop assembled by a committee.
- People who are fine with "good enough".
- People who do not use Arch or Hyprland.

---

## Install

> [!TIP]
> **The installer takes minutes. The backup happens before anything is replaced.**

Built for **Arch Linux** with **Hyprland**. The installer checks your system, installs what is missing, backs up what it replaces, and asks before it touches anything.

```bash
git clone https://github.com/zhaleff/BlackNode.git "$HOME/BlackNode" && cd "$HOME/BlackNode" && bash Scripts/install.sh
```

> [!IMPORTANT]
> Your current GTK, Qt, shell, and Zsh configuration will be replaced. Everything is copied to `~/.blacknode-backup-YYYYmmdd-HHMMSS` first, and every step is logged to `~/.blacknode-install.log`.

### After the installer

1. Log out and back in.
2. Press <kbd>SUPER</kbd> + <kbd>W</kbd> and choose an image you like.
3. Press <kbd>SUPER</kbd> + <kbd>SPACE</kbd> to see the menu, then start working.

> [!NOTE]
> The generated palette needs one image before the desktop is complete. If something looks unstyled on the first login, [the first-boot guide](./docs/firstBoot.md) explains the missing step.

<details>
<summary><b>Not on Arch, or not ready to switch?</b></summary>

<br>

BlackNode is built for Arch and its derivatives. On another distribution you can read the configuration and take what you need, but the installer and packages assume Arch.

Star the repo. When you switch, it will be here.

</details>

---

## Questions

<details>
<summary><b>Is this just a theme pack?</b></summary>

<br>

No. BlackNode is a full session: the layout, the menus, the notifications, the lock screen, the shell, and the editor. The colors come from one source so the pieces agree with each other.

</details>

<details>
<summary><b>Do I need to know how to configure Hyprland?</b></summary>

<br>

No. Install, log in, choose an image. The defaults are designed to work on their own. When you want to change something, the files are plain text and the [manual](./docs/README.md) is there.

</details>

<details>
<summary><b>Will it overwrite my current setup?</b></summary>

<br>

Only after backing it up. Your existing configuration is copied to `~/.blacknode-backup-YYYYmmdd-HHMMSS` before anything is replaced. Every command is logged. You can return to your old setup at any time.

</details>

<details>
<summary><b>What if something breaks?</b></summary>

<br>

Read the log, then [loose ends](./docs/looseEnds.md). It lists what is incomplete, what depends on optional packages, and what to check first.

</details>

<details>
<summary><b>Why is it free?</b></summary>

<br>

Because it is a desk worth sharing. The project uses the MIT license: use it, change it, make it yours. If it saves you a weekend, star the repo so someone else can find it.

</details>

---

<div align="center">

<h2>Install BlackNode</h2>

<p>One command. The installer handles the rest.</p>

<br>

<a href="#install"><img src="https://img.shields.io/badge/INSTALL-BlackNode-CBA6F7?style=for-the-badge&logo=archlinux&logoColor=white&labelColor=302D41" alt="Install BlackNode"></a>&nbsp;
<a href="./docs/philosophy.md"><img src="https://img.shields.io/badge/READ-The%20Philosophy-B4BEFE?style=for-the-badge&labelColor=302D41" alt="Read the philosophy"></a>

<br>
<br>

<sub>Built on Arch Linux and Hyprland. Released under the <a href="./LICENSE">MIT License</a>.</sub>

<sub>If it saves you a weekend, use the Star button on GitHub.</sub>

<sub>Made by <a href="https://github.com/zhaleff">zhaleff</a>.</sub>

</div>
