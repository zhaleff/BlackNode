<h1 align="center">HollowSec's Waybar Configurations</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/configs-3-blue?style=for-the-badge&logo=wayland&logoColor=white&labelColor=302D41&color=89B4FA" alt="Configs"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/last%20updated-2025--03--02-green?style=for-the-badge&logo=github&logoColor=white&labelColor=302D41&color=A6E3A1" alt="Last Updated"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge&logo=open-source-initiative&logoColor=white&labelColor=302D41&color=F9E2AF" alt="License"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/Waybar-0.9.24+-brightgreen?style=for-the-badge&logo=files&logoColor=white&labelColor=302D41&color=CBA6F7" alt="Waybar"></a>
  </p>
</div>

Hello.  This is a quick overview of my Waybar configurations – or as I like to call them, **HollowBars**.  Currently there are three distinct styles, each tailored to a different workflow.  I’m constantly developing new ones, so expect this collection to grow.

---

## The Three Styles

| Style | Name | Description | Status |
|-------|------|-------------|--------|
| 1 | **Classic** | A balanced, full‑featured bar with workspaces, media controls, system resources, and clock. Ideal for daily driving. | ✅ Stable |
| 2 | **Hacking** | Designed for penetration testing and CTF work. Includes VPN status, target IP, and quick‑access tools. | ⚠️ Currently broken (WIP) |
| 3 | **Minimal** | Ultra‑clean bar with only three modules: workspaces, clock, and system tray. Perfect for distraction‑free focus. | ✅ Stable |

---

### Style 1 – Classic

The default configuration.  It groups modules into left and right sections, covering:

- Hyprland workspaces
- Media playback (MPRIS + controls)
- Hardware indicators (backlight, audio, network, battery)
- Package update counts (pacman & AUR)
- System resources (CPU, temperature, memory)
- Clock and idle inhibitor
- Active window title

This is the style documented in the main `MODULES.md`.

---

### Style 2 – Hacking (Work in Progress)

A specialised bar for security work.  It aims to include:

- VPN connection status (HTB, TryHackMe, etc.)
- Custom target IP module (with click to set)
- Network scanning shortcuts
- Minimal distractions

Currently this configuration is **unstable** and not recommended for daily use.  I’m actively reworking it to be both functional and visually consistent.

---

### Style 3 – Minimal

As the name suggests, this bar is stripped down to the essentials:

- **Left:** Hyprland workspaces
- **Center:** (empty)
- **Right:** Clock and system tray

That’s it.  Three modules, zero clutter.  Ideal for users who want just enough information to navigate and nothing more.

---

## Roadmap

I plan to add at least two more configurations in the coming months:

- **Gaming** – with FPS counter, GPU stats, and Discord integration.
- **Productivity** – focused on todo lists, calendar, and email notifications.

If you have ideas or requests, feel free to open an issue or reach out directly.

---

Happy customising.

**— HollowSec**
